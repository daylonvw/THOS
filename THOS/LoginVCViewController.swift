//
//  ViewController.swift
//  Jobie
//
//  Created by daylonvanwel on 05-02-16.
//  Copyright © 2016 daylon wel. All rights reserved.
//

import UIKit
import ParseFacebookUtilsV4

class LoginVCViewController: UIViewController {

    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var userPassWordTextField: UITextField!
    
    @IBOutlet var userLoginButton: UIButton!
    @IBOutlet var userCreateNewAccountButton: UIButton!
    @IBOutlet var facebookLoginButton: UIButton!
    
    @IBOutlet var userTypeSegmentedControl: UISegmentedControl!
    
    
    var userFriendsArray = [String]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let loginButton = FBSDKLoginButton()
        loginButton.center = CGPointMake(view.center.x, view.center.y + 200)
        
        facebookLoginButton.setTitle(" Login with Facebook", forState: .Normal)
        facebookLoginButton.setImage(loginButton.imageView?.image, forState: .Normal)
        facebookLoginButton.setBackgroundImage(loginButton.backgroundImageForState(.Normal), forState: .Normal)
    
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func faceBookLoginPressed() {
        
        let permissionsArray = ["public_profile", "email", "user_friends"]
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissionsArray) {
            (user: PFUser?, error: NSError?) -> Void in
           
            if let user = user {
               
                if user.isNew {
                  
                    self.showUserTypeSegmentedControlfor(user)
                    print("User signed up and logged in through Facebook!")
                    
                } else {
                    
                    self.performSegueWithIdentifier("loginVCtoTabBarControllerSegue", sender: self)
                    print("User logged in through Facebook!")
                }
                
            } else {
                
                print("Uh oh. The user cancelled the Facebook login.")
            }
        }
    }
    
    func showUserTypeSegmentedControlfor(user: PFUser) {
        
        for subView in self.view.subviews {
            
            if subView.hidden == false {
                
                subView.hidden = true
                
            } else if subView.hidden == true {
                
                subView.hidden = false
            }
        }

    }
    
    @IBAction func segmentedControlValeuChanged(sender: AnyObject) {
        
        if self.userTypeSegmentedControl.selectedSegmentIndex == 0 {
            
            PFUser.currentUser()!["userType"] = "seeker"
            self.getFaceBookUserInfo(PFUser.currentUser()!)

            
        } else if self.userTypeSegmentedControl.selectedSegmentIndex == 1 {
            
            PFUser.currentUser()!["userType"] = "helper"
            self.getFaceBookUserInfo(PFUser.currentUser()!)

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
            
//            user["userType"] = "seeker"

            user.saveInBackgroundWithBlock({ (succes, error) -> Void in
                
                if error != nil {
                    
                    print(error?.localizedDescription)
                    
                } else {
                    
                    let object = PFObject(className: "UserRating")
                    object["user"] = user
                    object["totalRating"] = 5
                    object["numberOfRatings"] = 1
                    object["rating"] = 3
                    object.saveInBackgroundWithBlock({ (succeeded, error ) -> Void in
                        
                        if succeeded == true {
                            
                            // set first distance for search
                            NSUserDefaults.standardUserDefaults().setInteger(50, forKey: "distanceForSearch")
                            NSUserDefaults.standardUserDefaults().synchronize()
                            
                            // creation complete.. go to job screen
                            if user["userType"] as! String == "seeker" {
                                
                                self.performSegueWithIdentifier("loginVCtoTabBarControllerSegue", sender: self)
                                
                            } else if user["userType"] as! String == "helper" {
                                
                                self.performSegueWithIdentifier("loginVCToSeekerSegue", sender: self)
                                
                            }

                            
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
                
                let alertController = UIAlertController(title: "Oh oh", message: "username password combination unknown", preferredStyle: .Alert)
                let action = UIAlertAction(title: "Oke", style: .Default, handler: nil)
                let forgotAction = UIAlertAction(title: "forgot my password", style: .Default, handler: { (action) -> Void in
                    
                    PFUser.requestPasswordResetForEmailInBackground(self.userNameTextField.text!, block: { (succes, error ) -> Void in
                        
                        if error != nil {
                            
                            print(error?.localizedDescription)
                        } else{
                            
                            if succes == true {
                                
                                print("succes")
                                
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
}

