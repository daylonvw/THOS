//
//  CreateJobViewController.swift
//  Jobie
//
//  Created by daylonvanwel on 05-02-16.
//  Copyright © 2016 daylon wel. All rights reserved.
//

import UIKit

class CreateJobViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var jobDescriptionTextView: UITextView!
    @IBOutlet var postJobButton: UIButton!
    @IBOutlet var currentPostionButton: UIButton!
    @IBOutlet var priceTextField: UITextField!
    
    let locationManager = CLLocationManager()
    var jobPFGeoPoint: PFGeoPoint!
    
    var cloudImage: UIImageView!
    
    var allRequiredJobInfoEntered: Bool!
    
    var jobType: Int!
    var jobSubType: Int!
    
    var missingItemsArray = [String]()
    var missingItemsString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set delegates
        self.jobDescriptionTextView.delegate = self
        self.priceTextField.delegate = self
        
        jobDescriptionTextView.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        jobDescriptionTextView.textColor = UIColor.darkGrayColor()
        jobDescriptionTextView.font = UIFont.systemFontOfSize(20, weight: UIFontWeightMedium)
        jobDescriptionTextView.placeholder = "Typ hier de opdrachtomschrijving"
        jobDescriptionTextView.layer.borderColor = UIColor.ThosColor().CGColor
        jobDescriptionTextView.layer.borderWidth = 1.0

        priceTextField.layer.borderColor = UIColor.ThosColor().CGColor
        priceTextField.layer.borderWidth = 1.0

        allRequiredJobInfoEntered = true
        
        let dismissViewButton = UIButton(frame: CGRect(x: 10, y: view.frame.size.height - 60, width: 60, height: 60))
        dismissViewButton.setTitle("Annuleer", forState: .Normal)
        dismissViewButton.setTitleColor(UIColor.ThosColor(), forState: .Normal)
        dismissViewButton.titleLabel?.adjustsFontSizeToFitWidth = true
        dismissViewButton.addTarget(self, action: #selector(self.dismissViewButtonPressed), forControlEvents: .TouchUpInside)
        
        view.addSubview(dismissViewButton)
      
        getlocation()

        
        NSNotificationCenter.defaultCenter().addObserverForName("openedWitdPushFromJobHelper", object: nil, queue: nil) { (notification: NSNotification) -> Void in
            
            self.openChatFromNotification(notification)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(true)
        
        self.checkForMewChats()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    
    @IBAction func postJobButtonPressed(sender: AnyObject) {
        
       self.checkForRequiredInfo()

    }
        
    func checkForRequiredInfo() {
        
        if jobDescriptionTextView.text == "" {
        
            self.allRequiredJobInfoEntered = false
            self.missingItemsArray.append("opdrachtomschrijving")
        }
        
        if self.jobPFGeoPoint == nil {
            
            self.allRequiredJobInfoEntered = false
            self.missingItemsArray.append("Opdracht locatie")

        }
        
        let priceString = self.priceTextField.text!
        
        if priceString == "" || priceString == "€" || priceString == "€ " {
            
            self.allRequiredJobInfoEntered = false
            self.missingItemsArray.append("opdracht prijs")

        }
        
        if self.allRequiredJobInfoEntered == true {
            
            self.postJobToServer()
            
        } else {
            
            self.allRequiredJobInfoEntered = true
            
            self.openalertViewController("")
        }
        
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
    
        if self.priceTextField.text! != "" && self.priceTextField.text! != "€ " {
            
            let priceString = self.priceTextField.text!
            
            let indexStartOfText = priceString.startIndex.advancedBy(2)
            
            let PriceSubString = priceString.substringFromIndex(indexStartOfText)

            let price: Int = Int(PriceSubString)!
            
            job["price"] = NSNumber(integer: price)
            
            
        }
        
        if self.jobPFGeoPoint != nil {
            
            job["jobLocation"] = self.jobPFGeoPoint
            
        }
        
        if self.jobDescriptionTextView.text != "" {
            
            job["jobDescription"] = self.jobDescriptionTextView.text
            
        }
        
        job["user"] = PFUser.currentUser()!
        job["userId"] = PFUser.currentUser()?.objectId
        job["open"] = true
        job["finished"] = false
        job["maxUsersReached"] = false
        job["posterAcceptedDate"] = false
        job["helperAcceptedDate"] = false
        job["posterReadLastText"] = false
        job["helperReadLastText"] = false

        job.saveInBackgroundWithBlock { (succes, error) -> Void in
            
            if error != nil {
                
                print(error?.localizedDescription)
                
            } else {
                
                if succes == true {
                    
                    self.animatePostButton()
                    self.sendNearByPush()
                }
            }
        }

        
    }
    
    func sendNearByPush() {
        // todo
        
        let pushQuery = PFInstallation.query()
        pushQuery?.whereKey("installationId", notEqualTo:PFInstallation().installationId)
        pushQuery?.whereKey("location", nearGeoPoint: self.jobPFGeoPoint, withinKilometers: 100)
        
        let dataDIC:[String: AnyObject] = [
            
            "alert"             : "Nieuwe opdracht in de buurt",
            "type"              : "new job",
            "badge"             : "increment",
            "sound"             : "message-sent.aiff"
        ]
        
        let push = PFPush()
        
        push.setQuery(pushQuery)
        push.setData(dataDIC)
        push.sendPushInBackground()

    }
    
    
    func resetUI() {
        
        self.jobDescriptionTextView.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        self.jobDescriptionTextView.textColor = UIColor.darkGrayColor()
        self.jobDescriptionTextView.text = ""
        
        self.priceTextField.text = ""
        
        self.jobDescriptionTextView.hidden = false
        self.priceTextField.hidden = false
        
        self.postJobButton.alpha = 1.0
        
        self.cloudImage.removeFromSuperview()

        self.missingItemsArray.removeAll(keepCapacity: true)
        self.missingItemsString = ""

    }
    
    
    func animatePostButton() {
        
        self.jobDescriptionTextView.hidden = true
        self.priceTextField.hidden = true
        
        
        cloudImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 250, height: 230))
        cloudImage.center = CGPointMake(view.center.x, 150)
        cloudImage.image = UIImage(named: "cloudImage")
        cloudImage.layer.shadowColor = UIColor.blackColor().CGColor
        cloudImage.layer.shadowOffset = CGSizeMake(1.0, 1.0)
        cloudImage.layer.shadowOpacity = 0.8
        self.view.addSubview(cloudImage)

        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: self.postJobButton.center.x,y: self.postJobButton.center.y))
       
        path.addCurveToPoint(CGPoint(x: self.view.center.x,y: 30), controlPoint1: CGPoint(x: view.frame.width - 20, y: view.center.y), controlPoint2: CGPoint(x: 10, y: 110))
        
        // create a new CAKeyframeAnimation that animates the objects position
        let anim = CAKeyframeAnimation(keyPath: "position")
        
        // set the animations path to our bezier curve
        anim.path = path.CGPath
        
        anim.repeatCount = 1.0
        anim.duration = 1.5
        
        self.postJobButton.layer.addAnimation(anim, forKey: "animate position along path")
        
        UIView.animateWithDuration(1.5, animations: { () -> Void in
           
            self.postJobButton.alpha = 0.0
            
            }) { (finished) -> Void in
             
                self.resetUI()
        }


    }
    
    func getlocation() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    
// cllocatationManagerDelagateFunctions
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locationManager.stopUpdatingLocation()
            
        self.jobPFGeoPoint = PFGeoPoint(location: locationManager.location)
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: self.jobPFGeoPoint.latitude, longitude: self.jobPFGeoPoint.longitude)
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // City
            if let city = placeMark.addressDictionary!["City"] as? NSString {
                
                self.currentPostionButton.setTitle("Opdracht locatie is \(city)", forState: .Normal)
                
                print(city)
            }

        })
    
        let installation = PFInstallation.currentInstallation()
        
        if PFUser.currentUser() != nil {
            
            installation["location"] = self.jobPFGeoPoint
            
        }
        
        installation.saveInBackground()

    
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print("failed location")
        
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        print("changed")
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
            
            self.priceTextField.text = ""
            self.priceTextField.resignFirstResponder()
            
        } else {
           
            self.priceTextField.text = "€ \(priceString)"
            self.priceTextField.resignFirstResponder()
        }
    }
    
    // todo check for new chats to new viewController "selectnewjobViewController"
 
    func checkForMewChats() {
    
//        let tabBarController = self.parentViewController as! HelpSeekerTabbarControllerViewController
//        tabBarController.checkForMewChats()

    }
    
    func openChatFromNotification(notification: NSNotification) {
        
        let query = PFQuery(className: "Job")
        query.whereKey("objectId", equalTo: notification.object as! String)
        query.getFirstObjectInBackgroundWithBlock { (object, error) in
            if error != nil {
                
                print(error)
                
            } else {
                
                let storyBoard  = UIStoryboard(name: "Main", bundle: nil)
                
                let chatController = storyBoard.instantiateViewControllerWithIdentifier("postedJobsChatController") as! JobChatViewController
                
                chatController.jobId = object!.objectId
                chatController.jobGeoPoint = object!.valueForKey("jobLocation") as! PFGeoPoint
                chatController.jobDescription = object!.valueForKey("jobDescription") as! String
                chatController.job = object!

                
                self.presentViewController(chatController, animated: true, completion: nil)

            }
        }
    }
    
    func dismissViewButtonPressed() {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
