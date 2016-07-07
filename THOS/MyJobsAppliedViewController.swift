//
//  MyJobsAppliedViewController.swift
//  THOS
//
//  Created by daylonvanwel on 09-02-16.
//  Copyright © 2016 daylon wel. All rights reserved.
//

import UIKit
import EventKit

class MyAppliedJobsCell: UITableViewCell {
    
    @IBOutlet var jobImageView: UIImageView!
    @IBOutlet var descriptionTV: UITextView!
    @IBOutlet var goToChatButton: UIButton!
    @IBOutlet var acceptedDateLabel: UILabel!
    @IBOutlet var addToCalenderButton: UIButton!
    
}

class MyJobsAppliedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var statusSegmentedControl: UISegmentedControl!
    
    var myAppliedJobsArray = [PFObject]()
    var jobIDForSegue: String!
    var location: PFGeoPoint!
    var jobDescription: String!
    
    var jobForChat: PFObject!

    var refreshContol: UIRefreshControl!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        refreshContol = UIRefreshControl()
        refreshContol.addTarget(self, action: #selector(MyJobsAppliedViewController.refreshPulled), forControlEvents: .ValueChanged)
        self.tableView.addSubview(refreshContol)
        
        self.getMyPlannedJobs()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)

        
    }

    func getMyPlannedJobs() {
        
        let querie = PFQuery(className: "Job")
        querie.whereKey("acceptedUser", equalTo: PFUser.currentUser()!)
        querie.findObjectsInBackgroundWithBlock { (jobs, error ) -> Void in
            
            if error != nil {
                
                print(error?.localizedDescription)
                
            } else {
                
                if ((jobs?.count) != nil) {
                    
                    for job in jobs! {
                        
                        if job["helperReadLastText"] as! Bool == false && self.myAppliedJobsArray.count != 0 {
                            
                            self.myAppliedJobsArray.insert(job, atIndex: 0)
                            self.tableView.reloadData()
                            self.refreshContol.endRefreshing()
                            
                        } else {
                            
                            self.myAppliedJobsArray.append(job)
                            self.tableView.reloadData()
                            self.refreshContol.endRefreshing()
                        }

                    }
                }
            }
            
        }

    }
    
    func getMyAppliedJobs() {
        
        //todo check if item still exists if not remove from array
        
        let appliedJobsArray = PFUser.currentUser()!.valueForKey("jobsAppliedToArray") as! [String]
        
        for job in appliedJobsArray {
    
            let querie = PFQuery(className: "Job")
            querie.whereKey("objectId", equalTo: job)
            querie.whereKey("acceptedUser", notEqualTo: PFUser.currentUser()!)

            querie.getFirstObjectInBackgroundWithBlock({ (job, error) in
                
                if error != nil {
                    
                    print(error?.localizedDescription)
                    
                } else {
                  
                    if job!["acceptedUser"] == nil {
                        
                        if  self.myAppliedJobsArray.count != 0 {
                        
                            self.myAppliedJobsArray.insert(job!, atIndex: 0)
                            self.tableView.reloadData()
                            self.refreshContol.endRefreshing()
                            
                        } else {
                            
                            self.myAppliedJobsArray.append(job!)
                            self.tableView.reloadData()
                            self.refreshContol.endRefreshing()
                        }
                    }
                }
                
            })

        }
    }
    
    func refreshPulled () {
        
        self.refreshContol.beginRefreshing()
        
        if myAppliedJobsArray.count > 0 {
            
            myAppliedJobsArray.removeAll(keepCapacity: true)
            self.tableView.reloadData()

        }

        if self.statusSegmentedControl.selectedSegmentIndex == 0 {
            
            self.getMyPlannedJobs()
            
        } else if self.statusSegmentedControl.selectedSegmentIndex == 1 {
            
            self.getMyAppliedJobs()
        
        }

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return myAppliedJobsArray.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! MyAppliedJobsCell
        
        let object  = self.myAppliedJobsArray[indexPath.row]
      
        if object["helperReadLastText"] != nil {
        
            if object["helperReadLastText"] as! Bool == false {
            
                let pulseAnimation = CABasicAnimation(keyPath: "opacity")
                pulseAnimation.duration = 0.5
                pulseAnimation.fromValue = 0
                pulseAnimation.toValue = 1
                pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                pulseAnimation.autoreverses = true
                pulseAnimation.repeatCount = FLT_MAX
                cell.goToChatButton.layer.addAnimation(pulseAnimation, forKey: nil)

            } else if object["helperReadLastText"] as! Bool == true {
            
            
            }
        }
        
        cell.goToChatButton.addTarget(self, action: #selector(MyJobsAppliedViewController.chatButtonPressed(_:)), forControlEvents: .TouchUpInside)
        cell.addToCalenderButton.addTarget(self, action: #selector(MyJobsAppliedViewController.addToCalenderButtonPressed(_:)), forControlEvents: .TouchUpInside)
        
        let image = cell.addToCalenderButton.imageView?.image?.jsq_imageMaskedWithColor(UIColor.ThosColor())
        cell.addToCalenderButton.setImage(image, forState: .Normal)
       
        
        let description = object["jobDescription"] as! String
        let price = object["price"] as! NSNumber
        let text = "\(description) €\(price)"
        
        cell.descriptionTV.attributedText = getColoredText(text)
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
            cell.acceptedDateLabel.text = ""
            
        } else if object["acceptedDate"] != nil {
            
            cell.addToCalenderButton.hidden = false
            let formatter = NSDateFormatter()
            formatter.dateStyle = .MediumStyle
            formatter.timeStyle = .ShortStyle
            let dateString = formatter.stringFromDate(object["acceptedDate"] as! NSDate)
            
            cell.acceptedDateLabel.text = dateString
            
        }
        
        if self.statusSegmentedControl.selectedSegmentIndex == 1 {
            
            cell.goToChatButton.hidden =  true
            
        } else if self.statusSegmentedControl.selectedSegmentIndex == 0 {
            
            cell.goToChatButton.hidden = false
        }
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let object  = self.myAppliedJobsArray[indexPath.row]

        if object["jobImage"] != nil {
            
            return 320
            
        } else {
            
            return 160
        }
    }

    func chatButtonPressed(sender: UIButton) {
        
        let jobCell = sender.superview?.superview as! MyAppliedJobsCell
        
        let indexPath = self.tableView.indexPathForCell(jobCell)
        
        let jobObject = myAppliedJobsArray[(indexPath?.row)!].objectId
        
      
        self.jobForChat = self.myAppliedJobsArray[(indexPath?.row)!]

        self.jobIDForSegue = jobObject
        
        self.location = myAppliedJobsArray[(indexPath?.row)!]["jobLocation"] as! PFGeoPoint
        
        self.jobDescription = myAppliedJobsArray[(indexPath?.row)!]["jobDescription"] as! String
        
        jobCell.backgroundColor = UIColor.whiteColor()
        self.tableView.reloadData()

        goToChatVC()
        
        
    }
    
    func goToChatVC(){
        
        self.performSegueWithIdentifier("myAppiedJobsToChatSegue", sender: self)
        
    }
    
    func addToCalenderButtonPressed(sender: UIButton) {
        
//        
//        let jobCell = sender.superview?.superview as! MyAppliedJobsCell
//        jobCell.backgroundColor = UIColor.whiteColor()
//        let indexPath = self.tableView.indexPathForCell(jobCell)
//        
//        let jobObject = myAppliedJobsArray[(indexPath?.row)!]
//
//        let jobDate = jobObject["acceptedDate"] as! NSDate
//        
//        let controller = UIAlertController(title: "Add appointment to calender?", message: jobObject["jobDescription"] as? String, preferredStyle: .Alert)
//        
//        let AddToCalanderAction = UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
//            
//            self.createEvent(jobObject, title: "job", startDate: jobDate)
//            
//            
//        })
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
//        
//        controller.addAction(AddToCalanderAction)
//        controller.addAction(cancelAction)
//        
//        self.presentViewController(controller, animated: true, completion: nil)

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let controller = segue.destinationViewController as! MyAppliedJobsChatViewController
        controller.jobId = self.jobIDForSegue
        controller.jobGeoPoint = self.location
        controller.jobDescription = self.jobDescription
        controller.job = self.jobForChat
        
        
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

    
    @IBAction func statusSegmentedControlChanged(sender: AnyObject) {
        
        if myAppliedJobsArray.count > 0 {
            
            myAppliedJobsArray.removeAll(keepCapacity: true)
            self.tableView.reloadData()

        }
        
        let segmentedControll = sender as! UISegmentedControl
        
        if segmentedControll.selectedSegmentIndex == 0 {
            
            self.getMyPlannedJobs()
            
        } else if segmentedControll.selectedSegmentIndex == 1 {
            
            self.getMyAppliedJobs()
        }
        
    }
    
}
