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
    @IBOutlet var backButton: UIButton!
    @IBOutlet var jobtypeImageView: UIImageView!
    @IBOutlet var jobSubjectTextField: UITextField!
    
    var priceButton: UIButton!
    var priceTextField: UITextField!
    var price: NSNumber!

    var datePickerView: UIView!
    var selectButton: UIButton!
    var jobDateOptions = [NSDate(), NSDate(), NSDate()]
    var datePicker: UIDatePicker!
    var dateButtonInt: Int!
    
    var optionOneButton: UIButton!
    var optionTwoButton: UIButton!
    var optionThreeButton: UIButton!

    var optionDateOne: NSDate!
    var optionDateTwo: NSDate!
    var optionDateThree: NSDate!
    
    var cloudImage: UIImageView!
    
    var allRequiredJobInfoEntered: Bool!
    
    var jobType: Int!
    var jobSubType: Int!
    var jobtypeImage: UIImage!
    
    var missingItemsArray = [String]()
    var missingItemsString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set delegates
        
        jobtypeImageView.image = jobtypeImage
        
        jobDescriptionTextView.delegate = self
        jobDescriptionTextView.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        jobDescriptionTextView.textColor = UIColor.darkGrayColor()
        jobDescriptionTextView.font = UIFont(name: "OpenSans", size: 20)
        jobDescriptionTextView.placeholder = "Opdrachtomschrijving"
        jobDescriptionTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        jobDescriptionTextView.layer.borderWidth = 1.0
        
        jobSubjectTextField.layer.borderColor = UIColor.lightGrayColor().CGColor
        jobSubjectTextField.layer.borderWidth = 1.0

        allRequiredJobInfoEntered = true
        
        let height = view.frame.height
        let width = view.frame.width
        
        priceButton = UIButton(frame: CGRect(x: 35, y: height - 200, width: width / 2 - 35, height: 50))
        let underlinePriceAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue, NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        let underlinePriceAttributedString = NSAttributedString(string: "€ 0,-", attributes: underlinePriceAttribute)
        priceButton.setAttributedTitle(underlinePriceAttributedString, forState: .Normal)
        priceButton.addTarget(self, action: #selector(openPriceTextField), forControlEvents: .TouchUpInside)

        optionOneButton = UIButton(frame: CGRect(x: view.center.x, y: height - 200, width: width / 2 - 35, height: 50))
        let underlineOneAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue, NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        let underlineOneAttributedString = NSAttributedString(string: "Datum 1", attributes: underlineOneAttribute)
        optionOneButton.setAttributedTitle(underlineOneAttributedString, forState: .Normal)
        optionOneButton.tag = 0
        optionOneButton.addTarget(self, action: #selector(dateOptionsButtonPressed(_:)), forControlEvents: .TouchUpInside)
        
        optionTwoButton = UIButton(frame: CGRect(x: 35, y: height - 150, width: width / 2 - 35, height: 50))
        let underlineTwoAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue, NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        let underlineTwoAttributedString = NSAttributedString(string: "Datum 2", attributes: underlineTwoAttribute)
        optionTwoButton.setAttributedTitle(underlineTwoAttributedString, forState: .Normal)
        optionTwoButton.tag = 1
        optionTwoButton.addTarget(self, action: #selector(dateOptionsButtonPressed(_:)), forControlEvents: .TouchUpInside)

        optionThreeButton = UIButton(frame: CGRect(x: view.center.x, y: height - 150, width: width / 2 - 35, height: 50))
        let underlineThreeAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue, NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        let underlineThreeAttributedString = NSAttributedString(string: "Datum 3", attributes: underlineThreeAttribute)
        optionThreeButton.setAttributedTitle(underlineThreeAttributedString, forState: .Normal)
        optionThreeButton.tag = 2
        optionThreeButton.addTarget(self, action: #selector(dateOptionsButtonPressed(_:)), forControlEvents: .TouchUpInside)

        view.addSubview(priceButton)
        view.addSubview(optionOneButton)
        view.addSubview(optionTwoButton)
        view.addSubview(optionThreeButton)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)

        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(true)
        
        self.checkForMewChats()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func openPriceTextField() {
        
        priceTextField = UITextField(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: 50))
        priceTextField.layer.borderColor = UIColor.ThosColor().CGColor
        priceTextField.layer.borderWidth = 1.0
        priceTextField.delegate = self
        priceTextField.hidden = true
        priceTextField.keyboardType = .DecimalPad
        priceTextField.tintColor = UIColor.darkGrayColor()
        
        view.addSubview(priceTextField)
        
        priceTextField.becomeFirstResponder()
    }
    
     func dateOptionsButtonPressed(sender: UIButton) {
        
        openDatePickerForButton(sender.tag)
    }

    func openDatePickerForButton(dateNumber: Int) {
        
        dateButtonInt = dateNumber
        
        datePickerView = UIView(frame: view.frame)
        datePickerView.backgroundColor = UIColor(white: 0.3, alpha: 0.4)
        
        let datePickerBackgroundView = UIView(frame: CGRect(x: 0, y: view.frame.size.height / 2, width: view.frame.width, height: view.frame.size.height / 2))
        datePickerBackgroundView.backgroundColor = UIColor.whiteColor()
        
        datePicker = UIDatePicker(frame: CGRect(x: 0, y: 10, width: view.frame.size.width, height: 200))
        datePicker.datePickerMode = .Date
        
        selectButton = UIButton(frame: CGRect(x: 10, y: datePickerBackgroundView.frame.size.height - 60, width: view.frame.size.width - 20, height: 50))
        selectButton.setTitle("Kies als datum", forState: .Normal)
        selectButton.backgroundColor = UIColor.ThosColor()
        selectButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        selectButton.addTarget(self, action: #selector(self.addDateToArray), forControlEvents: .TouchUpInside)
        
    
        datePickerBackgroundView.addSubview(selectButton)
        datePickerBackgroundView.addSubview(datePicker)
        datePickerView.addSubview(datePickerBackgroundView)
        self.view.addSubview(datePickerView)
        
    }
    
    func addDateToArray() {
        
        jobDateOptions.insert(datePicker.date, atIndex: dateButtonInt)
        jobDateOptions.removeAtIndex(dateButtonInt + 1)
        
        datePickerView.removeFromSuperview()
        
        updateButtonText(dateButtonInt, date: self.datePicker.date)
        
    }
    
    func updateButtonText(buttonNumber: Int, date: NSDate) {
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        let dateString = formatter.stringFromDate(date)

        
        if buttonNumber == 0 {
            
            let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue, NSForegroundColorAttributeName: UIColor.darkGrayColor()]
            let underlineAttributedString = NSAttributedString(string: dateString, attributes: underlineAttribute)

            self.optionOneButton.setAttributedTitle(underlineAttributedString, forState: .Normal)
            
        } else if buttonNumber == 1 {
            
            let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue, NSForegroundColorAttributeName: UIColor.darkGrayColor()]
            let underlineAttributedString = NSAttributedString(string: dateString, attributes: underlineAttribute)
            
            self.optionTwoButton.setAttributedTitle(underlineAttributedString, forState: .Normal)

        } else if buttonNumber == 2 {
            
            let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue, NSForegroundColorAttributeName: UIColor.darkGrayColor()]
            let underlineAttributedString = NSAttributedString(string: dateString, attributes: underlineAttribute)
            
            self.optionThreeButton.setAttributedTitle(underlineAttributedString, forState: .Normal)

        }

    }
    

    
    func checkForRequiredInfo() {
        
        if jobDescriptionTextView.text == "" {
        
            self.allRequiredJobInfoEntered = false
            self.missingItemsArray.append("opdrachtomschrijving")
        }
        
        

        if Int(price) < 10 {
            
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
        job["isPaid"] = false
        
        
        job.saveInBackgroundWithBlock { (succes, error) -> Void in
            
            if error != nil {
                
                print(error?.localizedDescription)
                
            } else {
                
                if succes == true {
                    
                    self.animatePostButton()
                }
            }
        }

        
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
            
            // todo pop up
            
        } else {
           
            if self.priceTextField.text! != "" && self.priceTextField.text! != "€ " {
                
                let price: Int = Int(self.priceTextField.text!)!
                
                self.price = NSNumber(integer: price)
                
                
            }
           
            let underlinePriceAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue, NSForegroundColorAttributeName: UIColor.darkGrayColor()]
            let underlinePriceAttributedString = NSAttributedString(string: "€ \(priceString)", attributes: underlinePriceAttribute)
            priceButton.setAttributedTitle(underlinePriceAttributedString, forState: .Normal)

            self.priceTextField.resignFirstResponder()
            self.priceTextField.removeFromSuperview()
        }
    }
    
    func keyboardWillShow(notification: NSNotification)  {
        
        print(notification.userInfo![UIKeyboardFrameEndUserInfoKey]?.CGRectValue().origin.y)
        
        self.priceTextField.center = CGPointMake(view.frame.width / 2, (notification.userInfo![UIKeyboardFrameEndUserInfoKey]?.CGRectValue().origin.y)! - 25)
        self.priceTextField.hidden = false

    }
    
    // todo check for new chats to new viewController "selectnewjobViewController"
 
    func checkForMewChats() {
    
//        let tabBarController = self.parentViewController as! HelpSeekerTabbarControllerViewController
//        tabBarController.checkForMewChats()

    }
    
     @IBAction func dismissViewButtonPressed() {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
