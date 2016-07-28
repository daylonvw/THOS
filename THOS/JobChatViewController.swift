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

class JobChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
        
//todo disbale change of device orienation
        
        NSNotificationCenter.defaultCenter().addObserverForName("newMessageRecieved", object: nil, queue: nil) { (notification) -> Void in
                        
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
            query.limit = 200
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
               
                if error == nil {
                   
                    self.job["posterReadLastText"] = true
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
            
    }
    
    // MARK: - JSQMessagesViewController method overrides
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
       
        self.sendMessage(text, video: nil, picture: nil, jobDate: nil)
    }
    
    func sendMessgePush(jobId: String, text: String) {
        
        
        let pushQuery = PFInstallation.query()
        
        let acceptedUser = job["acceptedUser"] as! PFUser
        let jobUser      = job["user"] as! PFUser
        
        print(acceptedUser)
        print(jobUser)
        
        if acceptedUser.objectId == PFUser.currentUser()?.objectId {
            
            pushQuery!.whereKey("user", equalTo:jobUser )

            print("job to do")
            
        } else if jobUser.objectId == PFUser.currentUser()!.objectId {
           
            pushQuery!.whereKey("user", equalTo: acceptedUser)

            print("my job")
        }

        
        let dataDIC:[String: AnyObject] = [
            
            "alert"             : text,
            "type"              : "newMessage",
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
       
        if message.senderId == self.senderId {
                
            cell.textView?.textColor = UIColor.whiteColor()
            
        } else if message.senderId != self.senderId {
                
            cell.textView?.textColor = UIColor.blackColor()
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

    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapCellAtIndexPath indexPath: NSIndexPath!, touchLocation: CGPoint) {

    }
    
    
    func backButtonPressed() {
        
        self.dismissViewControllerAnimated(true, completion: nil)
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
