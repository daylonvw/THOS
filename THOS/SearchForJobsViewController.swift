//
//  SearchForJobsViewController.swift
//  Jobie
//
//  Created by daylonvanwel on 05-02-16.
//  Copyright © 2016 daylon wel. All rights reserved.
//

import UIKit

class jobCell: UITableViewCell {
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var jobDescriptionLabel: UILabel!
    @IBOutlet var jobPriceLabel: UILabel!
    
}

class SearchForJobsViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
// IBOutlets
    
    @IBOutlet var tableView: UITableView!
    
    var jobsArray = [PFObject]()
    
    var questionLabel: UILabel!
    var outdoorHeroButton: UIButton!
    var indoorHeroButton: UIButton!
    var centerX: CGFloat!
    var centerY: CGFloat!
    
    var carpenterButton: UIButton!
    var electricianButton: UIButton!
    var tutorButton: UIButton!
    
    var gardenerButton: UIButton!
    var jobsAroundTheHouseButton: UIButton!
    var deliveryButton: UIButton!
    
    var backButton: UIButton!
    
    var jobTypeNumber: Int!
    var jobSubTypeNumber: Int!

    override func viewDidLoad() {
       
        super.viewDidLoad()
        // setup default design
        
        centerX = view.center.x
        centerY = view.center.y
        
//        NSNotificationCenter.defaultCenter().addObserverForName("openedWitdPushFromJobPoster", object: nil, queue: nil) { (notification: NSNotification) -> Void in
//            
//            self.openChatFromNotification(notification)
//        }
//
//        NSNotificationCenter.defaultCenter().addObserverForName("userAppliedToJob", object: nil, queue: nil) { (notification: NSNotification) -> Void in
//        
//                    self.openChatFromNotification(notification)
//        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(true)
        
        tableView.hidden = true
        
        self.checkForMewChats()
        
        self.tableView.hidden = true
        self.jobsArray.removeAll(keepCapacity: true)
        self.showJobOptions()

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func showJobOptions() {
        
        questionLabel = UILabel(frame: CGRect(x: 10, y: 70, width: view.frame.size.width - 20, height: 60))
        questionLabel.textColor = UIColor.ThosColor()
        questionLabel.text = "Naar wat voor klus ben je op zoek?"
        questionLabel.numberOfLines = 2
        questionLabel.adjustsFontSizeToFitWidth = true
        questionLabel.textAlignment = .Center
        questionLabel.font = UIFont.systemFontOfSize(16, weight: UIFontWeightMedium)
        
        outdoorHeroButton = UIButton(frame: CGRect(x: 20, y: centerY - 30, width: view.frame.size.width - 40, height: 50))
        outdoorHeroButton.backgroundColor = UIColor.ThosColor()
        outdoorHeroButton.setTitle("Klussen buiten het huis", forState: .Normal)
        outdoorHeroButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        outdoorHeroButton.addTarget(self, action: #selector(self.jobTypeButtonPressed(_:)), forControlEvents: .TouchUpInside)
        outdoorHeroButton.tag = 0
        
        indoorHeroButton = UIButton(frame: CGRect(x: 20, y: centerY + 25, width: view.frame.size.width - 40, height: 50))
        indoorHeroButton.backgroundColor = UIColor.ThosColor()
        indoorHeroButton.setTitle("Klussen binnen het huis", forState: .Normal)
        indoorHeroButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        indoorHeroButton.addTarget(self, action: #selector(self.jobTypeButtonPressed(_:)), forControlEvents: .TouchUpInside)
        indoorHeroButton.tag = 1

        backButton = UIButton(frame: CGRect(x: 10, y: view.frame.size.height - 100, width: 60, height: 60))
        backButton.setTitle("Annuleer", forState: .Normal)
        backButton.setTitleColor(UIColor.ThosColor(), forState: .Normal)
        backButton.addTarget(self, action: #selector(self.backButtonPressed(_:)), forControlEvents: .TouchUpInside)
        backButton.titleLabel?.adjustsFontSizeToFitWidth = true
        backButton.hidden = true

        view.addSubview(questionLabel)
        view.addSubview(outdoorHeroButton)
        view.addSubview(indoorHeroButton)
        view.addSubview(backButton)
        
    }

    func jobTypeButtonPressed(sender: UIButton)  {
        
        UIView.animateWithDuration(0.2, animations: {
            
            self.outdoorHeroButton.transform = CGAffineTransformMakeTranslation(-400, 0.1)
            self.indoorHeroButton.transform = CGAffineTransformMakeTranslation(-400, 0.1)
            
        }) { (Bool) in
            
            self.outdoorHeroButton.removeFromSuperview()
            self.indoorHeroButton.removeFromSuperview()
            
            if sender.tag == 0 {
                
                self.showOutdoorSubTypesOptions()
                
            } else if sender.tag == 1 {
                
                self.showIndoorSubTypesOptions()
            }
            
            self.jobTypeNumber = sender.tag
            self.backButton.hidden = false
            
        }
        
        
    }

    
    func showOutdoorSubTypesOptions() {
        
        questionLabel.text = "Wat voor klus rondom het huis wil je doen?"
        
        gardenerButton = UIButton(frame: CGRect(x: 20, y: centerY - 80, width: view.frame.size.width - 40, height: 50))
        gardenerButton.backgroundColor = UIColor.ThosColor()
        gardenerButton.setTitle("Hovenier", forState: .Normal)
        gardenerButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        gardenerButton.addTarget(self, action: #selector(self.subTypeButtonPressed(_:)), forControlEvents: .TouchUpInside)
        gardenerButton.tag = 0
        gardenerButton.transform = CGAffineTransformMakeTranslation(+400, 0.1)
        
        jobsAroundTheHouseButton = UIButton(frame: CGRect(x: 20, y: centerY - 25, width: view.frame.size.width - 40, height: 50))
        jobsAroundTheHouseButton.backgroundColor = UIColor.ThosColor()
        jobsAroundTheHouseButton.setTitle("Klussen aan het huis", forState: .Normal)
        jobsAroundTheHouseButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        jobsAroundTheHouseButton.addTarget(self, action: #selector(self.subTypeButtonPressed(_:)), forControlEvents: .TouchUpInside)
        jobsAroundTheHouseButton.tag = 1
        jobsAroundTheHouseButton.transform = CGAffineTransformMakeTranslation(+400, 0.1)
        
        deliveryButton = UIButton(frame: CGRect(x: 20, y: centerY + 30, width: view.frame.size.width - 40, height: 50))
        deliveryButton.backgroundColor = UIColor.ThosColor()
        deliveryButton.setTitle("Ophaal/bezorg diensten", forState: .Normal)
        deliveryButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        deliveryButton.addTarget(self, action: #selector(self.subTypeButtonPressed(_:)), forControlEvents: .TouchUpInside)
        deliveryButton.tag = 2
        deliveryButton.transform = CGAffineTransformMakeTranslation(+400, 0.1)
        
        view.addSubview(gardenerButton)
        view.addSubview(jobsAroundTheHouseButton)
        view.addSubview(deliveryButton)
        
        UIView.animateWithDuration(0.2, animations: {
            
            self.gardenerButton.transform = CGAffineTransformIdentity
            self.jobsAroundTheHouseButton.transform = CGAffineTransformIdentity
            self.deliveryButton.transform = CGAffineTransformIdentity
            
        })
        
        
    }
    
    func showIndoorSubTypesOptions()  {
        
        questionLabel.text = "Wat voor klus in huis wil je doen?"
        
        carpenterButton = UIButton(frame: CGRect(x: 20, y: centerY - 80, width: view.frame.size.width - 40, height: 50))
        carpenterButton.backgroundColor = UIColor.ThosColor()
        carpenterButton.setTitle("Klusjes man", forState: .Normal)
        carpenterButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        carpenterButton.addTarget(self, action: #selector(self.subTypeButtonPressed(_:)), forControlEvents: .TouchUpInside)
        carpenterButton.tag = 0
        carpenterButton.transform = CGAffineTransformMakeTranslation(+400, 0.1)
        
        electricianButton = UIButton(frame: CGRect(x: 20, y: centerY - 25, width: view.frame.size.width - 40, height: 50))
        electricianButton.backgroundColor = UIColor.ThosColor()
        electricianButton.setTitle("Elektricien", forState: .Normal)
        electricianButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        electricianButton.addTarget(self, action: #selector(self.subTypeButtonPressed(_:)), forControlEvents: .TouchUpInside)
        electricianButton.tag = 1
        electricianButton.transform = CGAffineTransformMakeTranslation(+400, 0.1)
        
        tutorButton = UIButton(frame: CGRect(x: 20, y: centerY + 30, width: view.frame.size.width - 40, height: 50))
        tutorButton.backgroundColor = UIColor.ThosColor()
        tutorButton.setTitle("Bijles", forState: .Normal)
        tutorButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        tutorButton.addTarget(self, action: #selector(self.subTypeButtonPressed(_:)), forControlEvents: .TouchUpInside)
        tutorButton.tag = 2
        tutorButton.transform = CGAffineTransformMakeTranslation(+400, 0.1)
        
        view.addSubview(carpenterButton)
        view.addSubview(electricianButton)
        view.addSubview(tutorButton)
        
        UIView.animateWithDuration(0.2, animations: {
            
            self.carpenterButton.transform = CGAffineTransformIdentity
            self.electricianButton.transform = CGAffineTransformIdentity
            self.tutorButton.transform = CGAffineTransformIdentity
            
        })
        
    }
    
    func subTypeButtonPressed(sender: UIButton)  {
        
        jobSubTypeNumber = sender.tag
        
        self.getJobs()
        
    }
    
    func backButtonPressed(sender: UIButton)  {
        
        
        for subView in view.subviews {
            
            subView.removeFromSuperview()
        }
        
        self.showJobOptions()
        
        
    }
    
    func getJobs() {
        
        print(jobTypeNumber)
        print(jobSubTypeNumber)
        
        let querie = PFQuery(className: "Job")
        querie.includeKey("user")
//        querie.whereKey("user", notEqualTo: PFUser.currentUser()!)
        querie.whereKey("open", equalTo: true)
        querie.whereKey("finished", equalTo: false)
        querie.whereKey("jobTypeNumber", equalTo: self.jobTypeNumber)
        querie.whereKey("jobSubTypeNumber", equalTo: self.jobSubTypeNumber)
        
        if PFUser.currentUser()!["jobsAppliedToArray"] != nil {
            
            querie.whereKey("objectId", notContainedIn: PFUser.currentUser()!["jobsAppliedToArray"] as! [AnyObject])

        }
        
    
        
        querie.findObjectsInBackgroundWithBlock { (jobs, error ) -> Void in
            
            if error != nil {
                
                print(error?.localizedDescription)
                
            } else {
                
                if ((jobs?.count) != nil) {
                    
                    if self.questionLabel != nil {
                        
                        self.questionLabel.removeFromSuperview()
                    }
                    
                    for subView in self.view.subviews {
                        
                        if subView.isKindOfClass(UIButton) {
                            
                            subView.removeFromSuperview()
                        }
                    }
                    
                    for job in jobs! {
                        
                        self.jobsArray.append(job)
                        
                        self.tableView.hidden = false
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
       
        return jobsArray.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! jobCell
        
        let job = self.jobsArray[indexPath.row]
        
        cell.jobDescriptionLabel.text = job["jobDescription"] as? String
        cell.jobPriceLabel.text = "€ \(job["price"])"
        
        let user = job["user"] as! PFUser
        
        let userImagefile = user["userImgage"] as! PFFile
        userImagefile.getDataInBackgroundWithBlock { (data, error) -> Void in
        
            cell.userImageView.image = UIImage(data: data!)
        
        }
        
        cell.userImageView.layer.masksToBounds = true
        cell.userImageView.layer.cornerRadius = 35
        
        return cell

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier("searchToDetailSegue", sender: indexPath)
    }
   
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let indexPath = sender as! NSIndexPath
        if segue.destinationViewController.isKindOfClass(JobDetailViewController) {
            
            let destinationViewController = segue.destinationViewController as! JobDetailViewController
            destinationViewController.job = jobsArray[indexPath.row]
        }
        
    }
    
    // searchbar delegates
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchBar.backgroundColor = UIColor.whiteColor()
        // show all annotations
        if searchBar.text! == "" {
            
  
            
        } else {
        

        }
        
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
        searchBar.backgroundColor = UIColor.whiteColor()
    
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.backgroundColor = UIColor.clearColor()

    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
     
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.backgroundColor = UIColor.clearColor()
        
    }
    

    @IBAction func resetSearchButtonPressed(sender: AnyObject) {
        
        self.tableView.hidden = true
        self.jobsArray.removeAll(keepCapacity: true)
        self.showJobOptions()
        questionLabel.removeFromSuperview()
    }
    
    func checkForMewChats() {
        
//        let tabBarController = self.parentViewController as! JobSeekerTabbarController
//        tabBarController.checkForMewChats()
        
    }

    func openChatFromNotification(notification: NSNotification) {
        
//        let query = PFQuery(className: "Job")
//        query.whereKey("objectId", equalTo: notification.object as! String)
//        query.getFirstObjectInBackgroundWithBlock { (object, error) in
//            if error != nil {
//                
//                print(error)
//                
//            } else {
//                                
//                let storyBoard  = UIStoryboard(name: "Main", bundle: nil)
//                
//                let chatController = storyBoard.instantiateViewControllerWithIdentifier("appliedJobsViewcontroller") as! MyAppliedJobsChatViewController
//                
//                chatController.jobId = object!.objectId
//                chatController.jobGeoPoint = object!.valueForKey("jobLocation") as! PFGeoPoint
//                chatController.jobDescription = object!.valueForKey("jobDescription") as! String
//                chatController.job = object!
//                
//                
//                self.presentViewController(chatController, animated: true, completion: nil)
//                
//            }
//        }
    }

}
