//
//  CreateJobViewController.swift
//  Jobie
//
//  Created by daylonvanwel on 05-02-16.
//  Copyright © 2016 daylon wel. All rights reserved.
//

import UIKit

class CreateJobViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var jobDescriptionTextView: UITextView!
    @IBOutlet var postJobButton: UIButton!
    @IBOutlet var priceTextField: UITextField!
    
    @IBOutlet var openDatePickerViewButton: UIButton!
    
    var datePickerView: UIView!
    var selectButton: UIButton!
    var jobDateOptions = [NSDate]()
    var datePicker: UIDatePicker!
    
    var optionDateOne: NSDate!
    var optionDateTwo: NSDate!
    var optionDateThree: NSDate!
    
    @IBOutlet var firstDateLabel: UILabel!
    @IBOutlet var secondDateLabel: UILabel!
    @IBOutlet var thirdDateLabel: UILabel!
    
    var cloudImage: UIImageView!
    
    var allRequiredJobInfoEntered: Bool!
    
    var jobType: Int!
    var jobSubType: Int!
    
    var missingItemsArray = [String]()
    var missingItemsString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set delegates
        self.jobDescriptionTextView.delegate = self
        self.priceTextField.delegate = self
        
        jobDescriptionTextView.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        jobDescriptionTextView.textColor = UIColor.darkGrayColor()
        jobDescriptionTextView.font = UIFont.systemFontOfSize(20, weight: UIFontWeightMedium)
        jobDescriptionTextView.placeholder = "Typ hier de opdrachtomschrijving"
        jobDescriptionTextView.layer.borderColor = UIColor.ThosColor().CGColor
        jobDescriptionTextView.layer.borderWidth = 1.0

        priceTextField.layer.borderColor = UIColor.ThosColor().CGColor
        priceTextField.layer.borderWidth = 1.0

        allRequiredJobInfoEntered = true
        
        let dismissViewButton = UIButton(frame: CGRect(x: 10, y: view.frame.size.height - 60, width: 60, height: 60))
        dismissViewButton.setTitle("Annuleer", forState: .Normal)
        dismissViewButton.setTitleColor(UIColor.ThosColor(), forState: .Normal)
        dismissViewButton.titleLabel?.adjustsFontSizeToFitWidth = true
        dismissViewButton.addTarget(self, action: #selector(self.dismissViewButtonPressed), forControlEvents: .TouchUpInside)
        
        view.addSubview(dismissViewButton)
    NSNotificationCenter.defaultCenter().addObserverForName("openedWitdPushFromJobHelper", object: nil, queue: nil) { (notification: NSNotification) -> Void in
            
            self.openChatFromNotification(notification)
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(true)
        
        self.checkForMewChats()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @IBAction func dateOptionsButtonPressed(sender: AnyObject) {
        
        openDatePickerForButton()
    }

    func openDatePickerForButton() {
        
        self.jobDateOptions.removeAll(keepCapacity: true)
        
        datePickerView = UIView(frame: view.frame)
        datePickerView.backgroundColor = UIColor(white: 0.3, alpha: 0.4)
        
        let datePickerBackgroundView = UIView(frame: CGRect(x: 0, y: view.frame.size.height / 2, width: view.frame.width, height: view.frame.size.height / 2))
        datePickerBackgroundView.backgroundColor = UIColor.whiteColor()
        
        datePicker = UIDatePicker(frame: CGRect(x: 0, y: 10, width: view.frame.size.width, height: 200))
        datePicker.datePickerMode = .Date
        
        selectButton = UIButton(frame: CGRect(x: 10, y: datePickerBackgroundView.frame.size.height - 60, width: view.frame.size.width - 20, height: 50))
        selectButton.setTitle("Kies als eerste datum", forState: .Normal)
        selectButton.backgroundColor = UIColor.ThosColor()
        selectButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        selectButton.addTarget(self, action: #selector(self.addDateToArray), forControlEvents: .TouchUpInside)
        
    
        datePickerBackgroundView.addSubview(selectButton)
        datePickerBackgroundView.addSubview(datePicker)
        datePickerView.addSubview(datePickerBackgroundView)
        self.view.addSubview(datePickerView)
        
    }
    
    func addDateToArray() {
        
        openDatePickerViewButton.setTitle("Klik hier om een datum te wijzigen", forState: .Normal)
        
        if self.jobDateOptions.count < 3 {
            
            self.jobDateOptions.append(datePicker.date)
            

            if jobDateOptions.count == 1 {
                
                selectButton.setTitle("Kies als tweede datum", forState: .Normal)

            } else if jobDateOptions.count == 2 {
                
                selectButton.setTitle("Kies als derde datum", forState: .Normal)

            }
            
            if jobDateOptions.count == 3 {
                
                datePickerView.removeFromSuperview()
                
                showDateOptions()
                
                
            }
            
        }
    }
    
    func showDateOptions() {
        
        var dateStringArray = [String]()
        
        for date in jobDateOptions {
            
            let formatter = NSDateFormatter()
            formatter.dateStyle = .MediumStyle
            let dateString = formatter.stringFromDate(date)
            
            dateStringArray.append(dateString)

        }
        
        
        firstDateLabel.text = "1. \(dateStringArray[0])"
        secondDateLabel.text = "2. \(dateStringArray[1])"
        thirdDateLabel.text = "3. \(dateStringArray[2])"

    }
    
    func checkForRequiredInfo() {
        
        if jobDescriptionTextView.text == "" {
        
            self.allRequiredJobInfoEntered = false
            self.missingItemsArray.append("opdrachtomschrijving")
        }
        
        
        let priceString = self.priceTextField.text!
        
        if priceString == "" || priceString == "€" || priceString == "€ " {
            
            self.allRequiredJobInfoEntered = false
            self.missingItemsArray.append("opdracht prijs")

        }
        
        if jobDateOptions.count < 3 {
            
            self.allRequiredJobInfoEntered = false
            self.missingItemsArray.append("opdracht datum")
        }
        
        if self.allRequiredJobInfoEntered == true {
            
            self.postJobToServer()
            
        } else {
            
            self.allRequiredJobInfoEntered = true
            
            self.openalertViewController("")
        }
        
    }
    
    @IBAction func postJobButtonPressed(sender: AnyObject) {
        
        self.checkForRequiredInfo()
        
    }
    
    func openalertViewController(missingItem: String) {
        
        for missingItem in self.missingItemsArray {
            
            self.missingItemsString = "\(self.missingItemsString), \(missingItem)"
            
        }
        
        let messageString  = String(self.missingItemsString.characters.dropFirst())
        let controoler = UIAlertController(title: "Oh oh, je bent het volgende vergeten:", message: messageString, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil )
        
        controoler.addAction(okAction)
        
        self.presentViewController(controoler, animated: true, completion: nil)
        
        self.missingItemsString = ""
        self.missingItemsArray.removeAll(keepCapacity: true)
        
    }

    
    func postJobToServer(){
    
        let job = PFObject(className: "Job")
    
        if self.priceTextField.text! != "" && self.priceTextField.text! != "€ " {
            
            let priceString = self.priceTextField.text!
            
            let indexStartOfText = priceString.startIndex.advancedBy(2)
            
            let PriceSubString = priceString.substringFromIndex(indexStartOfText)

            let price: Int = Int(PriceSubString)!
            
            job["price"] = NSNumber(integer: price)
            
            
        }
        
        if self.jobDescriptionTextView.text != "" {
            
            job["jobDescription"] = self.jobDescriptionTextView.text
            
        }
        
        job["user"] = PFUser.currentUser()!
        job["userId"] = PFUser.currentUser()?.objectId
        job["open"] = true
        job["finished"] = false
        job["posterAcceptedDate"] = false
        job["helperAcceptedDate"] = false
        job["posterReadLastText"] = false
        job["helperReadLastText"] = false
        job["firtsOptionDate"] = jobDateOptions[0]
        job["secondsOptionDate"] = jobDateOptions[1]
        job["thirdOptionDate"] = jobDateOptions[2]
        job["jobTypeNumber"] = self.jobType
        job["jobSubTypeNumber"] = self.jobSubType
        
        
        job.saveInBackgroundWithBlock { (succes, error) -> Void in
            
            if error != nil {
                
                print(error?.localizedDescription)
                
            } else {
                
                if succes == true {
                    
                    self.animatePostButton()
                    self.sendNearByPush()
                }
            }
        }

        
    }
    
    func sendNearByPush() {
        // todo
        
//        let pushQuery = PFInstallation.query()
//        pushQuery?.whereKey("installationId", notEqualTo:PFInstallation().installationId)
//        pushQuery?.whereKey("location", nearGeoPoint: self.jobPFGeoPoint, withinKilometers: 100)
//        
//        let dataDIC:[String: AnyObject] = [
//            
//            "alert"             : "Nieuwe opdracht in de buurt",
//            "type"              : "new job",
//            "badge"             : "increment",
//            "sound"             : "message-sent.aiff"
//        ]
//        
//        let push = PFPush()
//        
//        push.setQuery(pushQuery)
//        push.setData(dataDIC)
//        push.sendPushInBackground()

    }
    
    
    func animatePostButton() {
        
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
// textFieldDelagate
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        return true
    }
    

    
    func textFieldDidBeginEditing(textField: UITextField) {
    
        self.jobDescriptionTextView.userInteractionEnabled = false

        if textField == self.priceTextField {
            
            let numberToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
            numberToolbar.barStyle = .Default
            numberToolbar.items = [UIBarButtonItem(title: "Klaar", style: .Plain, target: self, action: #selector(CreateJobViewController.resignNumberpad))]
            numberToolbar.sizeToFit()
            self.priceTextField.inputAccessoryView = numberToolbar
            
        }
    }

 // textView delegate
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        return true
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            
            self.jobDescriptionTextView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func resignNumberpad() {
        
        self.jobDescriptionTextView.userInteractionEnabled = true

        let priceString = self.priceTextField.text!
        
        if priceString == "" || priceString == "€" || priceString == "€ " {
            
            self.priceTextField.text = ""
            self.priceTextField.resignFirstResponder()
            
        } else {
           
            self.priceTextField.text = "€ \(priceString)"
            self.priceTextField.resignFirstResponder()
        }
    }
    
    // todo check for new chats to new viewController "selectnewjobViewController"
 
    func checkForMewChats() {
    
//        let tabBarController = self.parentViewController as! HelpSeekerTabbarControllerViewController
//        tabBarController.checkForMewChats()

    }
    
    func openChatFromNotification(notification: NSNotification) {
        
        let query = PFQuery(className: "Job")
        query.whereKey("objectId", equalTo: notification.object as! String)
        query.getFirstObjectInBackgroundWithBlock { (object, error) in
            if error != nil {
                
                print(error)
                
            } else {
                
                let storyBoard  = UIStoryboard(name: "Main", bundle: nil)
                
                let chatController = storyBoard.instantiateViewControllerWithIdentifier("postedJobsChatController") as! JobChatViewController
                
                chatController.jobId = object!.objectId
                chatController.jobGeoPoint = object!.valueForKey("jobLocation") as! PFGeoPoint
                chatController.jobDescription = object!.valueForKey("jobDescription") as! String
                chatController.job = object!

                
                self.presentViewController(chatController, animated: true, completion: nil)

            }
        }
    }
    
    
    
    func dismissViewButtonPressed() {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
