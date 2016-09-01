//
//  SHowUserProfileViewController.swift
//  THOS
//
//  Created by daylonvanwel on 01-09-16.
//  Copyright © 2016 daylon wel. All rights reserved.
//

import UIKit

class SHowUserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var userImage: UIImage!
    var userName: String!
    var user: PFUser!
    
    var width: CGFloat!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        width = view.frame.width

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        for view in cell.subviews {
            
            if view.isKindOfClass(UIImageView) {
                
                view.removeFromSuperview()
                
            }
        }
        
        if indexPath.row == 3 {
            
            cell.accessoryType = .DisclosureIndicator
            cell.textLabel?.font = UIFont(name: "OpenSans", size: 18)
        }
        
        if indexPath.row == 0 {
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 200))
            imageView.contentMode = .ScaleAspectFill
            imageView.image  = userImage
            cell.addSubview(imageView)
            
            
        } else if indexPath.row == 1 {
                
                let nameLabel = UILabel(frame: CGRect(x: 35.0, y: 20.0, width: width - 70, height: 50))
                nameLabel.text = user["displayName"] as? String
                nameLabel.textAlignment = .Left
                nameLabel.font = UIFont(name: "OpenSans-Semibold", size: 32)
                nameLabel.textColor = UIColor.darkGrayColor()
                
                let facebookButton = UIButton(frame: CGRect(x: 35, y: 90, width: 50, height: 50))
                facebookButton.setImage(UIImage(named: "whiteFacebook"), forState: .Normal)
                
                let likeButton = UIButton(frame: CGRect(x: 95, y: 90, width: 50, height: 50))
                likeButton.setImage(UIImage(named: "whiteLike"), forState: .Normal)
                
                let likecountLabel = UILabel(frame: CGRect(x: 155, y: 90, width: 80, height: 50))
                likecountLabel.text = "10 X"
                likecountLabel.font = UIFont(name: "OpenSans", size: 32)
                likecountLabel.textColor = UIColor(red: 236.0/155.0, green: 121.0/155.0, blue: 132.0/155.0, alpha: 1.0)
                
                                cell.addSubview(likecountLabel)
                cell.addSubview(likeButton)
                cell.addSubview(facebookButton)
                cell.addSubview(nameLabel)
                
            } else if indexPath.row == 2 {
                
                let descriptionTextView = UITextView(frame: CGRect(x: 35, y: 20, width: width - 70, height: 100))
                descriptionTextView.text = "Heeft u snel een elektricien in Almere nodig? Dan bent u mij op het juiste adres."
                descriptionTextView.textColor = UIColor.darkGrayColor()
                descriptionTextView.font = UIFont(name: "OpenSans-Light", size: 20)
                descriptionTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
                descriptionTextView.layer.borderWidth = 0.5
                descriptionTextView.layer.cornerRadius = 4.0
                
                cell.addSubview(descriptionTextView)

                
            } else if indexPath.row == 3 {
                
                cell.textLabel?.text = "Advertenties"
                cell.imageView?.image = UIImage(named: "myAds")
                
                
            } else if indexPath.row == 4 {
                
                // portfolio
            
            } else if indexPath.row == 5 {
                
                let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue, NSForegroundColorAttributeName: UIColor.ThosColor(),NSFontAttributeName: UIFont(name: "OpenSans", size: 22.0)!]
                let underlineAttributedString = NSAttributedString(string: "Stuur bericht", attributes: underlineAttribute)
                cell.textLabel?.attributedText = underlineAttributedString
                
            } else if indexPath.row == 6 {
            
                let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue, NSForegroundColorAttributeName: UIColor.redColor(), NSFontAttributeName: UIFont(name: "OpenSans", size: 16.0)!]
                let underlineAttributedString = NSAttributedString(string: "Blokkeer", attributes: underlineAttribute)
                cell.textLabel?.attributedText = underlineAttributedString
                
            } else if indexPath.row == 7 {

            }
        
        return cell
        
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == 0 || indexPath.row == 2 {
            
            return 200
            
        } else if indexPath.row == 1  || indexPath.row == 4 {
            
            return 160
            
        }  else {
            
            return 50
            
        }
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
