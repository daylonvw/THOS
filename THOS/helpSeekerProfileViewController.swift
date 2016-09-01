//
//  helpSeekerProfileViewController.swift
//  Jobie
//
//  Created by daylonvanwel on 05-02-16.
//  Copyright © 2016 daylon wel. All rights reserved.
//

import UIKit

class helpSeekerProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet var tableView: UITableView!
    // looking for help
    
    
    var ratingView: FloatRatingView!
    var userImage: UIImage!
    
    var width: CGFloat!
    
    override func viewDidLoad() {
      
        super.viewDidLoad()
        
        width = view.frame.width
        

    }
    
    override func viewWillAppear(animated: Bool) {
    
        
//        let query = PFQuery(className: "UserRating")
//        query.whereKey("user", equalTo: PFUser.currentUser()!)
//        query.getFirstObjectInBackgroundWithBlock({ (object , error ) -> Void in
//            
//            if error != nil {
//                
//                print(error?.localizedDescription)
//            } else {
//                                
//                self.ratingView = FloatRatingView(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
//
//                let rating = object!["rating"] as! NSNumber
//                self.ratingView.rating = Float(rating)
//                self.ratingView.center = CGPointMake(self.view.center.x,  200)
//                self.ratingView.editable = false
//                self.ratingView.minRating = 1
//                self.ratingView.maxRating = 5
//                self.ratingView.fullImage = UIImage(named: "starFull")
//                self.ratingView.emptyImage = UIImage(named: "starEmpty")
//                
//                self.view.addSubview(self.ratingView)
//
//            }
//        })
//
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
                
        if indexPath.row == 0 {
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 200))
            imageView.contentMode = .ScaleAspectFill
            cell.addSubview(imageView)
            
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
                            
                            self.userImage = UIImage(data: data!)
                            imageView.image = self.userImage
                            
                            
                        }
                    })
                    
                    
                }
            })

            
        } else if indexPath.row != 0 {
            
        
        
        if indexPath.row > 1 && indexPath.row < 6 {
            
            cell.accessoryType = .DisclosureIndicator
            cell.textLabel?.font = UIFont(name: "OpenSans", size: 18)
        }
        
        if indexPath.row == 1 {
            
            let nameLabel = UILabel(frame: CGRect(x: 35.0, y: 20.0, width: width - 70, height: 50))
            nameLabel.text = PFUser.currentUser()!["displayName"] as? String
            nameLabel.textAlignment = .Left
            nameLabel.font = UIFont(name: "OpenSans-Semibold", size: 32)
            nameLabel.textColor = UIColor.darkGrayColor()
            
            let facebookButton = UIButton(frame: CGRect(x: 35, y: 90, width: 50, height: 50))
            facebookButton.setImage(UIImage(named: "blueFacebook"), forState: .Normal)
            
            let likeButton = UIButton(frame: CGRect(x: 95, y: 90, width: 50, height: 50))
            likeButton.setImage(UIImage(named: "pinkLike"), forState: .Normal)
            
            let likecountLabel = UILabel(frame: CGRect(x: 155, y: 90, width: 80, height: 50))
            likecountLabel.text = "10 X"
            likecountLabel.font = UIFont(name: "OpenSans", size: 32)
            likecountLabel.textColor = UIColor(red: 236.0/155.0, green: 121.0/155.0, blue: 132.0/155.0, alpha: 1.0)
            
            let descriptionTextView = UITextView(frame: CGRect(x: 35, y: 160, width: width - 70, height: 110))
            descriptionTextView.text = "Heeft u snel een elektricien in Almere nodig? Dan bent u mij op het juiste adres."
            descriptionTextView.textColor = UIColor.darkGrayColor()
            descriptionTextView.font = UIFont(name: "OpenSans-Light", size: 20)
            descriptionTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
            descriptionTextView.layer.borderWidth = 0.5
            descriptionTextView.layer.cornerRadius = 4.0

            cell.addSubview(descriptionTextView)
            cell.addSubview(likecountLabel)
            cell.addSubview(likeButton)
            cell.addSubview(facebookButton)
            cell.addSubview(nameLabel)
            
        } else if indexPath.row == 2 {
            
            cell.textLabel?.text = "Mijn advertenties"
            cell.imageView?.image = UIImage(named: "myAds")
            
        } else if indexPath.row == 3 {
            
            cell.textLabel?.text = "Voltooide advertenties"
            cell.imageView?.image = UIImage(named: "completedAds")

        } else if indexPath.row == 4 {
            
            cell.textLabel?.text = "Bewaarde advertenties"
            cell.imageView?.image = UIImage(named: "savedAds")

        } else if indexPath.row == 5 {
            
            cell.textLabel?.text = "Berichten"
            cell.imageView?.image = UIImage(named: "messages")

        } else if indexPath.row == 7 {
          
            
            for view in cell.subviews {
                
                if view.isKindOfClass(UIImageView) {
                    
                    view.removeFromSuperview()
                }
                
            }
            let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue, NSForegroundColorAttributeName: UIColor.ThosColor(),NSFontAttributeName: UIFont(name: "OpenSans", size: 22.0)!]
            let underlineAttributedString = NSAttributedString(string: "Opmerkingen", attributes: underlineAttribute)
            cell.textLabel?.attributedText = underlineAttributedString
            
        } else if indexPath.row == 8 {
            
            let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue, NSForegroundColorAttributeName: UIColor.ThosColor(), NSFontAttributeName: UIFont(name: "OpenSans", size: 22.0)!]
            let underlineAttributedString = NSAttributedString(string: "Uitloggen", attributes: underlineAttribute)
            cell.textLabel?.attributedText = underlineAttributedString
        }


        }
  
        
        return cell

        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            
            return 200
            
        } else if indexPath.row == 1 {
            
            return 280
            
        } else if indexPath.row == 6 {
            
            return 200
            
        } else {
    
        return 50
            
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == 7 {
            
            feedBackButtonPressed()
            
        } else if indexPath.row == 8 {
            
            logoutButtonPressed()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func logoutButtonPressed() {
        
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
    
    func feedBackButtonPressed() {
        
        
        let feedBackVC = FeedBackController()
        feedBackVC.title = "Feedback"
        feedBackVC.placeholder = "We waarderen je feedback"
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

    }
    
}
