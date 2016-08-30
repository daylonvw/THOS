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
        
        centerX = view.center.x
        centerY = view.center.y

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
                }
            }
            
        }

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
       
                if indexPath.section == 0 {
            
                    if indexPath.row == 0 {
                
                        cell.jobDescriptionLabel.text = "Schoonmaak"
                        cell.userImageView.image = UIImage(named: "IndoorCleaning")
                
                    } else if indexPath.row == 1 {
                
                        cell.jobDescriptionLabel.text = "Oppas"
                        cell.userImageView.image = UIImage(named: "nanny")
                
                
                    } else if indexPath.row == 2 {
                
                        cell.jobDescriptionLabel.text = "Houtwerk"
                        cell.userImageView.image = UIImage(named: "woodWork")
                
                
                    } else if indexPath.row == 3 {
                
                        cell.jobDescriptionLabel.text = "Electricien"
                        cell.userImageView.image = UIImage(named: "electrician")
                
                
                    }
            
                } else if indexPath.section == 1 {
            
                    if indexPath.row == 0 {
                
                        cell.jobDescriptionLabel.text = "Rondom het huis"
                        cell.userImageView.image = UIImage(named: "aroundTheHouse")
                    
                    } else if indexPath.row == 1 {
                
                        cell.jobDescriptionLabel.text = "In de tuin"
                        cell.userImageView.image = UIImage(named: "garden")
                
                
                    }
                    
                } else if indexPath.section == 2 {
            
                    if indexPath.row == 0 {
                
                        cell.jobDescriptionLabel.text = "Vervoer en verzend"
                        cell.userImageView.image = UIImage(named: "pickUp")
                    }
            }

        } else if showCatagories == false {
            
            let job = self.jobsArray[indexPath.row]
            
            cell.jobDescriptionLabel.text = job["jobDescription"] as? String
                        
            cell.userImageView.image = catagorieImage
            
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
        
        jobsArray.removeAll(keepCapacity: true)
        showCatagories = true
        tableView.reloadData()
    }
    


}
