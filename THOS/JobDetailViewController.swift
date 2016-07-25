//
//  JobDetailViewController.swift
//  THOS
//
//  Created by daylonvanwel on 13-07-16.
//  Copyright © 2016 daylon wel. All rights reserved.
//

import UIKit

class JobDetailViewController: UIViewController, UITextViewDelegate {

    
    @IBOutlet var jobDescriptionTextView: UITextView!
    @IBOutlet var jobPriceLabel: UILabel!
    @IBOutlet var firstDateButton: UIButton!
    @IBOutlet var secondDateButton: UIButton!
    @IBOutlet var thirdDateButton: UIButton!
    @IBOutlet var acceptJobButton: UIButton!
    
    var job: PFObject!
    
    var dateOne: NSDate!
    var dateTwo: NSDate!
    var dateThree: NSDate!
    
    var acceptedDate: NSDate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        jobDescriptionTextView.delegate = self
        
        showInfo()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showInfo() {
     

        jobPriceLabel.text =  "Deze opdracht levert je € \(job["price"]) op!"

        jobDescriptionTextView.text = job["jobDescription"] as? String
        jobDescriptionTextView.font = UIFont.systemFontOfSize(18, weight: UIFontWeightSemibold)
        jobDescriptionTextView.textAlignment = .Center
        
        dateOne = job["firtsOptionDate"] as! NSDate
        dateTwo =  job["secondsOptionDate"] as! NSDate!
        dateThree = job["thirdOptionDate"] as! NSDate!
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        let dateStringOne = formatter.stringFromDate(dateOne)
        let dateStringTwo = formatter.stringFromDate(dateTwo)
        let dateStringThree = formatter.stringFromDate(dateThree)
        
        firstDateButton.setTitle("Ik wil de klus doen op \(dateStringOne)", forState: .Normal)
        secondDateButton.setTitle("Ik wil de klus doen op \(dateStringTwo)", forState: .Normal)
        thirdDateButton.setTitle("Ik wil de klus doen op \(dateStringThree)", forState: .Normal)
        

    }

    @IBAction func firstDateButtonPressed(sender: AnyObject) {
        
        setButtonColors(firstDateButton)
        acceptedDate = dateOne
    }
    
    @IBAction func secondDateButtonPressed(sender: AnyObject) {
        
        setButtonColors(secondDateButton)
        acceptedDate = dateTwo
    }
    
    @IBAction func thirdDateButtonPressed(sender: AnyObject) {
    
        setButtonColors(thirdDateButton)
        acceptedDate = dateThree
    }
    
    func setButtonColors(sender: UIButton)  {
        
        for button in self.view.subviews {
            
            if button != sender && button.tag == 1 && button.isKindOfClass(UIButton) {
                
                let dateButton = button as! UIButton
                dateButton.setTitleColor(UIColor.ThosColor(), forState: .Normal)
                dateButton.backgroundColor = UIColor.whiteColor()
                
            } else {
                
                sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                sender.backgroundColor = UIColor.ThosColor()
 
            }
        }
    }
    
    @IBAction func acceptButtonPressed(sender: AnyObject) {
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
