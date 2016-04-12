//
//  helpSeekerProfileViewController.swift
//  Jobie
//
//  Created by daylonvanwel on 05-02-16.
//  Copyright © 2016 daylon wel. All rights reserved.
//

import UIKit

class helpSeekerProfileViewController: UIViewController {
    
    
    // looking for help
    @IBOutlet var userProfileImageView: UIImageView!
    @IBOutlet var backgroundImageView: UIImageView!
    
    
    var ratingView: FloatRatingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userProfileImageView.clipsToBounds = true
        self.userProfileImageView.layer.cornerRadius = 60
        
        let userQuery = PFUser.query()
        userQuery?.whereKey("objectId", equalTo: PFUser.currentUser()!.objectId!)
        userQuery?.getFirstObjectInBackgroundWithBlock({ (user , error ) -> Void in
            
            if error != nil {
                
                // something went wrong
                
            } else {
                
                let file = user!["userImgage"] as! PFFile
                file.getDataInBackgroundWithBlock({ (data, error) -> Void in
                
                    if error != nil {
                        
                        // something went wrong
                    } else {
                        
                        self.userProfileImageView.image = UIImage(data: data!)
//                        let tintColor = UIColor(red: 150.0/255.0, green: 179.0/255.0, blue: 188.0/255.0, alpha: 0.7)
                        
//                        let bluredImage = UIImage(data: data!)?.applyLightEffect()
                        
//                        self.backgroundImageView.image = bluredImage
                        
                    

                    }
                })
                
                
            }
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let query = PFQuery(className: "UserRating")
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.getFirstObjectInBackgroundWithBlock({ (object , error ) -> Void in
            
            if error != nil {
                
                print(error?.localizedDescription)
            } else {
                                
                self.ratingView = FloatRatingView(frame: CGRect(x: 0, y: 0, width: 200, height: 60))

                let rating = object!["rating"] as! NSNumber
                self.ratingView.rating = Float(rating)
                self.ratingView.center = CGPointMake(self.view.center.x,  200)
                self.ratingView.editable = false
                self.ratingView.minRating = 1
                self.ratingView.maxRating = 5
                self.ratingView.fullImage = UIImage(named: "starFull")
                self.ratingView.emptyImage = UIImage(named: "starEmpty")
                
                self.view.addSubview(self.ratingView)

            }
        })

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        
        PFUser.logOutInBackgroundWithBlock { (error) -> Void in
           
            if error != nil {
                
                print("not logged out")
                
            } else {
                
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyBoard.instantiateViewControllerWithIdentifier("loginVC")
                
                self.presentViewController(controller, animated: true, completion: nil)

            }
        }
        
    }

    @IBAction func switchUserTypeButtonPressed(sender: AnyObject) {
        
        
        PFUser.currentUser()?.setValue("helper", forKey: "userType")
        PFUser.currentUser()?.saveInBackground()
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewControllerWithIdentifier("SeekingJobTabbarVC")
        
        self.presentViewController(controller, animated: true, completion: nil)

    }
    
    @IBAction func feedBackButtonPressed(sender: AnyObject) {
        
        
        let feedBackVC = FeedBackController()
        feedBackVC.title = "Feedback"
        feedBackVC.placeholder = "Be gentle"
        feedBackVC.completionHandler = {
            
            // tupple returned by the completion handeler ( composeViewController
            (result, text) in
            
            switch result {
                
            case .Cancel: print("cancel")
                
            case .Post:
                
                self.sendFeedbackButtonPressed(feedBackVC.textView.text)
                
            }
            
        }
        
        
        
        feedBackVC.modalPresentationStyle = .OverCurrentContext
        
        presentViewController(feedBackVC, animated: true, completion: nil)

    }
    
    
    func sendFeedbackButtonPressed(text: String) {
        
        
        let feedbackText = text
        let object = PFObject(className: "Feedback")
        
        object.setObject(feedbackText, forKey:"feedback")
        object.setObject(PFUser.currentUser()!, forKey: "user")
        object.saveInBackground()
        
        // create uialertController
        
//        let alert = UIAlertView(title:NSLocalizedString("Thank you", comment: ""), message:NSLocalizedString("We appreciate the feedback", comment: ""), delegate: self, cancelButtonTitle: "OK")
//        alert.alpha = 0.9
//        alert.opaque = true
//        
//        alert.show()
        
    }

}
