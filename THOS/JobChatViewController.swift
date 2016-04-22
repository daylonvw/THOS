//
//  JobChatViewController.swift
//  Jobie
//
//  Created by daylonvanwel on 08-02-16.
//  Copyright © 2016 daylon wel. All rights reserved.
//

import UIKit
import Foundation
import MediaPlayer
import EventKit

class JobChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PayPalPaymentDelegate {

    var timer: NSTimer = NSTimer()
    var isLoading: Bool = false
    
    var jobId: String!
    var jobGeoPoint: PFGeoPoint!
    var jobDescription: String!
    var job: PFObject!

    var users = [PFUser]()
    var messages = [JSQMessage]()
    var avatars = Dictionary<String, JSQMessagesAvatarImage>()
    
    var bubbleFactory = JSQMessagesBubbleImageFactory()
    var outgoingBubbleImage: JSQMessagesBubbleImage!
    var incomingBubbleImage: JSQMessagesBubbleImage!
    
    var blankAvatarImage: JSQMessagesAvatarImage!
    
    var senderImageUrl: String!
    var batchMessages = true
    
    let eventStore = EKEventStore()

    
    var datePicker: UIDatePicker!
    var dateImageView: UIImageView!
    var dateButton: UIButton!
    var dateCancelButton: UIButton!

    var phoneNumberEntered: Bool!
    
    
    #if HAS_CARDIO
    var acceptCreditCards: Bool = true {
    didSet {
    payPalConfig.acceptCreditCards = acceptCreditCards
    }
    }
    
    
    #else
    var acceptCreditCards: Bool = false {
        didSet {
            payPalConfig.acceptCreditCards = acceptCreditCards
        }
    }
    #endif
    
    var resultText = "" // empty
    var payPalConfig = PayPalConfiguration() // default

    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        let user = PFUser.currentUser()
        self.senderId = user!.objectId
        self.senderDisplayName = user![PF_USER_FULLNAME] as! String
        
        self.navigationBar.items![0].title = self.jobDescription

        outgoingBubbleImage = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImage = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        
                
        isLoading = false
        self.loadMessages()
        Messages.clearMessageCounter(jobId);
        
    
        if job["acceptedDate"] != nil {
            
            self.inputToolbar?.contentView?.leftBarButtonItem?.hidden = true
            
        }
//todo disbale change of device orienation
        
        NSNotificationCenter.defaultCenter().addObserverForName("messageFromJobHelperRecieved", object: nil, queue: nil) { (notification) -> Void in
            
            print(notification)
            
            self.loadMessages()
        }
        
        //        title = "PayPal SDK Demo"
        //        successView.hidden = true
        
        // Set up payPalConfig
        payPalConfig.acceptCreditCards = true;
        
        payPalConfig.merchantName = "T.H.O.S."
        payPalConfig.merchantPrivacyPolicyURL = NSURL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = NSURL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        
        PayPalMobile.preconnectWithEnvironment(PayPalEnvironmentSandbox)
        
        
        
        // Setting the languageOrLocale property is optional.
        //
        // If you do not set languageOrLocale, then the PayPalPaymentViewController will present
        // its user interface according to the device's current language setting.
        //
        // Setting languageOrLocale to a particular language (e.g., @"es" for Spanish) or
        // locale (e.g., @"es_MX" for Mexican Spanish) forces the PayPalPaymentViewController
        // to use that language/locale.
        //
        // For full details, including a list of available languages and locales, see PayPalPaymentViewController.h.
        
        payPalConfig.languageOrLocale = NSLocale.preferredLanguages()[0]
        
        // Setting the payPalShippingAddressOption property is optional.
        //
        // See PayPalConfiguration.h for details.
        
        payPalConfig.payPalShippingAddressOption = .PayPal;
        
        //        print("PayPal iOS SDK Version: \(PayPalMobile.libraryVersion())")

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView!.collectionViewLayout.springinessEnabled = true
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // Mark: - Backend methods
    
    func loadMessages() {
        
        if self.isLoading == false {
            self.isLoading = true
            let lastMessage = messages.last
            // querie for chats
            let query = PFQuery(className: PF_CHAT_CLASS_NAME)
            query.whereKey(PF_CHAT_GROUPID, equalTo: jobId)
           
            if lastMessage != nil {
                query.whereKey(PF_CHAT_CREATEDAT, greaterThan: (lastMessage?.date)!)
            }
            query.includeKey(PF_CHAT_USER)
            query.includeKey("toUser")
            query.orderByDescending(PF_CHAT_CREATEDAT)
            query.limit = 200
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
               
                if error == nil {
                   
                    self.job["posterReadLastText"] = true
                    self.job.saveInBackground()
                    self.automaticallyScrollsToMostRecentMessage = false
                    
                    for object in Array((objects as [PFObject]!).reverse()) {
                        
                        self.addMessage(object)

                        print(object.createdAt)
                        if object["toUser"] != nil {
                        
                            let toUser = object["toUser"] as! PFUser

                            if PFUser.currentUser()!.objectId == toUser.objectId {
                                
                                object["isRead"] = true
                                object.saveInBackground()
                                
                            } else {
                                
                                // nothing yet
                            }
                        }
                        
                    }
                    
                    if objects!.count > 0 {
                        
                        self.finishReceivingMessage()
                        self.scrollToBottomAnimated(false)
                    }
                    self.automaticallyScrollsToMostRecentMessage = true
                    
                } else {
                    
                    print(error)
                }
                
                self.isLoading = false;
            })
        }
    }
    
    func addMessage(object: PFObject) {
       
        var message: JSQMessage!
        
        let user = object[PF_CHAT_USER] as! PFUser
        let name = user[PF_USER_FULLNAME] as! String
        
        let videoFile = object[PF_CHAT_VIDEO] as? PFFile
        let pictureFile = user[PF_CHAT_PICTURE] as? PFFile
        
        let jobDate = object[PF_JOB_DATE] as? NSDate
        
        if videoFile == nil && pictureFile == nil && jobDate == nil  {
            
            message = JSQMessage(senderId: user.objectId, senderDisplayName: name, date: object.createdAt, text: (object[PF_CHAT_TEXT] as? String), jobDate: nil)
            
        }
        
        if videoFile != nil {
            let mediaItem = JSQVideoMediaItem(fileURL: NSURL(string: videoFile!.url!), isReadyToPlay: true)
            message = JSQMessage(senderId: user.objectId, senderDisplayName: name, date: object.createdAt, media: mediaItem, jobDate: nil)
        }
        
        if pictureFile != nil {
            
            let mediaItem = JSQPhotoMediaItem(image: nil)
            mediaItem.appliesMediaViewMaskAsOutgoing = (user.objectId == self.senderId)
            message = JSQMessage(senderId: user.objectId, senderDisplayName: name, date: object.createdAt, media: mediaItem, jobDate:  nil)
            
            pictureFile!.getDataInBackgroundWithBlock({ (imageData, error) -> Void in
                if error == nil {
                    mediaItem.image = UIImage(data: imageData!)
                    self.collectionView!.reloadData()
                }
            })
        }
        
        if jobDate != nil {
            
            
            message = JSQMessage(senderId: user.objectId, senderDisplayName: name, date: object.createdAt, text: (object[PF_CHAT_TEXT] as? String), jobDate: object[PF_JOB_DATE] as? NSDate)
            
        }
        
        users.append(user)
        messages.append(message)
        
        self.collectionView?.reloadData()
        
    }
    
    func sendMessage(text: String, video: NSURL?, picture: UIImage?, jobDate: NSDate?) {
      
        self.phoneNumberEntered = false
        
        let allText = text.componentsSeparatedByString(" ")
        
        for word in allText {
            
            if word.hasPrefix("+31") || word.hasPrefix("06") {
                
                self.phoneNumberEntered = true
            }
            
            
        }
        
        if phoneNumberEntered == false {
            
            let object = PFObject(className: PF_CHAT_CLASS_NAME)
            
            object[PF_CHAT_USER] = PFUser.currentUser()
            object[PF_CHAT_GROUPID] = self.jobId
            object[PF_CHAT_TEXT] = text
            object["toUser"] = self.job["acceptedUser"]
            object["isRead"] = false
            
            if let jobDate = jobDate {
                
                object[PF_JOB_DATE] = jobDate
                
                
            } else {
                
                
            }
            
            object.saveInBackgroundWithBlock { (succeeded, error) -> Void in
                if error == nil {
                    JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    self.loadMessages()
                } else {
                    
                }
            }
            
            sendMessgePush(jobId, text: text)
            Messages.updateMessageCounter(jobId, lastMessage: text)
            
            job["helperReadLastText"] = false
            job.saveInBackground()

            self.finishSendingMessage()
            
        } else {
            
            self.keyboardController.textView?.resignFirstResponder()
            let imageView = UIImageView(frame: self.view.frame)
            imageView.image = UIImage(named: "dare")
            imageView.backgroundColor = UIColor.blackColor()
            imageView.contentMode = .ScaleAspectFit
            self.view.addSubview(imageView)
        }
    }
    
    // MARK: - JSQMessagesViewController method overrides
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
       
        self.sendMessage(text, video: nil, picture: nil, jobDate: nil)
    }
    
    func sendMessgePush(jobId: String, text: String) {
        
        let pushQuery = PFInstallation.query()
        pushQuery!.whereKey("user", equalTo: job["acceptedUser"])
        
        let dataDIC:[String: AnyObject] = [
            
            "alert"             : text,
            "type"              : "jobPosterMessage",
            "badge"             : "increment",
            "sound"             : "message-sent.aiff",
            "job"               : jobId
            
        ]
        
        let push = PFPush()
        
        push.setQuery(pushQuery)
        push.setData(dataDIC)
        push.sendPushInBackground()

    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
        self.inputToolbar?.contentView?.textView?.resignFirstResponder()
        
        collectionView!.scrollEnabled = false
        
        datePicker = UIDatePicker(frame: CGRect(x: 0, y: 200, width: view.frame.width, height: 150))
        datePicker.tintColor = UIColor.redColor()
        datePicker.minimumDate = NSDate()
        datePicker.datePickerMode = .DateAndTime
        let image = self.collectionView!.convertViewToImage()
        
        let blurImage = image.applyExtraLightEffect()
        
        dateImageView = UIImageView(frame: CGRect(x: 0, y: -40, width: view.frame.size.width, height: view.frame.size.height + 100))
        dateImageView.image = blurImage
        
        
        dateButton = UIButton(frame: CGRect(x: 10, y: 0, width: view.frame.size.width - 20, height: 50))
        dateButton.addTarget(self, action: #selector(JobChatViewController.sendjobDate), forControlEvents: .TouchUpInside)
        dateButton.center = CGPointMake(view.center.x, view.frame.size.height - 120)
        dateButton.setTitle("OK", forState: .Normal)
        dateButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        dateButton.backgroundColor = UIColor.ThosColor()
        
        
        dateCancelButton = UIButton(frame: CGRect(x: 10, y: 0, width: view.frame.size.width - 20, height: 50))
        dateCancelButton.addTarget(self, action: #selector(JobChatViewController.dismissDatePickerView), forControlEvents: .TouchUpInside)
        dateCancelButton.center = CGPointMake(view.center.x, view.frame.size.height - 60)
        dateCancelButton.setTitle("Cancel", forState: .Normal)
        dateCancelButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        dateCancelButton.backgroundColor = UIColor.ThosColor()

        self.view.addSubview(dateCancelButton)
        self.view.addSubview(dateImageView)
        self.view.addSubview(dateButton)
        self.view.addSubview(datePicker)
        
        self.view.bringSubviewToFront(dateImageView)
        self.view.bringSubviewToFront(datePicker)
        self.view.bringSubviewToFront(dateButton)
        self.view.bringSubviewToFront(dateCancelButton)


        
        
    }
    
    func dismissDatePickerView() {
        
        collectionView?.scrollEnabled = true
        self.dateCancelButton.removeFromSuperview()
        self.dateImageView.removeFromSuperview()
        self.datePicker.removeFromSuperview()
        self.dateButton.removeFromSuperview()
        
    }
    
    // MARK: - JSQMessages CollectionView DataSource
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return self.messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = self.messages[indexPath.item]
        
        if message.senderId == self.senderId {
            
            return outgoingBubbleImage
        }
        return incomingBubbleImage
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let user = self.users[indexPath.item]
        if self.avatars[user.objectId!] == nil {
            let thumbnailFile = user[PF_USER_THUMBNAIL] as? PFFile
            thumbnailFile?.getDataInBackgroundWithBlock({ (imageData, error) -> Void in
                if error == nil {
                   
                    self.avatars[user.objectId!] = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: imageData!), diameter: 30)
                    self.collectionView!.reloadData()
                }
            })
            return blankAvatarImage
        } else {
            return self.avatars[user.objectId!]
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath
        
        indexPath: NSIndexPath!) -> NSAttributedString! {
      
        if indexPath.item % 3 == 0 {
           
            let message = self.messages[indexPath.item]
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        return nil;
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = self.messages[indexPath.item]
        if message.senderId == self.senderId {
            return nil
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == message.senderId {
                return nil
            }
        }
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        return nil
    }
    
    // MARK: - UICollectionView DataSource
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = self.messages[indexPath.item]
       
        if message.jobDate != nil {
          
            cell.textView?.textColor = UIColor.ThosColor()
            cell.textView.font = UIFont.systemFontOfSize(16, weight: UIFontWeightBold)
            cell.messageBubbleImageView.image = nil
            
            cell.cancelDateButton.hidden = false
            cell.acceptDateButton.hidden = false
            
            cell.cancelDateButton.addTarget(self, action: #selector(JobChatViewController.declineDateButtonPressed(_:)), forControlEvents: .TouchUpInside)
            cell.acceptDateButton.addTarget(self, action: #selector(JobChatViewController.acceptDateButtonPressed(_:)), forControlEvents: .TouchUpInside)

            
        } else if message.jobDate == nil {
            
            cell.cancelDateButton.hidden = true
            cell.acceptDateButton.hidden = true

            if message.senderId == self.senderId {
                
                cell.textView?.textColor = UIColor.whiteColor()
                
            } else if message.senderId != self.senderId {
                
                cell.textView?.textColor = UIColor.blackColor()
            }
            
        }
        
        return cell
    }
    
    // MARK: - UICollectionView flow layout
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let message = self.messages[indexPath.item]
        if message.senderId == self.senderId {
            return 0
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == message.senderId {
                return 0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 0
    }
    
    // MARK: - Responding to CollectionView tap events
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        print("didTapLoadEarlierMessagesButton")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, atIndexPath indexPath: NSIndexPath!) {
        print("didTapAvatarImageview")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {

    }
    
    func sendAcceptedDatePush() {
        
        let pushQuery = PFInstallation.query()
        pushQuery!.whereKey("user", equalTo: job["acceptedUser"])
        
        let dataDIC:[String: AnyObject] = [
            
            "alert"             : "User accepted the date for: \(self.job["jobDescription"])",
            "type"              : "PosterDateAccepted",
            "badge"             : "increment",
            "sound"             : "message-sent.aiff"
        ]
        
        let push = PFPush()
        
        push.setQuery(pushQuery)
        push.setData(dataDIC)
        push.sendPushInBackground()
        
    }
    
    func declineDateButtonPressed(sender: UIButton) {
        
        let cell = sender.superview as! JSQMessagesCollectionViewCell
        
        let indexPath = self.collectionView.indexPathForCell(cell)
        
        let query = PFQuery(className: "Chat")
        query.whereKey("groupId", equalTo: self.jobId)
        query.orderByDescending(PF_CHAT_CREATEDAT)

        query.findObjectsInBackgroundWithBlock { (objects, error) in
            
            if error == nil {
                
                let messageText = self.messages[(indexPath?.row)!].text

                for chat in objects! {
                    
                    let chatText = chat[PF_CHAT_TEXT] as! String
                    
                    if messageText == chatText {
                        
                        chat.deleteInBackground()

                        self.messages.removeAtIndex((indexPath?.row)!)
                        
                        self.collectionView.reloadData()
                    }
                }
            }
        }
        
    }
    
    func acceptDateButtonPressed(sender: UIButton) {
        
        let cell = sender.superview as! JSQMessagesCollectionViewCell
        
        let indexPath = self.collectionView.indexPathForCell(cell)
        
        let message = self.messages[(indexPath?.row)!]
        
        let controller = UIAlertController(title: "Accept appointment", message: "for job ?", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        
        let acceptDateAction = UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
        
            self.job["acceptedDate"] = message.jobDate
            self.job["posterAcceptedDate"] = true
            self.job.saveInBackground()
        
            self.inputToolbar?.contentView?.leftBarButtonItem?.hidden = true
        
            self.sendAcceptedDatePush()
            self.openPaypal()
            
            self.deleteDateChatsFromParse()
        })
        
        let AddToCalanderAction = UIAlertAction(title: "Yes and add to Calender", style: .Default, handler: { (action) -> Void in
        
            self.createEvent(self.eventStore, title: "job", startDate: message.jobDate)
        
            self.job["acceptedDate"] = message.jobDate
            self.job["posterAcceptedDate"] = true
            self.job.saveInBackground()
        
            self.inputToolbar?.contentView?.leftBarButtonItem?.hidden = true
        
            self.sendAcceptedDatePush()
            self.openPaypal()
            
            self.deleteDateChatsFromParse()
        
        })
        controller.addAction(acceptDateAction)
        controller.addAction(AddToCalanderAction)
        controller.addAction(cancelAction)

        self.presentViewController(controller, animated: true, completion: nil)
        
    }

    func deleteDateChatsFromParse() {
        
        
        let querie = PFQuery(className: "Chat")
        querie.whereKey("groupId", equalTo: self.jobId)
        querie.findObjectsInBackgroundWithBlock { (objects, error) in
            
            if error == nil {
                
                for chat in objects! {
                    
                    if chat["jobDate"] != nil {
                    
                        chat.deleteInBackground()
                        self.deleteMessageFromMessagesArray(chat)
                        
                    }

                }
            }
        }

    }
    
    func deleteMessageFromMessagesArray(chatObject: PFObject) {
        
        for message in self.messages {
            
            if message.text == chatObject[PF_CHAT_TEXT] as! String {
                
                self.messages.removeAtIndex(self.messages.indexOf(message)!)
                self.collectionView.reloadData()
                
                
            }
        }

    }
    
    func openPaypal() {
        
//        let price = self.job["price"] as! NSNumber
//        
//        let item1 = PayPalItem(name: "T.H.O.S.", withQuantity: 1, withPrice: NSDecimalNumber(decimal: price.decimalValue), withCurrency: "EUR", withSku: self.job.objectId)
//        
//        let items = [item1]
//        let subtotal = PayPalItem.totalPriceForItems(items)
//        
//        // Optional: include payment details
//                let shipping = NSDecimalNumber(string: "5.99")
//                let tax = NSDecimalNumber(string: "2.50")
//        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
//        
//        let total = subtotal.decimalNumberByAdding(shipping).decimalNumberByAdding(tax)
//        
//        let payment = PayPalPayment(amount: total, currencyCode: "EUR", shortDescription: "T.H.O.S. \(self.job["jobDescription"])", intent: .Sale)
//        
//        payment.items = items
//        payment.paymentDetails = paymentDetails
//        
//        print(payment)
//        
//        if (payment.processable) {
//           
//            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
//            presentViewController(paymentViewController!, animated: true, completion: nil)
//        }
//        else {
//
//            print("Payment not processalbe: \(payment)")
//        }
//        

    }

    
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapCellAtIndexPath indexPath: NSIndexPath!, touchLocation: CGPoint) {

    }
    
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let video = info[UIImagePickerControllerMediaURL] as? NSURL
        let picture = info[UIImagePickerControllerEditedImage] as? UIImage
        
        self.sendMessage("", video: video, picture: picture, jobDate: nil)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func backButtonPressed() {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sendjobDate() {
        
        collectionView?.scrollEnabled = true

        dateCancelButton.removeFromSuperview()
        dateButton.removeFromSuperview()
        dateImageView.removeFromSuperview()
        datePicker.removeFromSuperview()
        
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .FullStyle
        formatter.timeStyle = .ShortStyle
        let dateString = formatter.stringFromDate(datePicker.date)
        
        
        self.sendMessage(dateString, video: nil, picture: nil, jobDate: self.datePicker.date)
    }

    func createEvent(eventStore: EKEventStore, title: String, startDate: NSDate) {
        
        if EKEventStore.authorizationStatusForEntityType(.Event) != EKAuthorizationStatus.Authorized {
            
            eventStore.requestAccessToEntityType(.Event, completion: { (granted, error ) -> Void in
                
                
                if granted == true {
                    
                    let userLocation = CLLocation(latitude: self.jobGeoPoint.latitude, longitude: self.jobGeoPoint.longitude)
                    let geoCoder = CLGeocoder()
                    
                    geoCoder.reverseGeocodeLocation(userLocation, completionHandler: { (placeMarks: [CLPlacemark]?, error) -> Void in
                        
                        if (placeMarks != nil) {
                            
                            if placeMarks!.count >= 0 {
                                
                                let placeMark = placeMarks![0]
                                
                                let event = EKEvent(eventStore: eventStore)
                                
                                event.title = self.jobDescription
                                event.startDate = startDate
                                event.endDate = startDate.dateByAddingTimeInterval(2000)
                                event.calendar = eventStore.defaultCalendarForNewEvents
                                
                                event.structuredLocation = EKStructuredLocation(mapItem: MKMapItem(placemark: MKPlacemark(placemark: placeMark)))
                                
                                do {
                                    
                                    print("try")
                                    try eventStore.saveEvent(event, span: .ThisEvent)
                                    
                                    
                                } catch {
                                    
                                    print("failed")
                                }
                                
                                
                            }
                        }
                    })
                    
                } else {
                    
                    print("no")
                }
            })
            
        } else if EKEventStore.authorizationStatusForEntityType(.Event) == EKAuthorizationStatus.Authorized {
            
            
            let userLocation = CLLocation(latitude: self.jobGeoPoint.latitude, longitude: self.jobGeoPoint.longitude)
            let geoCoder = CLGeocoder()
            
            geoCoder.reverseGeocodeLocation(userLocation, completionHandler: { (placeMarks: [CLPlacemark]?, error) -> Void in
                
                if (placeMarks != nil) {
                    
                    if placeMarks!.count >= 0 {
                        
                        let placeMark = placeMarks![0]
                        
                        let event = EKEvent(eventStore: eventStore)
                        
                        event.title = self.jobDescription
                        event.startDate = startDate
                        event.endDate = startDate.dateByAddingTimeInterval(2000)
                        event.calendar = eventStore.defaultCalendarForNewEvents
                        
                        event.structuredLocation = EKStructuredLocation(mapItem: MKMapItem(placemark: MKPlacemark(placemark: placeMark)))
                        
                        do {
                            
                            print("try")
                            try eventStore.saveEvent(event, span: .ThisEvent)
                            
                            
                        } catch {
                            
                            print("failed")
                        }
                        
                        
                    }
                }
            })
            
        }
        
        
    }
    
    
    func payPalPaymentDidCancel(paymentViewController: PayPalPaymentViewController) {
        print("PayPal Payment Cancelled")
        resultText = ""
        //        successView.hidden = true
        paymentViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func payPalPaymentViewController(paymentViewController: PayPalPaymentViewController, didCompletePayment completedPayment: PayPalPayment) {
        print("PayPal Payment Success !")
        paymentViewController.dismissViewControllerAnimated(true, completion: { () -> Void in
            // send completed confirmaion to your server
            print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
            
            self.resultText = completedPayment.description
            
            // todo send payment to backend
            
        })
    }

}
