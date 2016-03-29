//
//  MyPostedJobsViewController.swift
//  Jobie
//
//  Created by daylonvanwel on 06-02-16.
//  Copyright © 2016 daylon wel. All rights reserved.
//

import UIKit
import EventKit

class MyPostedJobsCell: UITableViewCell {
    
    @IBOutlet var jobImageView: UIImageView!
    @IBOutlet var descriptionTV: UITextView!
    @IBOutlet var interestedHandyUserView: UIView!
    @IBOutlet var interestedUsersLabel: UILabel!
    @IBOutlet var acceptedDateLbel: UILabel!
    @IBOutlet var addToCalenderButton: UIButton!
    
    @IBOutlet var GoToChatButton: UIButton!
    var jobInfoTuppleArray = [(user: PFUser,image: UIImage, job: PFObject)]()
    
}

class MyPostedJobsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FloatRatingViewDelegate {

    
    @IBOutlet var tableView: UITableView!
    
    var myPostedJobsArray = [PFObject]()
    var userView: userPopUpView!
    var acceptedUser: PFUser!
    var selectedJob: PFObject!
    var jobDescription: String!

    var location: PFGeoPoint!

    var jobIDForSegue: String!
    var jobForChat: PFObject!
    
    var finishUpView = FinishUpView(frame: CGRectZero)
    
    var userToPay: PFUser!
    var newUserRating: NSNumber!
    var ratingToUpdate: PFObject!
    
    var sharedFriendsArray = [String]()
    
    var sharedfriendsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        print("appeared")
        
        if myPostedJobsArray.count > 0 {
            
            myPostedJobsArray.removeAll(keepCapacity: true)
        }
        
        getMyJobs()

    }
    
    func getMyJobs() {
        
        let querie = PFQuery(className: "Job")
        querie.whereKey("user", equalTo: PFUser.currentUser()!)
        querie.includeKey("acceptedUser")
        querie.findObjectsInBackgroundWithBlock { (jobs, error ) -> Void in
            
            if error != nil {
                
                print(error?.localizedDescription)
                
            } else {
                
                if ((jobs?.count) != nil) {
                    
                    for job in jobs! {
                        
                        self.myPostedJobsArray.append(job)
                        self.tableView.reloadData()
                        
                    }
                }
            }
            
        }

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return myPostedJobsArray.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! MyPostedJobsCell
        
        if cell.jobInfoTuppleArray.count > 0 {
            
            cell.jobInfoTuppleArray.removeAll(keepCapacity: true)
            
            for view in cell.interestedHandyUserView.subviews {
                
                view.removeFromSuperview()
            }
        }
        let object  = self.myPostedJobsArray[indexPath.row]

        if object["open"] as! Bool == false {
            
            cell.GoToChatButton.hidden = false
            cell.interestedHandyUserView.hidden = true
            cell.interestedUsersLabel.hidden = true
            
            cell.GoToChatButton.addTarget(self, action: Selector("chatButtonPressed:"), forControlEvents: .TouchUpInside)
            
            cell.addToCalenderButton.addTarget(self, action: Selector("addToCalenderButtonPressed:"), forControlEvents: .TouchUpInside)


            let image = cell.addToCalenderButton.imageView?.image?.jsq_imageMaskedWithColor(UIColor.ThosColor())
            cell.addToCalenderButton.setImage(image, forState: .Normal)
            
        } else if object["open"] as! Bool == true {
            
            cell.GoToChatButton.hidden = true
            
            if object["interestedUsersArray"] != nil {
                
                cell.interestedHandyUserView.hidden = false
                cell.interestedUsersLabel.hidden = false

                var index = 0
                
                let usersIdArray: [String] = object["interestedUsersArray"] as! [String]
                                
                let usersView = UIView(frame: CGRect(x: 0, y: 0, width: Int(usersIdArray.count * 60), height: 60))
                
                usersView.center = CGPointMake(120, 30)
                
                
                let tapGesture = UITapGestureRecognizer(target: self, action: Selector("getUser:"))
                tapGesture.numberOfTapsRequired = 1
                usersView.addGestureRecognizer(tapGesture)
                cell.interestedHandyUserView.addSubview(usersView)
                
                for userId in usersIdArray {
                    
                    let querie = PFUser.query()
                    querie?.whereKey("objectId", equalTo: userId)
                    querie?.getFirstObjectInBackgroundWithBlock({ (user , error ) -> Void in
                        
                        if error != nil {
                            
                            print(error?.localizedDescription)
                            
                        } else {
                            
                            let userImagefile = user!["userImgage"] as! PFFile
                            userImagefile.getDataInBackgroundWithBlock { (data, error) -> Void in
                                
                                if error != nil {
                                    
                                    print(error?.localizedDescription)
                                    
                                } else {
                                    
                                    
                                    let image = UIImage(data: data!)
                                    let user = user as! PFUser
                                    
                                    
                                    if cell.jobInfoTuppleArray.count < usersIdArray.count {
                                        
                                        cell.jobInfoTuppleArray.append((user, image!, object))

                                        let imageView = UIImageView(frame: CGRect(x: index * 60, y: 0, width: 60, height: 60))
                                        imageView.layer.cornerRadius = 30
                                        imageView.clipsToBounds = true
                                        imageView.image = UIImage(data: data!)
                                        imageView.layer.borderColor = UIColor.ThosColor().CGColor
                                        imageView.layer.borderWidth = 2
                                        imageView.contentMode = .ScaleAspectFill
                                        imageView.accessibilityHint = userId
                                    
                                    
                                        usersView.addSubview(imageView)
                                        
                                        index++
                                        
                                    }
                                    
                                }
                            }
                            
                        }
                        
                    })
                    
                }
                
                
                
            } else {
                
                cell.interestedHandyUserView.hidden = true
                cell.interestedUsersLabel.hidden = true

            }


        }
        
        cell.descriptionTV.text = object["jobDescription"] as! String
        cell.descriptionTV.textColor = UIColor.darkGrayColor()
        cell.descriptionTV.font = UIFont.systemFontOfSize(20, weight: UIFontWeightLight)

        if object["jobImage"] != nil {
            
            let file = object["jobImage"] as! PFFile
            file.getDataInBackgroundWithBlock({ (data, error) -> Void in
                
                if error != nil {
                    
                    print(error?.localizedDescription)
                    
                } else {
                    
                    cell.jobImageView.hidden = false
                    cell.jobImageView.clipsToBounds = true
                    cell.jobImageView.image = UIImage(data: data!)
                }
                
            })
            
        } else {
            
            cell.jobImageView.hidden = true
        }
        
        if object["acceptedDate"] == nil {
            
            cell.addToCalenderButton.hidden = true
            cell.acceptedDateLbel.text = ""
            
        } else if object["acceptedDate"] != nil {
            
            cell.addToCalenderButton.hidden = false
            let formatter = NSDateFormatter()
            formatter.dateStyle = .MediumStyle
            formatter.timeStyle = .ShortStyle
            let dateString = formatter.stringFromDate(object["acceptedDate"] as! NSDate)
            
            cell.acceptedDateLbel.text = dateString
            
        }
       
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let object  = self.myPostedJobsArray[indexPath.row]
        
        
        if object["interestedUsersArray"] != nil {
            
            if object["jobImage"] != nil {
                
                return 380
                
            } else {
                
                return 220
            }
            
        } else {
            
            
            if object["jobImage"] != nil {
                
                return 260
                
            } else {
                
                return 100
            }
        }
        
    }
    
    func getUser(sender: UITapGestureRecognizer) {
        
        
        let jobCell = sender.view?.superview?.superview?.superview as! MyPostedJobsCell
        
        let tappedEventInt = Int(sender.locationInView(sender.view).x / 60)
        
        let interestedUserTupple = jobCell.jobInfoTuppleArray[tappedEventInt]
        
        showUserViewWithUser(interestedUserTupple)
        
    }


    func showUserViewWithUser(jobInfo: (PFUser, UIImage, PFObject)) {
        
        self.tableView.scrollEnabled = false
        
        
        userView = userPopUpView(frame: self.view.frame)
        
        userView.ratingView.hidden = true
        userView.acceptButton.frame = CGRectMake(0, 0, self.view.frame.size.width - 20, 40)
        userView.acceptButton.center = CGPointMake(self.view.center.x, self.view.frame.height - 110)
        userView.acceptButton.addTarget(self, action: Selector("acceptUserForJob"), forControlEvents: .TouchUpInside)
        
        userView.declineButton.frame = CGRectMake(0, 0, self.view.frame.size.width - 20, 40)
        userView.declineButton.center = CGPointMake(self.view.center.x, self.view.frame.height - 60)

        userView.declineButton.addTarget(self, action: Selector("dismissUserView"), forControlEvents: .TouchUpInside)
      
        
        let query = PFQuery(className: "UserRating")
        query.whereKey("user", equalTo: jobInfo.0)
        query.getFirstObjectInBackgroundWithBlock({ (object , error ) -> Void in
            
            if error != nil {
                
                print(error?.localizedDescription)
            } else {
                
                self.userView.ratingView.hidden = false
                // todo new class querie for rating
                let rating = object!["rating"] as! NSNumber
                self.userView.ratingView.rating = Float(rating)
                self.userView.ratingView.center = CGPointMake(self.view.center.x, 200)
                self.userView.ratingView.editable = false
                
            }
        })

        if jobInfo.0["friendsArray"] != nil {
            
            let userFriends = jobInfo.0["friendsArray"]
            let myfriends = PFUser.currentUser()!["friendsArray"]
        
            let set1 = NSMutableSet(array: userFriends as! Array)
            let set2 = NSMutableSet(array: myfriends as! Array)
        
            set1.intersectSet(set2 as Set<NSObject>)
        
            let sharedResult = set1.allObjects as NSArray
            
            if sharedResult.count > 0 {
                
                self.sharedfriendsView = UIView(frame: CGRect(x: 0, y: 0, width: Int(self.view.frame.size.width - 40), height: (30 * sharedResult.count) + 30))
                self.sharedfriendsView.center = self.view.center
              
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: Int(self.sharedfriendsView.frame.size.width), height: 30))
                label.text = "Common friends"
                label.textColor = UIColor.darkGrayColor()
                label.textAlignment  = .Center
                label.font = UIFont.systemFontOfSize(20)
                self.sharedfriendsView.addSubview(label)

                
                self.userView.addSubview(self.sharedfriendsView)
                var index = 0
                
                while index < sharedResult.count {
                
                    let user = sharedResult[index]
                
                    self.getSharedFriendsInfoWith(index + 1 , userId: user as! String)
                    index++

                }
            }
        }
        
        userView.userNameLabel.text = jobInfo.0["displayName"] as? String
        
        userView.userimageView.image = jobInfo.1
        userView.userimageView.center = CGPointMake(userView.center.x, 100)
        
        userView.center = CGPointMake(view.center.x, view.center.y - 20)
        self.view.addSubview(userView)
        
        acceptedUser = jobInfo.0
        selectedJob = jobInfo.2

    }
    
    func getSharedFriendsInfoWith(index: Int, userId: String) {
        
        FBSDKGraphRequest.init(graphPath: userId, parameters: ["fields": "name"], HTTPMethod: "GET").startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if error != nil {
                
                print(error.localizedDescription)
                
            } else {
                
                print(index)
                self.sharedFriendsArray.append(result.valueForKey("name") as! String)
                let label = UILabel(frame: CGRect(x: 0, y: index * 30, width: Int(self.sharedfriendsView.frame.size.width), height: 30))
                label.text = result.valueForKey("name") as? String
                label.textColor = UIColor.ThosColor()
                label.textAlignment  = .Center
                label.font = UIFont.systemFontOfSize(16)
                self.sharedfriendsView.addSubview(label)
                
                
            }
            
        })

        
    }
    
    func acceptUserForJob() {
        
        self.selectedJob.setObject(self.acceptedUser, forKey: "acceptedUser")
        self.selectedJob.setObject(false, forKey: "open")
        self.selectedJob.saveInBackgroundWithBlock { (succes, error ) -> Void in
            
            if error != nil {
                
                
            } else {
                
                if succes == true {
                    
                    // todo segue to chat!!
                    self.tableView.scrollEnabled = true

                    self.userView.removeFromSuperview()
                    self.myPostedJobsArray.removeAll()
                    self.getMyJobs()
                    
                    self.sendAcceptedPush(self.acceptedUser!)
                    print("user selected, ready to open chatView")
                }
            }
        }
        
    }
    
    func sendAcceptedPush(user: PFUser) {
        
        let pushQuery = PFInstallation.query()
        pushQuery!.whereKey("user", equalTo: user)
        let descriptionString = self.selectedJob["jobDescription"] as! String
        
        let dataDIC:[String: AnyObject] = [
            
            "alert"             : "New accepted job: \(descriptionString)",
            "type"              : "accepted",
            "badge"             : "increment",
            "sound"             : "message-sent.aiff"
        ]
        
        let push = PFPush()
        
        push.setQuery(pushQuery)
        push.setData(dataDIC)
        push.sendPushInBackground()
    }
    
    
    func dismissUserView() {
        
        userView.removeFromSuperview()
        self.tableView.scrollEnabled = true
        acceptedUser = nil 
    }
    
//    func dropInViewController(viewController: BTDropInViewController, didSucceedWithTokenization paymentMethodNonce: BTPaymentMethodNonce) {
//        
//    }
//    
//    func dropInViewControllerDidCancel(viewController: BTDropInViewController) {
//        
//    }
    
//    func userDidCancelPayment() {
//      
//        dismissViewControllerAnimated(true, completion: nil)
//    }
//    
//    func finishUpButtonPressed(sender: UIButton) {
//    
//        let jobCell = sender.superview?.superview as! MyPostedJobsCell
//        
//        let indexPath = self.tableView.indexPathForCell(jobCell)
//        
//        let jobObject = myPostedJobsArray[(indexPath?.row)!]
//
//        self.userToPay = jobObject["acceptedUser"] as! PFUser
//        let imageFile = self.userToPay["userImgage"] as! PFFile
//        
//        imageFile.getDataInBackgroundWithBlock { (data, error) -> Void in
//            
//            if error != nil {
//                
//                print(error?.localizedDescription)
//                
//            } else {
//                
//                
//                self.finishUpView.frame = CGRectMake(0, -20, self.view.frame.width, self.view.frame.height + 80)
//                self.finishUpView.center = CGPointMake(self.view.center.x, self.view.center.y)
//                
//                self.finishUpView.payButton.frame = CGRectMake(0, 0, self.view.frame.size.width - 20, 40)
//                self.finishUpView.payButton.center = CGPointMake(self.view.center.x, self.view.frame.height - 100)
//                self.finishUpView.payButton.addTarget(self, action: Selector("payButtonPressed"), forControlEvents: .TouchUpInside)
//                
//                self.finishUpView.cancelButton.frame = CGRectMake(0, 0, self.view.frame.size.width - 20, 40)
//                self.finishUpView.cancelButton.center = CGPointMake(self.view.center.x, self.view.frame.height - 50)
//                self.finishUpView.cancelButton.addTarget(self, action: Selector("dismissFinishUpView"), forControlEvents: .TouchUpInside)
//                
//                self.finishUpView.userImageView.center = CGPointMake(self.view.center.x, 140)
//                self.finishUpView.userImageView.image = UIImage(data: data!)
//                
//                let query = PFQuery(className: "UserRating")
//                query.whereKey("user", equalTo: self.userToPay)
//                query.getFirstObjectInBackgroundWithBlock({ (object , error ) -> Void in
//                    
//                    if error != nil {
//                        
//                        print(error?.localizedDescription)
//                    } else {
//                        
//                        self.ratingToUpdate = object
//                        
//                        // todo new class querie for rating
//                        let rating = object!["rating"] as! NSNumber
//                        self.finishUpView.ratingView.rating = Float(rating)
//                        self.finishUpView.ratingView.center = CGPointMake(self.view.center.x, self.view.frame.height - 150)
//                        self.finishUpView.ratingView.delegate = self
//
//                    }
//                })
//                
//                self.finishUpView.textView.frame = CGRectMake(0, 0, self.view.frame.width, 180)
//                self.finishUpView.textView.center = CGPointMake(self.view.center.x, 300)
//                self.finishUpView.textView.text = jobObject["jobDescription"] as! String
//                
//                self.finishUpView.backGroundImageView.frame = CGRectMake(0, -20, self.view.frame.width, self.view.frame.height + 80)
//                let image = self.tableView.convertViewToImage()
//                let blurImage = image.applyLightEffect()
//                self.finishUpView.backGroundImageView.image = blurImage
//                
//                
//                self.view.addSubview(self.finishUpView)
//
//            }
//        }
//
//       
//    }
//    
//    func payButtonPressed() {
//        
//        
//        print(self.ratingToUpdate)
//      
//        if self.newUserRating != nil {
//            
//            let numberOfRatings = Int(self.ratingToUpdate["numberOfRatings"] as! NSNumber!)
//            let rating = Int(self.ratingToUpdate["totalRating"] as! NSNumber) + Int(self.newUserRating)
//            
//            let newRating = rating / numberOfRatings
//            let newNumberOfRatings = numberOfRatings + 1
//            
//            
//            self.ratingToUpdate["totalRating"] = NSNumber(integer: rating)
//            self.ratingToUpdate["rating"] = NSNumber(integer: newRating)
//            self.ratingToUpdate["numberOfRatings"] = NSNumber(integer: newNumberOfRatings)
//            self.ratingToUpdate.saveInBackground()
//            
//            // todo set job["finished"] to true after payment is completed
//            
//            self.finishUpView.removeFromSuperview()
//
//        } else {
//            
//            // todo set new rating as old rating
//            
//            let numberOfRatings = Int(self.ratingToUpdate["numberOfRatings"] as! NSNumber!)
//            let rating = Int(self.ratingToUpdate["totalRating"] as! NSNumber) + 5
//            
//            let newRating = rating / numberOfRatings
//            let newNumberOfRatings = numberOfRatings + 1
//            
//            self.ratingToUpdate["totalRating"] = NSNumber(integer: rating)
//            self.ratingToUpdate["rating"] = NSNumber(integer: newRating)
//            self.ratingToUpdate["numberOfRatings"] = NSNumber(integer: newNumberOfRatings)
//            self.ratingToUpdate.saveInBackground()
//            
//            self.finishUpView.removeFromSuperview()
//            
//            // todo set job["finished"] to true after payment is completed
//            
//
//        }
//        
//    }
//    
//    func dismissFinishUpView() {
//        
//        finishUpView.removeFromSuperview()
//    }
    
    func chatButtonPressed(sender: UIButton) {

        let jobCell = sender.superview?.superview as! MyPostedJobsCell
        
        let indexPath = self.tableView.indexPathForCell(jobCell)
        
        let jobObject: String = myPostedJobsArray[(indexPath?.row)!].objectId!
       
        self.location = myPostedJobsArray[(indexPath?.row)!]["jobLocation"] as! PFGeoPoint
        
        self.jobDescription = myPostedJobsArray[(indexPath?.row)!]["jobDescription"] as! String

        self.jobForChat = self.myPostedJobsArray[(indexPath?.row)!]
        self.jobIDForSegue = jobObject
        
        goToChatVC()
        
        
    }
    
    func goToChatVC(){
        
        self.performSegueWithIdentifier("myPostedJobsToChatSegue", sender: self)

    }
    
    
    func addToCalenderButtonPressed(sender: UIButton) {
        
        
        let jobCell = sender.superview?.superview as! MyPostedJobsCell
        
        let indexPath = self.tableView.indexPathForCell(jobCell)
        
        let jobObject = myPostedJobsArray[(indexPath?.row)!]
        
        let jobDate = jobObject["acceptedDate"] as! NSDate
        
        let controller = UIAlertController(title: "Add appointment to calender?", message: jobObject["jobDescription"] as? String, preferredStyle: .Alert)

        let AddToCalanderAction = UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
            
            self.createEvent(jobObject, title: "job", startDate: jobDate)

            
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        
        controller.addAction(AddToCalanderAction)
        controller.addAction(cancelAction)
        
        self.presentViewController(controller, animated: true, completion: nil)
        
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let controller = segue.destinationViewController as! JobChatViewController
        controller.jobId = self.jobIDForSegue
        controller.jobGeoPoint = self.location
        controller.jobDescription = self.jobDescription
        controller.job = self.jobForChat
    }
    
    func floatRatingView(ratingView: FloatRatingView, isUpdating rating:Float) {
        
        
        
    }
    
    func floatRatingView(ratingView: FloatRatingView, didUpdate rating: Float) {
        
        self.newUserRating = NSNumber(float: rating)
    
    }
    
    func createEvent(job: PFObject, title: String, startDate: NSDate) {
        
        let eventStore = EKEventStore()
        
        let jobLocation =  job["jobLocation"] as! PFGeoPoint
        if EKEventStore.authorizationStatusForEntityType(.Event) != EKAuthorizationStatus.Authorized {
            
            eventStore.requestAccessToEntityType(.Event, completion: { (granted, error ) -> Void in
                
                
                if granted == true {
                    
                    let userLocation = CLLocation(latitude: jobLocation.latitude, longitude: jobLocation.longitude)
                    let geoCoder = CLGeocoder()
                    
                    geoCoder.reverseGeocodeLocation(userLocation, completionHandler: { (placeMarks: [CLPlacemark]?, error) -> Void in
                        
                        if (placeMarks != nil) {
                            
                            if placeMarks!.count >= 0 {
                                
                                let placeMark = placeMarks![0]
                                
                                let event = EKEvent(eventStore: eventStore)
                                
                                event.title = job["jobDescription"] as! String
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
            
            
            let userLocation = CLLocation(latitude: jobLocation.latitude, longitude: jobLocation.longitude)
            let geoCoder = CLGeocoder()
            
            geoCoder.reverseGeocodeLocation(userLocation, completionHandler: { (placeMarks: [CLPlacemark]?, error) -> Void in
                
                if (placeMarks != nil) {
                    
                    if placeMarks!.count >= 0 {
                        
                        let placeMark = placeMarks![0]
                        
                        let event = EKEvent(eventStore: eventStore)
                        
                        event.title = job["jobDescription"] as! String
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
