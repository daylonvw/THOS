//
//  ViewController.swift
//  Jobie
//
//  Created by daylonvanwel on 05-02-16.
//  Copyright © 2016 daylon wel. All rights reserved.
//

import UIKit
import ParseFacebookUtilsV4

class LoginVCViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var userPassWordTextField: UITextField!
    
    @IBOutlet var userLoginButton: UIButton!
    @IBOutlet var userCreateNewAccountButton: UIButton!
    @IBOutlet var facebookLoginButton: UIButton!
    
    var userFriendsArray = [String]()
    var termsView: UIWebView!
    var cancelButton: UIButton!
    var acceptButton: UIButton!
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let loginButton = FBSDKLoginButton()
        loginButton.center = CGPointMake(view.center.x, view.center.y + 200)
        
        facebookLoginButton.contentHorizontalAlignment = .Left
        facebookLoginButton.setTitleColor(UIColor.ThosColor(), forState: .Normal)
        
        userCreateNewAccountButton.contentHorizontalAlignment = .Left

        userLoginButton.contentHorizontalAlignment = .Left
        userLoginButton.setTitleColor(UIColor.ThosColor(), forState: .Normal)

        
        self.userCreateNewAccountButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        userNameTextField.delegate = self
        userPassWordTextField.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func faceBookLoginPressed() {
        
        
        let controller = UIAlertController(title: "Bedankt voor het registreren", message: "door het creëren van een account ga je akkoord met onze algemene voorwaarden", preferredStyle: .Alert)
        
        let acceptAction = UIAlertAction(title: "Accepteer", style: .Default) { (action) in
            
            self.continueWithFacebookLogin()
            
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
        cancelButton.addTarget(self, action: #selector(LoginVCViewController.dismissTermsView), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(cancelButton)
        
        acceptButton = UIButton(frame: CGRect(x: view.frame.size.width / 2, y: self.view.frame.size.height - 60, width: view.frame.size.width / 2, height: 60))
        acceptButton.backgroundColor = UIColor.ThosColor()
        acceptButton.setTitle("Accepteer", forState: .Normal)
        acceptButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        acceptButton.addTarget(self, action: #selector(LoginVCViewController.continueWithFacebookLogin), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(acceptButton)
    }
    
    func dismissTermsView() {
        
        self.termsView.removeFromSuperview()
        acceptButton.removeFromSuperview()
        cancelButton.removeFromSuperview()
    }
    
    func continueWithFacebookLogin() {
        
        for subView in view.subviews {
            
            subView.hidden = true
        }
        
        let permissionsArray = ["public_profile", "email", "user_friends"]
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissionsArray) {
            (user: PFUser?, error: NSError?) -> Void in
            
            if let user = user {
                
                if user.isNew {
                    
                    self.getFaceBookUserInfo(user)
                    
                } else {
                    
                    self.performSegueWithIdentifier("loginVCtoTabBarControllerSegue", sender: self)
                }
                
            } else {
                
                
                for subView in self.view.subviews {
                    
                    subView.hidden = false
                }

                
                print("Uh oh. The user cancelled the Facebook login.")
            }
        }

    }
    
    func getFaceBookUserInfo(user: PFUser) {
        
        FBSDKGraphRequest.init(graphPath: "/me", parameters: ["fields": "id,name,email,first_name,friends"], HTTPMethod: "GET").startWithCompletionHandler { (connection, result, error) -> Void in
                        
            if result.valueForKey("first_name") != nil {
                
                user["displayName"] = result.valueForKey("first_name") as! String
            }
            
            if result.valueForKey("email") != nil {
                
                user.email = result.valueForKey("email") as? String
                user.username = result.valueForKey("email") as? String
            }
            
            if result.valueForKey("friends") != nil {
                
                
                var index = 0
                
                let friendsArray: AnyObject? = result.valueForKey("friends")?.valueForKey("data")
                
                while index < friendsArray?.count {
                    
                    let userID = friendsArray?[index].valueForKey("id") as! String
                    
                    self.userFriendsArray.append(userID)
                    index += 1
                }
            }
            
            
            user["friendsArray"] = self.userFriendsArray
            
            let imageUrl = NSURL(string: "https://graph.facebook.com/\(result.valueForKey("id")!)/picture?type=large&return_ssl_resources=1")
            let imageFile = PFFile(data: NSData(contentsOfURL: imageUrl!)!)
            user["userImgage"] = imageFile
            
            user.saveInBackgroundWithBlock({ (succes, error) -> Void in
                
                if error != nil {
                    
                    print(error?.localizedDescription)
                    
                } else {
                    
                    // todo rating nakijken ook bij creeren account
                    
                    let object = PFObject(className: "UserRating")
                    object["user"] = user
                    object["totalRating"] = 1
                    object["numberOfRatings"] = 1
                    object["rating"] = 1
                    object.saveInBackgroundWithBlock({ (succeeded, error ) -> Void in
                        
                        if succeeded == true {
                            
                            // set first distance for search
                            NSUserDefaults.standardUserDefaults().setInteger(50, forKey: "distanceForSearch")
                            NSUserDefaults.standardUserDefaults().synchronize()
                            
                            self.performSegueWithIdentifier("loginVCtoTabBarControllerSegue", sender: self)
                        }
                    })
                    
                }
            })
        }
        
    }
    
    
    @IBAction func userLoginButtonPressed(sender: AnyObject) {
            
        PFUser.logInWithUsernameInBackground(userNameTextField.text!, password: userPassWordTextField.text!) {
           
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                // Do stuff after successful login.
                                
                self.performSegueWithIdentifier("loginVCtoTabBarControllerSegue", sender: self)
                
                
            } else {
                
                // The login failed. Check error to see why.
                
                let alertController = UIAlertController(title: "Oh oh", message: "Verkeerde combinatie van wachtwoord en gebruikersnaam", preferredStyle: .Alert)
                let action = UIAlertAction(title: "Oke", style: .Default, handler: nil)
                let forgotAction = UIAlertAction(title: "Ik ben me wachtwoord vergeten", style: .Default, handler: { (action) -> Void in
                    
                    PFUser.requestPasswordResetForEmailInBackground(self.userNameTextField.text!, block: { (succes, error ) -> Void in
                        
                        if error != nil {
                            
                            print(error?.localizedDescription)
                            
                        } else{
                            
                            if succes == true {
                                
                                // set first distance for search
                                NSUserDefaults.standardUserDefaults().setInteger(50, forKey: "distanceForSearch")
                                NSUserDefaults.standardUserDefaults().synchronize()
                                
                                self.userNameTextField.resignFirstResponder()
                                self.userPassWordTextField.resignFirstResponder()
                            }
                        }
                    })
                    
                })
                
                alertController.addAction(forgotAction)
                alertController.addAction(action)
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        
    }

    @IBAction func UserCreateAccountButtonPressed(sender: AnyObject) {
        
        self.performSegueWithIdentifier("loginVCtoCreateAccountVCsegue", sender: self)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }

}

