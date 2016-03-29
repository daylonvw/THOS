//
//  CreateAccountViewController.swift
//  Jobie
//
//  Created by daylonvanwel on 05-02-16.
//  Copyright © 2016 daylon wel. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userEmailTextField: UITextField!
    @IBOutlet var userPassWordTextFiled: UITextField!
    @IBOutlet var userDatePicker: UIDatePicker!
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var userTypeSegmentedControl: UISegmentedControl!
    
    var enteredAllInfo: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("selectImagePressed"))
        gestureRecognizer.numberOfTapsRequired = 1
        self.userImageView.userInteractionEnabled = true
        self.userImageView.addGestureRecognizer(gestureRecognizer)
   
        self.userImageView.layer.cornerRadius = 50
        self.userImageView.layer.masksToBounds = true
        
        userEmailTextField.delegate = self
        userPassWordTextFiled.delegate = self
        
        enteredAllInfo = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func selectImagePressed() {

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)

    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        dismissViewControllerAnimated(true, completion: nil)
        self.userImageView.image = image
        self.userImageView.highlighted = true
    }
    
    @IBAction func createButtonPressed(sender: AnyObject) {
        
        let dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "MM/dd/yy"
        
        
        let timeinterval = NSDate().timeIntervalSinceDate(self.userDatePicker.date)
            
        let secondsperY = 31536000
        let userAge  = Int(timeinterval) / secondsperY
        let userAgenumer = NSNumber(integer: userAge)
        
    
        let user = PFUser()
        
        if userNameTextField.text != "" {
            
            user.username = self.userEmailTextField.text
            user["displayName"] = self.userNameTextField.text

        } else {
            
            enteredAllInfo = false
            openalertViewController("user name")
        }

        if userPassWordTextFiled.text != "" {
            
            user.password = self.userPassWordTextFiled.text

        } else {
          
            enteredAllInfo = false

            openalertViewController("password")
        }
        
        if userEmailTextField.text != "" {
            
            user.email = self.userEmailTextField.text

        } else {
            
            enteredAllInfo = false

            openalertViewController("email")
        }
        
        if userImageView.highlighted == true {
            
            let file = PFFile(data: UIImageJPEGRepresentation(self.userImageView.image!, 0.3)!)
            user["userImgage"] = file

        } else {
            
            enteredAllInfo = false

            openalertViewController("image")
        }
        
        if self.userTypeSegmentedControl.selectedSegmentIndex == -1 {
            
            enteredAllInfo = false

            openalertViewController("user type")
            
        } else {
            
            if self.userTypeSegmentedControl.selectedSegmentIndex == 0 {
                
                user["userType"] = "seeker"

                
            } else if self.userTypeSegmentedControl.selectedSegmentIndex == 1 {
                
                user["userType"] = "helper"

            }
        }
        

        if userAge > 12 {
            
            user["userAge"] = userAgenumer

        } else {
            
            enteredAllInfo = false

            openalertViewController("birthday")

        }
        
        if enteredAllInfo == true {
        
            for subView in self.view.subviews {
                
                subView.hidden = true
            }
            
            let activity = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            activity.activityIndicatorViewStyle = .WhiteLarge
            activity.center = self.view.center
            activity.startAnimating()
            self.view.addSubview(activity)
            
            user.signUpInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
           
                if error != nil {
               
                        print(error?.localizedDescription)
                
                } else {

                    let object = PFObject(className: "UserRating")
                    object["user"] = user
                    object["totalRating"] = 5
                    object["numberOfRatings"] = 1
                    object["rating"] = 3
                    object.saveInBackgroundWithBlock({ (succeded, error ) -> Void in
                    
                        if succeeded == true {
                        
                            // set first distance for search
                            NSUserDefaults.standardUserDefaults().setInteger(50, forKey: "distanceForSearch")
                            NSUserDefaults.standardUserDefaults().synchronize()
                        
                            // creation complete.. go to job screen
                        
                            if user["userType"] as! String == "seeker" {

                                self.performSegueWithIdentifier("createAccountVCtoTabbarVCsegue", sender: self)
                            
                            } else if user["userType"] as! String == "helper" {
                            
                                self.performSegueWithIdentifier("createUserToHelperSegue", sender: self)

                            }

                        }
                    })

                }
            }
        }
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
     
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        textField.resignFirstResponder()
    }
    
    func openalertViewController(missingItem: String) {
    
        let messageString  = "You seem to have forgotten to enter your \(missingItem)"
        let controoler = UIAlertController(title: "Uh oh", message: messageString, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default) { (action) -> Void in
            
            self.enteredAllInfo = true
        }
        
        controoler.addAction(okAction)
        
        self.presentViewController(controoler, animated: true, completion: nil)
        
    }
}























