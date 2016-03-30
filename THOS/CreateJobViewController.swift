//
//  CreateJobViewController.swift
//  Jobie
//
//  Created by daylonvanwel on 05-02-16.
//  Copyright © 2016 daylon wel. All rights reserved.
//

import UIKit    

class CreateJobViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, JSImagePickerViewControllerDelegate {

    
    @IBOutlet var jobDescriptionTextView: UITextView!
    @IBOutlet var postJobButton: UIButton!
    @IBOutlet var jobLocationSegmentedControl: UISegmentedControl!
    @IBOutlet var addImagebuttton: UIButton!
    @IBOutlet var priceTextField: UITextField!
    
    
    @IBOutlet var houseKeepingButton: UIButton!
    @IBOutlet var labourButton: UIButton!
    
    let locationManager = CLLocationManager()
    var jobPFGeoPoint: PFGeoPoint!
    var jobImage: UIImage!
    var jobImageView: UIImageView!
    
    var cloudImage: UIImageView!
    
    var allRequiredJobInfoEntered: Bool!
    
    var jobType: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // set delegates
        self.jobDescriptionTextView.delegate = self
        self.priceTextField.delegate = self
        
        self.jobLocationSegmentedControl.state
        
        self.postJobButton.layer.cornerRadius = 40
        self.postJobButton.layer.shadowColor = UIColor.blackColor().CGColor
        self.postJobButton.layer.shadowOffset = CGSizeMake(1.0, 1.0)
        self.postJobButton.layer.shadowOpacity = 0.8

        jobDescriptionTextView.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        jobDescriptionTextView.textColor = UIColor.darkGrayColor()
        jobDescriptionTextView.font = UIFont.systemFontOfSize(20, weight: UIFontWeightMedium)
        jobDescriptionTextView.placeholder = "Job description..."
        jobDescriptionTextView.layer.borderColor = UIColor.ThosColor().CGColor
        jobDescriptionTextView.layer.borderWidth = 1.0
        
        jobImageView = UIImageView(frame: CGRect(x: 10, y: 30, width: view.frame.width - 20, height: 150))
        jobImageView.contentMode = .ScaleAspectFill
        jobImageView.clipsToBounds = true
        view.addSubview(jobImageView)
        view.sendSubviewToBack(jobImageView)
        
        priceTextField.layer.borderColor = UIColor.ThosColor().CGColor
        priceTextField.layer.borderWidth = 1.0

        
        jobLocationSegmentedControl.layer.cornerRadius = 4
        addImagebuttton.layer.cornerRadius = 4
        
        allRequiredJobInfoEntered = true
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func jobLocation(sender: AnyObject) {
        
        let segmentenControl = sender as! UISegmentedControl
        
        if segmentenControl.selectedSegmentIndex == 0 {
            
            getlocation()
        
        } else if segmentenControl.selectedSegmentIndex == 1 {
            
            let controller = UIAlertController(title: "Enter zipcode", message: "for job location", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in
                
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            
            
            let action = UIAlertAction(title: "Use", style: .Default, handler: { (action) -> Void in
                
                let textField = controller.textFields![0]
                var zipCodeText = textField.text!
                
                var index = 0
                for character in zipCodeText.characters {
                    
                    if character == " " {
                        
                        zipCodeText.removeAtIndex(zipCodeText.startIndex.advancedBy(index))
                        
                        index -= 1

                    }
                    
                    index += 1
                }
                
                print(zipCodeText)
                
                let zipCode = NSURL(string: "https://maps.googleapis.com/maps/api/geocode/json?address=\(zipCodeText)&sensor=true")
                
                let downloadTask = NSURLSession.sharedSession().dataTaskWithURL(zipCode!, completionHandler: { (data , responce, error) -> Void in
                    
                    do {
                        
                        let dict = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)

                        let locationArray = dict.valueForKey("results")?.valueForKey("geometry")?.valueForKey("location")
                        
                        if locationArray!.count == 1 {
                        
                            let latitude = locationArray?.objectAtIndex(0).valueForKey("lat")
                            let longtitude = locationArray?.objectAtIndex(0).valueForKey("lng")
                        
                            self.jobPFGeoPoint = PFGeoPoint(latitude: Double(latitude! as! NSNumber), longitude: Double(longtitude! as! NSNumber))
                            
                        } else {
                            
                            let controller = UIAlertController(title: "Zipcode not found", message: "Please try again", preferredStyle: .Alert)
                            let ok = UIAlertAction(title: "Ok", style: .Default, handler: { (action) -> Void in
                                
                                self.dismissViewControllerAnimated(true, completion: nil)
                            })
                            
                            controller.addAction(ok)
                            
                            self.presentViewController(controller, animated: true, completion: nil)
                        }

                    } catch let error as NSError {
                       
                        print(error)
                    }
                    
                    
                    
                })
                
                downloadTask.resume()


            })
            
            controller.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                
                textField.placeholder = "Zipcode"
            })
            
            controller.addAction(cancelAction)
            controller.addAction(action)
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    
    
    @IBAction func postJobButtonPressed(sender: AnyObject) {
        
       self.checkForRequiredInfo()

    }
    

    @IBAction func houseKeepingButtonPressed(sender: AnyObject) {
        
        if sender.tag == 0 {
            
            self.jobType = "houseKeeping"
            
            (sender as! UIButton).tag = 1
            
            self.labourButton.alpha = 0.2
            self.labourButton.userInteractionEnabled = false
            
        } else if sender.tag == 1 {
            
            self.jobType = nil
            
            (sender as! UIButton).tag = 0
            
            self.labourButton.alpha = 1.0
            self.labourButton.userInteractionEnabled = true
        }

    }

    @IBAction func labourButtonSelected(sender: AnyObject) {
        
        if sender.tag == 0 {
            
            self.jobType = "labour"

            (sender as! UIButton).tag = 1
            
            self.houseKeepingButton.alpha = 0.2
            self.houseKeepingButton.userInteractionEnabled = false
            
        } else if sender.tag == 1 {
            
            self.jobType = nil

            (sender as! UIButton).tag = 0
            
            self.houseKeepingButton.alpha = 1.0
            self.houseKeepingButton.userInteractionEnabled = true
        }

    }
    
    func checkForRequiredInfo() {
        
        if jobDescriptionTextView.text == "" {
        
            self.allRequiredJobInfoEntered = false
        }
        
        if self.jobPFGeoPoint == nil {
            
            self.allRequiredJobInfoEntered = false
        }
        
        let priceString = self.priceTextField.text!
        
        if priceString == "" || priceString == "€" || priceString == "€ " {
            
            self.allRequiredJobInfoEntered = false
        }
        
        if jobType == nil {
            
            self.allRequiredJobInfoEntered = false
        }
        
        if self.allRequiredJobInfoEntered == true {
            
            self.postJobToServer()
            
        } else {
            
            self.allRequiredJobInfoEntered = true
            self.openalertViewController("Please enter all requierd items")
        }
        
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
        
        if jobImage != nil {
            
            let file  = PFFile(data: UIImageJPEGRepresentation(self.jobImage, 0.5)!)
            job["jobImage"] = file
            
        }
        
        if self.jobPFGeoPoint != nil {
            
            job["jobLocation"] = self.jobPFGeoPoint
            
        }
        
        if self.jobDescriptionTextView.text != "" {
            
            job["jobDescription"] = self.jobDescriptionTextView.text
            
        }
        
        if self.jobType != nil {
        
            job["jobType"] = self.jobType
        }
        
        job["user"] = PFUser.currentUser()!
        job["userId"] = PFUser.currentUser()?.objectId
        job["open"] = true
        job["finished"] = false
        job["maxUsersReached"] = false
        job["posterAcceptedDate"] = false
        job["helperAcceptedDate"] = false
        
        job.saveInBackgroundWithBlock { (succes, error) -> Void in
            
            if error != nil {
                
                print(error?.localizedDescription)
                
            } else {
                
                if succes == true {
                    
                    self.animatePostButton()
//                    self.sendNearByPush()
                }
            }
        }

        
    }
    
    func sendNearByPush() {
        
        let pushQuery = PFInstallation.query()
        pushQuery?.whereKey("location", nearGeoPoint: self.jobPFGeoPoint, withinKilometers: 100)
        
        let dataDIC:[String: AnyObject] = [
            
            "alert"             : "New jobs nearby",
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
        
        for view in self.jobImageView.subviews {
            
            view.removeFromSuperview()
        }
        
        self.jobPFGeoPoint = nil
        self.jobImageView.image = nil
        self.jobImage = nil
        
        self.priceTextField.text = ""
        self.jobLocationSegmentedControl.selectedSegmentIndex = -1
        
        // remove before real testing
//        job.deleteInBackground()


        self.jobDescriptionTextView.hidden = false
        self.jobImageView.hidden = false
        self.jobLocationSegmentedControl.hidden = false
        self.addImagebuttton.hidden = false
        self.priceTextField.hidden = false
        self.houseKeepingButton.hidden = false
        self.labourButton.hidden = false
        
        self.postJobButton.alpha = 1.0
        
        self.cloudImage.removeFromSuperview()
        
        self.jobType = nil
        self.labourButton.alpha = 1.0
        self.houseKeepingButton.alpha = 1.0
        self.labourButton.userInteractionEnabled = true
        self.houseKeepingButton.userInteractionEnabled = true
        
        

    }
    
    func openalertViewController(missingItem: String) {
        
        let messageString  = "You seem to have forgotten to enter your \(missingItem)"
        let controoler = UIAlertController(title: "Uh oh", message: messageString, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil )
        
        controoler.addAction(okAction)
        
        self.presentViewController(controoler, animated: true, completion: nil)
        
    }

    func animatePostButton() {
        
        self.jobDescriptionTextView.hidden = true
        self.jobImageView.hidden = true
        self.jobLocationSegmentedControl.hidden = true
        self.addImagebuttton.hidden = true
        self.priceTextField.hidden = true
        self.houseKeepingButton.hidden = true
        self.labourButton.hidden = true
        
        
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
    

    
    @IBAction func addImageButtonPressed(sender: AnyObject) {
        
        let controller = JSImagePickerViewController()
        controller.delegate = self
        controller.showImagePickerInController(self)

    }
    

    func imagePicker(imagePicker: JSImagePickerViewController!, didSelectImage image: UIImage!) {
        
        self.jobImage = image
        self.jobImageView.image = image
        
        let layerView = UIView(frame: CGRect(x: 0, y: 0, width: self.jobImageView.frame.width, height: self.jobImageView.frame.height))
        layerView.backgroundColor = UIColor(white: 0.2, alpha: 0.2)
        self.jobImageView.addSubview(layerView)
        
        jobDescriptionTextView.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        jobDescriptionTextView.textColor = UIColor.whiteColor()

        
    }
    
// cllocatationManagerDelagateFunctions
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locationManager.stopUpdatingLocation()
            
        self.jobPFGeoPoint = PFGeoPoint(location: locationManager.location)
        
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
        
//        print("changed")
    }

    
    
// textFieldDelagate
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        return true
    }
    

    
    func textFieldDidBeginEditing(textField: UITextField) {
    
        self.jobDescriptionTextView.userInteractionEnabled = false
        self.jobLocationSegmentedControl.userInteractionEnabled = false
        self.addImagebuttton.userInteractionEnabled = false
        self.houseKeepingButton.userInteractionEnabled = false
        self.labourButton.userInteractionEnabled = false
        
        if textField == self.priceTextField {
            
            let numberToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
            numberToolbar.barStyle = .Default
            numberToolbar.items = [UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(CreateJobViewController.resignNumberpad))]
            numberToolbar.sizeToFit()
            self.priceTextField.inputAccessoryView = numberToolbar
            
        }
    }


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
        self.jobLocationSegmentedControl.userInteractionEnabled = true
        self.addImagebuttton.userInteractionEnabled = true
        self.houseKeepingButton.userInteractionEnabled = true
        self.labourButton.userInteractionEnabled = true
        
        
        let priceString = self.priceTextField.text!
        
        if priceString == "" || priceString == "€" || priceString == "€ " {
            
            self.priceTextField.text = ""
            self.priceTextField.resignFirstResponder()
            
        } else {
           
            self.priceTextField.text = "€ \(priceString)"
            self.priceTextField.resignFirstResponder()
        }
    }
}
