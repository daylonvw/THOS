//
//  MyAppliedJobsChatViewController.swift
//  THOS
//
//  Created by daylonvanwel on 09-02-16.
//  Copyright © 2016 daylon wel. All rights reserved.
//

import UIKit
import Foundation
import MediaPlayer
import EventKit



class MyAppliedJobsChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        
        NSNotificationCenter.defaultCenter().addObserverForName("messageFromJobPosterRecieved", object: nil, queue: nil) { (notification) -> Void in
            
            print(notification)
            
            self.loadMessages()
        }

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
            query.limit = 50
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                
                if error == nil {
                    
                    self.job["helperReadLastText"] = true
                    self.job.saveInBackground()

                    self.automaticallyScrollsToMostRecentMessage = false
                    
                    for object in Array((objects as [PFObject]!).reverse()) {
                        
                        self.addMessage(object)
                        
                        if object["toUser"] != nil {
                            
                            let toUser = object["toUser"] as! PFUser
                            
                            if PFUser.currentUser()!.objectId == toUser.objectId {
                                
                                object["isRead"] = true
                                object.saveInBackground()
                                
                            } else {
                                
                                // nothing
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
            object["toUser"] = self.job["user"]
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
        
            job["posterReadLastText"] = false
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
        pushQuery!.whereKey("user", equalTo: job["user"])
        let descriptionString = self.job["jobDescription"] as! String
        
        let dataDIC:[String: AnyObject] = [
            
            "alert"             : "New message about your job: \(descriptionString)",
            "type"              : "jobHelperMessage",
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
        dateButton.addTarget(self, action: #selector(MyAppliedJobsChatViewController.sendjobDate), forControlEvents: .TouchUpInside)
        dateButton.center = CGPointMake(view.center.x, view.frame.size.height - 120)
        dateButton.setTitle("OK", forState: .Normal)
        dateButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        dateButton.backgroundColor = UIColor.ThosColor()
        
        
        dateCancelButton = UIButton(frame: CGRect(x: 10, y: 0, width: view.frame.size.width - 20, height: 50))
        dateCancelButton.addTarget(self, action: #selector(MyAppliedJobsChatViewController.dismissDatePickerView), forControlEvents: .TouchUpInside)
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
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
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
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
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

            cell.textView?.textColor = UIColor.blackColor()
            
            
        } else if message.jobDate == nil {
            
            if message.senderId == self.senderId {
                
                cell.textView?.textColor = UIColor.whiteColor()
                
            } else {
                
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
        
        let message = self.messages[indexPath.item]
        
        if message.senderId != self.senderId {
        
        if message.jobDate != nil {
            
            let controller = UIAlertController(title: "Accept appointment", message: "for job ?", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "No", style: .Default, handler: { (action) -> Void in
                
                // todo send "not accepted to user
            })
            
            let acceptDateAction = UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
                
                self.job["acceptedDate"] = message.jobDate
                self.job["helperAcceptedDate"] = true
                self.job.saveInBackground()
                
                self.inputToolbar?.contentView?.leftBarButtonItem?.hidden = true
                
                self.sendAcceptedDatePush()
            })
            
            let AddToCalanderAction = UIAlertAction(title: "Yes and add to Calender", style: .Default, handler: { (action) -> Void in
                
                self.createEvent(self.eventStore, title: "job", startDate: message.jobDate)
                
                self.job["acceptedDate"] = message.jobDate
                self.job["helperAcceptedDate"] = true
                self.job.saveInBackground()
                
                self.inputToolbar?.contentView?.leftBarButtonItem?.hidden = true
                
                self.sendAcceptedDatePush()
                
            })
            
            
            
            controller.addAction(cancelAction)
            controller.addAction(acceptDateAction)
            controller.addAction(AddToCalanderAction)
            self.presentViewController(controller, animated: true, completion: nil)
            
            
        } else {
            
            print("not a date")
        }
        
        }
    }
    
    func sendAcceptedDatePush() {
        
        let user = job["user"] as! PFUser
        
        let pushQuery = PFInstallation.query()
        pushQuery!.whereKey("user", equalTo: user)
        
        let dataDIC:[String: AnyObject] = [
            
            "alert"             : "User accepted the date for: \(self.job["jobDescription"])",
            "type"              : "HelperDateAccepted",
            "badge"             : "increment",
            "sound"             : "message-sent.aiff"
        ]
        
        let push = PFPush()
        
        push.setQuery(pushQuery)
        push.setData(dataDIC)
        push.sendPushInBackground()
        
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

        dateButton.removeFromSuperview()
        dateImageView.removeFromSuperview()
        datePicker.removeFromSuperview()
        dateCancelButton.removeFromSuperview()
        
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
}


