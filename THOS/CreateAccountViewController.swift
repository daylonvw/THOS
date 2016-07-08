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
    @IBOutlet var userNameTextField: UITextField!
    
    var enteredAllInfo: Bool!
    var termsView: UIWebView!
    var newUser: PFUser!
    var cancelButton: UIButton!
    var acceptButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CreateAccountViewController.selectImagePressed))
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
        
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            
            print("lib")
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(imagePicker, animated: true, completion: nil)

        } else if UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum) {
           
            print("album")
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            self.presentViewController(imagePicker, animated: true, completion: nil)

        }
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        dismissViewControllerAnimated(true, completion: nil)
        
            self.userImageView.image = image
            self.userImageView.highlighted = true
        
    }
    
    @IBAction func createButtonPressed(sender: AnyObject) {
        
        let user = PFUser()
        
        if userNameTextField.text != "" {
            
            user.username = self.userEmailTextField.text
            user["displayName"] = self.userNameTextField.text

        } else {
            
            enteredAllInfo = false
            openalertViewController("Gebruikersnaam")
        }

        if userPassWordTextFiled.text != "" {
            
            user.password = self.userPassWordTextFiled.text

        } else {
          
            enteredAllInfo = false

            openalertViewController("Wachtwoord")
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

            openalertViewController("Foto")
        }
        
        if enteredAllInfo == true {
        
            newUser = user
            self.openConditionsAlertViewController()
        }

    }
    
    func openConditionsAlertViewController() {
        
        let controller = UIAlertController(title: "Bedankt voor het registreren", message: "door het creëren van een account ga je akkoord met onze algemene voorwaarden", preferredStyle: .Alert)
        
        let acceptAction = UIAlertAction(title: "Accepteer", style: .Default) { (action) in
            
            self.continueCreatinAccount()
            
        }
        
        let readfirstAction = UIAlertAction(title: "Laat zien", style: .Default) { (action) in
            
            self.openTermsView()
            
        }
        
        let cancelAction = UIAlertAction(title: "Terug", style: .Default, handler: nil)

        controller.addAction(readfirstAction)
        controller.addAction(acceptAction)
        controller.addAction(cancelAction)
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func continueCreatinAccount() {
        
        for subView in self.view.subviews {
            
            subView.hidden = true
        }
        
        let user = newUser
        
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
                object["totalRating"] = 1
                object["numberOfRatings"] = 1
                object["rating"] = 1
                object.saveInBackgroundWithBlock({ (succeded, error ) -> Void in
                    
                    if succeeded == true {
                        
                        // set first distance for search
                        NSUserDefaults.standardUserDefaults().setInteger(50, forKey: "distanceForSearch")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                        self.performSegueWithIdentifier("createAccountVCtoTabbarVCsegue", sender: self)
                            
                    }
                })
                
            }
        }

    }
    
    func openTermsView() {
        
        
        if let pdf = NSBundle.mainBundle().URLForResource("The House of Service legal BU", withExtension: "pdf", subdirectory: nil, localization: nil)  {
            let req = NSURLRequest(URL: pdf)
            termsView = UIWebView(frame: CGRect(x: 0, y: 20, width: view.frame.size.width, height: view.frame.size.height - 60))
            termsView.loadRequest(req)
            self.view.addSubview(termsView)
        }

        
        cancelButton = UIButton(frame: CGRect(x: 0, y: self.view.frame.size.height - 60, width: view.frame.size.width / 2, height: 60))
        cancelButton.backgroundColor = UIColor.ThosColor()
        cancelButton.setTitle("Terug", forState: .Normal)
        cancelButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        cancelButton.addTarget(self, action: #selector(CreateAccountViewController.dismissTermsView), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(cancelButton)
        
        acceptButton = UIButton(frame: CGRect(x: view.frame.size.width / 2, y: self.view.frame.size.height - 60, width: view.frame.size.width / 2, height: 60))
        acceptButton.backgroundColor = UIColor.ThosColor()
        acceptButton.setTitle("Accepteer", forState: .Normal)
        acceptButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        acceptButton.addTarget(self, action: #selector(CreateAccountViewController.continueCreatinAccount), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(acceptButton)
    }
    
    func dismissTermsView() {
        
        self.termsView.removeFromSuperview()
        acceptButton.removeFromSuperview()
        cancelButton.removeFromSuperview()
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
    
        let messageString  = "Je bent vergeten om je \(missingItem) te selecteren"
        let controoler = UIAlertController(title: "Oh oh", message: messageString, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Oke", style: .Default) { (action) -> Void in
            
            self.enteredAllInfo = true
        }
        
        controoler.addAction(okAction)
        
        self.presentViewController(controoler, animated: true, completion: nil)
        
    }
}























