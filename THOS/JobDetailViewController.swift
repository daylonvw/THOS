//
//  JobDetailViewController.swift
//  THOS
//
//  Created by daylonvanwel on 13-07-16.
//  Copyright © 2016 daylon wel. All rights reserved.
//

import UIKit

class JobDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func sendInterestedPush(job: PFObject) {
        
        let pushQuery = PFInstallation.query()
        pushQuery!.whereKey("user", equalTo: job["user"] as! PFUser)
        let descriptionString = job["jobDescription"] as! String
        
        let dataDIC:[String: AnyObject] = [
            
            "alert"             : "Someone is intersted in your job: \(descriptionString)",
            "type"              : "interested",
            "badge"             : "increment",
            "sound"             : "message-sent.aiff"
        ]
        
        let push = PFPush()
        
        push.setQuery(pushQuery)
        push.setData(dataDIC)
        push.sendPushInBackground()
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
