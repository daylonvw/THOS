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
    
}

class SearchForJobsViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
// IBOutlets
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var jobSearchBar: UISearchBar!
    
    var jobsArray = [PFObject]()
    
    var showCatagories: Bool!
    var catagorieImage: UIImage!
    
    var centerX: CGFloat!
    var centerY: CGFloat!
    
    var jobTypeNumber: Int!
    var jobSubTypeNumber: Int!

    override func viewDidLoad() {
       
        super.viewDidLoad()
        // setup default design
        
        showCatagories = true
        
        
        jobSearchBar.delegate = self
        jobSearchBar.barTintColor  = UIColor.ThosColor()
        let button = jobSearchBar.valueForKey("cancelButton") as! UIButton
        button.setTitle("Annuleer", forState: UIControlState.Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.hidden = true
        
        let subview = jobSearchBar.subviews[0]
        
        for subv in subview.subviews {
            
            if subv.isKindOfClass(UITextField) {
                
                let textF = subv as! UITextField
                textF.backgroundColor = UIColor.ThosColor()
                textF.textColor = UIColor.whiteColor()

                textF.attributedPlaceholder = NSAttributedString(string:"Zoek op trefwoord", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
                textF.textAlignment = .Left
                textF.font = UIFont(name: "OpenSans", size: 26.0)
                textF.adjustsFontSizeToFitWidth = true

                let glassIconView = textF.leftView as? UIImageView
                
                glassIconView!.image = glassIconView!.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                glassIconView!.tintColor = UIColor.whiteColor()
                glassIconView?.transform = CGAffineTransformMakeScale(1.2, 1.2)

                }
        }
        
        
        centerX = view.center.x
        centerY = view.center.y
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.fromColor(UIColor.ThosColor()), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage.fromColor(UIColor.ThosColor())
        // set on previous controller
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
//        self.tableView.contentInset = UIEdgeInsetsMake(-64.0, 0.0, 0.0, 0.0)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.fromColor(UIColor.ThosColor()), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage.fromColor(UIColor.ThosColor())
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(true)
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func getJobs() {
        
        let querie = PFQuery(className: "Job")
        querie.includeKey("user")
        querie.whereKey("user", notEqualTo: PFUser.currentUser()!)
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
                
                if ((jobs?.count) > 0) {
                  
                    self.showCatagories = false
                    
                    for job in jobs! {
                        
                        self.jobsArray.append(job)
                        
                        self.tableView.reloadData()
                        
                    }
                    
                } else {
                    
                    self.showNoJobsAllertcontroller()
                }
            }
            
        }

    }
    
    func getJobsWithText(text: String) {
        
        let querie = PFQuery(className: "Job")
        querie.includeKey("user")
        querie.whereKey("user", notEqualTo: PFUser.currentUser()!)
        querie.whereKey("open", equalTo: true)
        querie.whereKey("finished", equalTo: false)
        querie.whereKey("jobDescription", containsString: text)
        
        if PFUser.currentUser()!["jobsAppliedToArray"] != nil {
            
            querie.whereKey("objectId", notContainedIn: PFUser.currentUser()!["jobsAppliedToArray"] as! [AnyObject])
            
        }
        
        querie.findObjectsInBackgroundWithBlock { (jobs, error ) -> Void in
            
            if error != nil {
                
                print(error?.localizedDescription)
                
            } else {
                
                if ((jobs?.count) > 0) {
                    
                    self.showCatagories = false
                    
                    for job in jobs! {
                        
                        self.jobsArray.append(job)
                        
                        self.tableView.reloadData()
                        
                    }
                    
                } else {
                    
                    self.showNoJobsAllertcontroller()
                }
            }
            
        }

    }
    
    func showNoJobsAllertcontroller() {
        
        let alertcontroller = UIAlertController(title: "Helaas", message: "Er zijn geen opdrachten gevonden, probeer het later nog eens", preferredStyle: .Alert)
        
        let action = UIAlertAction(title: "Oke", style: .Default, handler: nil)
        
        alertcontroller.addAction(action)
        
        self.presentViewController(alertcontroller, animated: true, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
       
        if showCatagories == true {
            
            return 3

        } else {
            
            return 1
        }
        
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if showCatagories == true {
            
            if section == 0 {
                
                return 4
                
            } else if section == 1 {
                
                return 2
                
            } else {
                
                return 1
            }

        } else  {
            
            return jobsArray.count
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! jobCell
        
        cell.userImageView.clipsToBounds = true
       
        if showCatagories == true {
       
            cell.userImageView.image = getJotTypeMedia(indexPath.section, subtype: indexPath.row).0
            cell.jobDescriptionLabel.text = getJotTypeMedia(indexPath.section, subtype: indexPath.row).1
            

        } else if showCatagories == false {
            
            let job = self.jobsArray[indexPath.row]
            
            cell.jobDescriptionLabel.text = job["jobDescription"] as? String
            let jobtype = job["jobTypeNumber"] as! NSNumber
            let jobSubType = job["jobSubTypeNumber"] as! NSNumber
            cell.userImageView.image = getJotTypeMedia(jobtype, subtype: jobSubType).0
            
        }

        
        return cell

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if showCatagories == true {
            
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            
            for view in (cell?.contentView.subviews)! {
                
                if view.isKindOfClass(UIImageView) {
                    
                    let imageView = view as! UIImageView
                    self.catagorieImage = imageView.image
                }
            }
            
            self.jobTypeNumber = indexPath.section
            self.jobSubTypeNumber = indexPath.row
            
            self.getJobs()
            
        } else if showCatagories ==  false {
            
            performSegueWithIdentifier("searchToDetailSegue", sender: indexPath)

        }
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
        
        
        let button = jobSearchBar.valueForKey("cancelButton") as! UIButton
        button.hidden = false
        
        jobsArray.removeAll(keepCapacity: true)
        showCatagories = false
        tableView.reloadData()
    
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        
        getJobsWithText(searchBar.text!)
        
        let button = jobSearchBar.valueForKey("cancelButton") as! UIButton
        button.hidden = true


    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
     
        let button = jobSearchBar.valueForKey("cancelButton") as! UIButton
        button.hidden = true
        
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.backgroundColor = UIColor.clearColor()
        showCatagories = true
        tableView.reloadData()
        
    }
    

    @IBAction func resetSearchButtonPressed(sender: AnyObject) {
        
        jobsArray.removeAll(keepCapacity: true)
        showCatagories = true
        tableView.reloadData()
    }
    
}

extension UIImage {
    static func fromColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}
