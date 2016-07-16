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
    
    @IBOutlet var descriptionTV: UITextView!
    @IBOutlet var acceptedDateLbel: UILabel!
    @IBOutlet var GoToChatButton: UIButton!
    
    
    var jobInfoTuppleArray = [(user: PFUser,image: UIImage, job: PFObject)]()
    
}

class MyPostedJobsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FloatRatingViewDelegate, SFDraggableDialogViewDelegate {

    //todo reload when returning from chat
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var statusSegmentedControl: UISegmentedControl!
    
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
    
    var refreshContol: UIRefreshControl!
    
    var segmentedControl: HMSegmentedControl!
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        refreshContol = UIRefreshControl()
        refreshContol.addTarget(self, action: #selector(MyPostedJobsViewController.refreshPulled), forControlEvents: .ValueChanged)
        self.tableView.addSubview(refreshContol)
        
        segmentedControl  = HMSegmentedControl(sectionTitles: ["Held", "Nog", "Ik"])
        segmentedControl.frame = CGRectMake(0, 20, view.frame.width, 50)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = UIColor.whiteColor()
        segmentedControl.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        segmentedControl.selectedTitleTextAttributes = [NSForegroundColorAttributeName: UIColor.ThosColor()]
        segmentedControl.selectionIndicatorColor = UIColor.ThosColor()
        segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox
        segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown
    
        segmentedControl.addTarget(self, action: #selector(self.statusChanged(_:)), forControlEvents: .ValueChanged)
        self.view.addSubview(segmentedControl)
    
        self.getMyPlannedJobs()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(true)
        NSNotificationCenter.defaultCenter().postNotificationName("chechForNewChats", object: nil)

    }
    
    func refreshPulled () {

        self.refreshContol.beginRefreshing()
        
        if myPostedJobsArray.count > 0 {
            
            myPostedJobsArray.removeAll(keepCapacity: true)
            self.tableView.reloadData()
        }
        
        if self.statusSegmentedControl.selectedSegmentIndex == 0 {
            
            self.getMyPlannedJobs()
            
        } else if self.statusSegmentedControl.selectedSegmentIndex == 1 {
            
            self.getMyOpenWithInterestedUsersJobs()
            
        } else if self.statusSegmentedControl.selectedSegmentIndex == 2 {
            
            self.getMyOpenWithoutInterestedUsersJobs()

        }


    }
    
    func statusChanged(sender: HMSegmentedControl) {
        print(sender.selectedSegmentIndex)
        if myPostedJobsArray.count > 0 {
            
            myPostedJobsArray.removeAll(keepCapacity: true)
            self.tableView.reloadData()
        }
        
        if sender.selectedSegmentIndex == 0 {
            
            self.getMyPlannedJobs()
            
        } else if sender.selectedSegmentIndex == 1 {
            
            self.getMyOpenWithInterestedUsersJobs()
            
        } else if sender.selectedSegmentIndex == 2 {
            
            self.getMyOpenWithoutInterestedUsersJobs()
        }

    }
    
    func getMyPlannedJobs() {
        
        let querie = PFQuery(className: "Job")
        querie.whereKey("user", equalTo: PFUser.currentUser()!)
        querie.whereKey("open", equalTo: false)
        querie.includeKey("acceptedUser")
        querie.findObjectsInBackgroundWithBlock { (jobs, error ) -> Void in
            
            if error != nil {
                
                print(error?.localizedDescription)
                
            } else {
                
                if ((jobs?.count) != nil) {
                    
                    for job in jobs! {
                        
                        if job["posterReadLastText"] as! Bool == false && self.myPostedJobsArray.count != 0 {
                        
                            self.myPostedJobsArray.insert(job, atIndex: 0)
                            self.tableView.reloadData()
                            self.refreshContol.endRefreshing()
                            
                        } else {
                        
                            self.myPostedJobsArray.append(job)
                            self.tableView.reloadData()
                            self.refreshContol.endRefreshing()
                        }
                    }
                    
                }
            }
            
        }

    }
    
    func getMyOpenWithInterestedUsersJobs() {
        
        let querie = PFQuery(className: "Job")
        querie.whereKey("user", equalTo: PFUser.currentUser()!)
        querie.whereKey("open", equalTo: true)
        querie.includeKey("acceptedUser")
        querie.findObjectsInBackgroundWithBlock { (jobs, error ) -> Void in
            
            if error != nil {
                
                print(error?.localizedDescription)
                
            } else {
                
                if ((jobs?.count) != nil) {
                    
                    for job in jobs! {
                        
                        if job["interestedUsersArray"] != nil {
                            
                            if job["posterReadLastText"] as! Bool == false && self.myPostedJobsArray.count != 0 {
                            
                                self.myPostedJobsArray.insert(job, atIndex: 0)
                                self.tableView.reloadData()
                                self.refreshContol.endRefreshing()
                            
                            } else {
                            
                                self.myPostedJobsArray.append(job)
                                self.tableView.reloadData()
                                self.refreshContol.endRefreshing()
                            }
                        }
                    }
                    
                } 
            }
            
        }

    }

    func getMyOpenWithoutInterestedUsersJobs() {
        
        let querie = PFQuery(className: "Job")
        querie.whereKey("user", equalTo: PFUser.currentUser()!)
        querie.whereKey("open", equalTo: true)
        querie.includeKey("acceptedUser")
        querie.findObjectsInBackgroundWithBlock { (jobs, error ) -> Void in
            
            if error != nil {
                
                print(error?.localizedDescription)
                
            } else {
                                
                if ((jobs?.count) != nil) {
                    
                    for job in jobs! {
                        
                        if job["interestedUsersArray"] == nil {
                            
                            if job["posterReadLastText"] as! Bool == false && self.myPostedJobsArray.count != 0 {
                                
                                self.myPostedJobsArray.insert(job, atIndex: 0)
                                self.tableView.reloadData()
                                self.refreshContol.endRefreshing()
                                
                            } else {
                                
                                self.myPostedJobsArray.append(job)
                                self.tableView.reloadData()
                                self.refreshContol.endRefreshing()
                            }
                        }
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
        
        let object  = self.myPostedJobsArray[indexPath.row]
        
        if object["posterReadLastText"] as! Bool == false {
            
            let pulseAnimation = CABasicAnimation(keyPath: "opacity")
            pulseAnimation.duration = 0.5
            pulseAnimation.fromValue = 0
            pulseAnimation.toValue = 1
            pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            pulseAnimation.autoreverses = true
            pulseAnimation.repeatCount = FLT_MAX
            cell.GoToChatButton.layer.addAnimation(pulseAnimation, forKey: nil)
            
        } else if object["posterReadLastText"] as! Bool == true {
            
            
        }

        if object["open"] as! Bool == false {
            
            cell.GoToChatButton.hidden = false
            
            cell.GoToChatButton.addTarget(self, action: #selector(MyPostedJobsViewController.chatButtonPressed(_:)), forControlEvents: .TouchUpInside)
            
        } else if object["open"] as! Bool == true {
            
            cell.GoToChatButton.hidden = true
            

        }
        
        let description = object["jobDescription"] as! String
        let price = object["price"] as! NSNumber
        let text = "\(description) €\(price)"

        cell.descriptionTV.attributedText = getColoredText(text)
        cell.descriptionTV.font = UIFont.systemFontOfSize(18, weight: UIFontWeightLight)
        
        if object["acceptedDate"] == nil {
            
            cell.acceptedDateLbel.text = ""
            
        } else if object["acceptedDate"] != nil {
            
            let formatter = NSDateFormatter()
            formatter.dateStyle = .MediumStyle
            let dateString = formatter.stringFromDate(object["acceptedDate"] as! NSDate)
            
            cell.acceptedDateLbel.text = "De Held komt op \(dateString)"
            
        }
       
        return cell
        
    }
    
    func chatButtonPressed(sender: UIButton) {

        let jobCell = sender.superview?.superview as! MyPostedJobsCell
        
        let indexPath = self.tableView.indexPathForCell(jobCell)
        
        let jobObject: String = myPostedJobsArray[(indexPath?.row)!].objectId!
       
        self.location = myPostedJobsArray[(indexPath?.row)!]["jobLocation"] as! PFGeoPoint
        
        self.jobDescription = myPostedJobsArray[(indexPath?.row)!]["jobDescription"] as! String

        self.jobForChat = self.myPostedJobsArray[(indexPath?.row)!]
        self.jobIDForSegue = jobObject
        
        jobCell.backgroundColor = UIColor.whiteColor()
        self.tableView.reloadData()

        goToChatVC()
        
        
    }
    
    func goToChatVC(){
        
        self.performSegueWithIdentifier("myPostedJobsToChatSegue", sender: self)

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
    
    
    func getColoredText(text: String) -> NSMutableAttributedString {
       
        let string:NSMutableAttributedString = NSMutableAttributedString(string: text)
        let words:[String] = text.componentsSeparatedByString(" ")
        
        for word in words {
         
            if (word.hasPrefix("€")) {
                
                string.beginEditing()
                let range:NSRange = (string.string as NSString).rangeOfString(word)
                string.addAttribute(NSForegroundColorAttributeName, value: UIColor.ThosColor(), range: range)
                
                string.endEditing()
            }
        }
        return string
    }

}
