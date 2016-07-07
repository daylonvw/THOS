//
//  JobSeekerTabbarController.swift
//  THOS
//
//  Created by daylonvanwel on 15-02-16.
//  Copyright © 2016 daylon wel. All rights reserved.
//

import UIKit

class JobSeekerTabbarController: UITabBarController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.tintColor = UIColor.darkGrayColor()
        
        
        for item in self.tabBar.items! {
            
            item.setTitleTextAttributes([NSFontAttributeName : UIFont.systemFontOfSize(14.0)], forState: .Normal)
            item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)

        }
        
        NSNotificationCenter.defaultCenter().addObserverForName("messageFromJobPosterRecieved", object: nil, queue: nil) { (notification) -> Void in
            
            self.setNewMessageIcon()
        }


        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setNewMessageIcon() {
        
        var items = self.tabBar.items as Array!
        
        let item = items[1]
        item.image = UIImage(named: "newMessageIcon")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        item.selectedImage = UIImage(named: "newMessageIcon")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)

        
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        
        var items = self.tabBar.items as Array!
        let messageItem = items[1]
        
        
        if messageItem == item {
            
            item.image = UIImage(named: "toolIcon")
            item.selectedImage = UIImage(named: "toolIcon")

        }
        
    }
    
    func checkForMewChats() {
        
        let chatQuery = PFQuery(className: "Chat")
        chatQuery.whereKey("isRead", equalTo: false)
        chatQuery.whereKey("toUser", equalTo: PFUser.currentUser()!)
        chatQuery.findObjectsInBackgroundWithBlock { (objects, error) in
            
            if error != nil {
                
                print(error)
                
            } else {
                
                if objects?.count > 0 {
                    
                    self.setNewMessageIcon()
                    
                } else {
                    
                    var items = self.tabBar.items as Array!
                    let item = items[1]
                    
                    item.image = UIImage(named: "toolIcon")
                    item.selectedImage = UIImage(named: "toolIcon")
                    
                }
            }
            
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
 