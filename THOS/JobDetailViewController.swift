//
//  JobDetailViewController.swift
//  THOS
//
//  Created by daylonvanwel on 13-07-16.
//  Copyright © 2016 daylon wel. All rights reserved.
//

import UIKit

class JobDetailViewController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
   
    var job: PFObject!
    
    var dateOne: NSDate!
    var dateTwo: NSDate!
    var dateThree: NSDate!
    
    var acceptedDate: NSDate!
    
    var width: CGFloat!
    
    var userImage: UIImage!
    var userName: String!
    var jobUser: PFUser!

    
    override func viewDidLoad() {
     
        super.viewDidLoad()
        
        width = view.frame.width
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

        let user = job["user"] as! PFUser
                
        let userQuery = PFUser.query()
        userQuery?.whereKey("objectId", equalTo: user.objectId!)
        userQuery?.getFirstObjectInBackgroundWithBlock({ (user , error ) -> Void in
            
            if error != nil {
                
                // something went wrong

            } else {
                
                self.jobUser = user as! PFUser

                let file = user!["userImgage"] as! PFFile
                file.getDataInBackgroundWithBlock({ (data, error) -> Void in
                    
                    if error != nil {
                        
                        // something went wrong
                    } else {
                        
                        self.userImage = UIImage(data: data!)
                        self.userName = user!["displayName"] as? String
                        
                        self.tableView.reloadData()
                    }
                })
                
                
            }
        })

    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        if indexPath.row == 0 {
            
            let descriptionLabel = UILabel(frame: CGRect(x: 35.0, y: 10.0, width: width - 70, height: 130))
            descriptionLabel.text = job["jobSubject"] as? String
            descriptionLabel.textAlignment = .Left
            descriptionLabel.adjustsFontSizeToFitWidth = true
            descriptionLabel.numberOfLines = 3
            descriptionLabel.font = UIFont(name: "OpenSans-Semibold", size: 32)
            descriptionLabel.textColor = UIColor.darkGrayColor()
            
            cell.addSubview(descriptionLabel)

        } else if indexPath.row == 1 {
            
            let imageView = UIImageView(frame: CGRect(x: 35, y: 10, width: 60, height: 60))
            imageView.layer.cornerRadius = 30
            imageView.clipsToBounds = true
            imageView.image = self.userImage
            
            let usernameLabel = UILabel(frame: CGRect(x: 110, y: 10, width: width - 120, height: 60))
            usernameLabel.text = self.userName
            usernameLabel.adjustsFontSizeToFitWidth = true
            usernameLabel.font = UIFont(name: "OpenSans-Semibold", size: 22)
            usernameLabel.textColor = UIColor.darkGrayColor()
          
            cell.addSubview(usernameLabel)
            cell.addSubview(imageView)
            
            cell.layer.borderColor = UIColor.lightGrayColor().CGColor
            cell.layer.borderWidth = 0.5
            cell.accessoryType = .DisclosureIndicator
            
        } else if indexPath.row == 2 {
            
            let descriptionTXTV = UITextView(frame: CGRect(x: 35.0, y: 20.0, width: width - 70, height: 140))
            descriptionTXTV.text = job["jobDescription"] as? String
            descriptionTXTV.textAlignment = .Left
            descriptionTXTV.font = UIFont(name: "OpenSans", size: 22)
            descriptionTXTV.textColor = UIColor.darkGrayColor()
            descriptionTXTV.editable = false
            descriptionTXTV.selectable = false
            
            cell.addSubview(descriptionTXTV)
            
        } else if indexPath.row == 3 {
            
            let priceLabel = UILabel(frame: CGRect(x: 35, y: 20, width: width / 2 - 35, height: 70))
            priceLabel.layer.borderColor = UIColor(white: 0.95, alpha: 0.9).CGColor
            priceLabel.layer.borderWidth = 1.0
            priceLabel.text = "€ \(job["price"])"
            priceLabel.textAlignment = .Center
            priceLabel.textColor = UIColor.darkGrayColor()
            
            dateOne = job["firtsOptionDate"] as! NSDate
            dateTwo =  job["secondsOptionDate"] as! NSDate
            dateThree = job["thirdOptionDate"] as! NSDate
            
            let formatter = NSDateFormatter()
            formatter.dateStyle = .MediumStyle
            
            let dateStringOne = formatter.stringFromDate(dateOne)
            let dateStringTwo = formatter.stringFromDate(dateTwo)
            let dateStringThree = formatter.stringFromDate(dateThree)
            
            let optionOneButton = UIButton(frame: CGRect(x: view.center.x, y: 20, width: width / 2 - 35, height: 70))
            let underlineOneAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue, NSForegroundColorAttributeName: UIColor.darkGrayColor()]
            let underlineOneAttributedString = NSAttributedString(string: dateStringOne, attributes: underlineOneAttribute)
            optionOneButton.setAttributedTitle(underlineOneAttributedString, forState: .Normal)
            optionOneButton.tag = 0
            optionOneButton.addTarget(self, action: #selector(firstDateButtonPressed(_:)), forControlEvents: .TouchUpInside)
            optionOneButton.layer.borderColor = UIColor(white: 0.95, alpha: 0.9).CGColor
            optionOneButton.layer.borderWidth = 1.0
            
            let optionTwoButton = UIButton(frame: CGRect(x: 35, y: 90, width: width / 2 - 35, height: 70))
            let underlineTwoAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue, NSForegroundColorAttributeName: UIColor.darkGrayColor()]
            let underlineTwoAttributedString = NSAttributedString(string: dateStringTwo, attributes: underlineTwoAttribute)
            optionTwoButton.setAttributedTitle(underlineTwoAttributedString, forState: .Normal)
            optionTwoButton.tag = 1
            optionTwoButton.addTarget(self, action: #selector(secondDateButtonPressed(_:)), forControlEvents: .TouchUpInside)
            optionTwoButton.layer.borderColor = UIColor(white: 0.95, alpha: 0.9).CGColor
            optionTwoButton.layer.borderWidth = 1.0
            
            let optionThreeButton = UIButton(frame: CGRect(x: view.center.x, y: 90, width: width / 2 - 35, height: 70))
            let underlineThreeAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue, NSForegroundColorAttributeName: UIColor.darkGrayColor()]
            let underlineThreeAttributedString = NSAttributedString(string: dateStringThree, attributes: underlineThreeAttribute)
            optionThreeButton.setAttributedTitle(underlineThreeAttributedString, forState: .Normal)
            optionThreeButton.tag = 2
            optionThreeButton.addTarget(self, action: #selector(thirdDateButtonPressed(_:)), forControlEvents: .TouchUpInside)
            optionThreeButton.layer.borderColor = UIColor(white: 0.95, alpha: 0.9).CGColor
            optionThreeButton.layer.borderWidth = 1.0
            
            cell.addSubview(priceLabel)
            cell.addSubview(optionOneButton)
            cell.addSubview(optionTwoButton)
            cell.addSubview(optionThreeButton)

            
        } else if indexPath.row == 4 {
            
            let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue, NSForegroundColorAttributeName: UIColor.ThosColor(), NSFontAttributeName: UIFont(name: "OpenSans", size: 26.0)!]
            let underlineAttributedString = NSAttributedString(string: "Stuur bericht", attributes: underlineAttribute)

            let label = UILabel(frame: CGRect(x: 35.0, y: 0.0, width: width - 70, height: 60))
    
            label.attributedText = underlineAttributedString
            
            cell.addSubview(label)
            
        } else if indexPath.row == 5 {
            
            // nothing yet
        }


        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            
            return 150
            
        } else if indexPath.row == 1 {
            
            return 80
            
        } else if indexPath.row == 2 {
            
            return 160
            
        } else if indexPath.row == 3 {
            
            return 160

        } else {
            
            return 60
        }

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == 1 {
            
            performSegueWithIdentifier("detailToShowUserProfileSegue", sender: self)
        }
    }
    
     func firstDateButtonPressed(sender: AnyObject) {
        print("one")
        acceptedDate = dateOne
    }
    
     func secondDateButtonPressed(sender: AnyObject) {
        print("two")
        acceptedDate = dateTwo
    }
    
     func thirdDateButtonPressed(sender: AnyObject) {
        print("three")
        acceptedDate = dateThree
    }
    
    
    func acceptButtonPressed(sender: AnyObject) {
        
        job["acceptedDate"] = acceptedDate
        job["acceptedUser"] = PFUser.currentUser()
        job["open"] = false
        
        job.saveInBackgroundWithBlock { (saved, error) in
            
            if error != nil {
                
                print(error)
            } else {
                
                if saved == true {
                    
                    self.sendAccepteddPush(self.job)
                    self.animateJobAcceptance()
                    
                } else {
                    
                    print("not saved")
                }
            }
        }
    }
    
    func animateJobAcceptance() {
        
        for subView in view.subviews {
            
            UIView.animateWithDuration(0.3, animations: { 
              
                subView.alpha  = 0.0
               
                }, completion: { (animated) in
                    
                    subView.removeFromSuperview()
                    self.navigationController?.popViewControllerAnimated(true)
            })
        }
    }
    
    func sendAccepteddPush(job: PFObject) {
        
        let pushQuery = PFInstallation.query()
        pushQuery!.whereKey("user", equalTo: job["user"] as! PFUser)
        let descriptionString = job["jobDescription"] as! String
        
        let dataDIC:[String: AnyObject] = [
            
            "alert"             : "Someone accepted your job: \(descriptionString)",
            // todo interesed is gone
            "type"              : "applied",
            "price"             : job["price"] as! NSNumber,
            "sku"               : job.objectId!,
            "description"       : job["jobDescription"] as! String,
            "badge"             : "increment",
            "sound"             : "message-sent.aiff"
        ]
        
        let push = PFPush()
        
        push.setQuery(pushQuery)
        push.setData(dataDIC)
        push.sendPushInBackground()
    }

    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.destinationViewController.isKindOfClass(SHowUserProfileViewController) {
            
            let controller = segue.destinationViewController as! SHowUserProfileViewController
            controller.user = jobUser
            controller.userName = userName
            controller.userImage = userImage
        }
    }
 

}
