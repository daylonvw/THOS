//
//  SearchForJobsViewController.swift
//  Jobie
//
//  Created by daylonvanwel on 05-02-16.
//  Copyright © 2016 daylon wel. All rights reserved.
//

import UIKit



class SearchForJobsViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, SFDraggableDialogViewDelegate, UISearchBarDelegate {
    
// IBOutlets
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var jobSearchBar: UISearchBar!

    @IBOutlet var houseKeepingButton: UIButton!
    @IBOutlet var labourButton: UIButton!
    
    @IBOutlet var searchBarButton: UIBarButtonItem!
    
    @IBOutlet var searchZipCodeButton: UIButton!
    @IBOutlet var zipCodeTextField: UITextField!
    @IBOutlet var searchCurrentLocationButton: UIButton!
    @IBOutlet var startSearchLabel: UILabel!
    @IBOutlet var orLabel: UILabel!
    
    
    var MapViewLocationManager:CLLocationManager! = CLLocationManager()
    
    
    let locationManager = CLLocationManager()
    var geoPoint: PFGeoPoint!
    var jobsArray = [PFObject]()
    
    var jobTypeSelected = [String]()
    

    override func viewDidLoad() {
       
        super.viewDidLoad()
        // setup default design
        
        self.jobSearchBar.delegate = self
        self.jobSearchBar.returnKeyType = .Done
        self.jobSearchBar.enablesReturnKeyAutomatically = true
        
        self.mapView.hidden = true
        self.jobSearchBar.hidden = true
        self.labourButton.hidden = true
        self.houseKeepingButton.hidden = true
        
        self.searchZipCodeButton.layer.cornerRadius = 4
        self.searchCurrentLocationButton.layer.cornerRadius = 4
        self.zipCodeTextField.layer.borderColor = UIColor.ThosColor().CGColor
        self.zipCodeTextField.layer.borderWidth = 1.0
        self.zipCodeTextField.layer.cornerRadius = 4
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func searchByZipCodeButtonPressed(sender: AnyObject) {
        
        self.zipCodeTextField.resignFirstResponder()
        var zipCodeText = zipCodeTextField.text!
        
        var index = 0
        for character in zipCodeText.characters {
           
            if character == " " {
            
                zipCodeText.removeAtIndex(zipCodeText.startIndex.advancedBy(index))
                
                index -= 1

            }
            
            index += 1
        }
        
        print(zipCodeText)
        
        // todo use removeAtIndex also at creating a job ( price, zipcode )
        self.dismmissSearchItems()

        let zipCode = NSURL(string: "https://maps.googleapis.com/maps/api/geocode/json?address=\(zipCodeText)&sensor=true")
        
        let downloadTask = NSURLSession.sharedSession().dataTaskWithURL(zipCode!, completionHandler: { (data , responce, error) -> Void in
            
            do {
                
                let dict = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                
                let locationArray = dict.valueForKey("results")?.valueForKey("geometry")?.valueForKey("location")
                // todo loop through characters from string and delete spaced ( crasher when there is a space )
                print(locationArray?.count)

                if (locationArray!.count != nil) {
                
                    let latitude = locationArray?.objectAtIndex(0).valueForKey("lat") as! Double
                    let longtitude = locationArray?.objectAtIndex(0).valueForKey("lng") as! Double
    
                    self.geoPoint = PFGeoPoint(latitude: latitude, longitude: longtitude)
                    
                    self.mapView.showsUserLocation = true
                    self.mapView.delegate = self
                    self.MapViewLocationManager.delegate = self
                    self.MapViewLocationManager.startUpdatingLocation()
                    self.mapView.region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: latitude, longitude: longtitude), 15000, 15000)
                    
                    self.getJobs()
                    
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

    }
    
    
    @IBAction func searchCurrentLocationButtonPressed(sender: AnyObject) {
        
        self.zipCodeTextField.resignFirstResponder()
        self.dismmissSearchItems()
        self.getlocation()
    }
    
    func dismmissSearchItems() {

        
        searchZipCodeButton.hidden = true
        zipCodeTextField.hidden = true
        searchCurrentLocationButton.hidden = true
        orLabel.hidden = true
        startSearchLabel.hidden = true
        
        self.mapView.hidden = false
        self.jobSearchBar.hidden = false
        self.labourButton.hidden = false
        self.houseKeepingButton.hidden = false


        
    }
    
    @IBAction func addSearchItems(sender: AnyObject) {
        
        self.jobSearchBar.resignFirstResponder()
        
        self.zipCodeTextField.text = ""
        
        self.geoPoint = nil
        self.jobsArray.removeAll(keepCapacity: true)
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        searchZipCodeButton.hidden = false
        zipCodeTextField.hidden = false
        searchCurrentLocationButton.hidden = false
        orLabel.hidden = false
        startSearchLabel.hidden = false
        
        self.mapView.hidden = true
        self.jobSearchBar.hidden = true
        self.labourButton.hidden = true
        self.houseKeepingButton.hidden = true
        
        

    }
    
    
    func getlocation() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }

    func getJobs() {
                
        let querie = PFQuery(className: "Job")
        querie.includeKey("user")
        querie.whereKey("user", notEqualTo: PFUser.currentUser()!)
        querie.whereKey("jobLocation", nearGeoPoint: self.geoPoint, withinKilometers: 60)
        querie.whereKey("open", equalTo: true)
        querie.whereKey("maxUsersReached", equalTo: false)
        querie.whereKey("finished", equalTo: false)
        
        if PFUser.currentUser()!["jobsAppliedToArray"] != nil {
            
            querie.whereKey("objectId", notContainedIn: PFUser.currentUser()!["jobsAppliedToArray"] as! [AnyObject])

        }
        
    
        
        querie.findObjectsInBackgroundWithBlock { (jobs, error ) -> Void in
            
            if error != nil {
                
                print(error?.localizedDescription)
                
            } else {
                
                if ((jobs?.count) != nil) {
                    
                    for job in jobs! {
                        
                        let user = job["user"] as! PFUser
                        let point = job["jobLocation"] as! PFGeoPoint
                        let annotation = DWAnnotation()
                        annotation.coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude)
                        annotation.title = job["jobDescription"] as? String
                        annotation.subtitle = user["displayName"] as? String
                        annotation.jobType = job["jobType"] as! String
                        self.mapView.addAnnotation(annotation)
                        
                        self.jobsArray.append(job)
                        
                    }
                }
            }
            
        }

    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
       
        print(mapView.selectedAnnotations)
        
        for annotation in mapView.selectedAnnotations {
            
            print(annotation.title)
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        let identifier = "pin"
        var view: MKAnnotationView
    
        if annotation.title! == "Current Location" {
            
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)

            view.image = UIImage(named: "currentUser")
            view.backgroundColor = UIColor.ThosColor()
            view.layer.cornerRadius = view.frame.size.width / 2
            
            view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            view.layer.shadowColor = UIColor.darkGrayColor().CGColor
            view.layer.shadowOffset = CGSizeMake(1.0, 1.0)
            view.layer.shadowOpacity = 0.9

            
        } else {

            
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            
            } else {
            // 3
                if annotation.isKindOfClass(DWAnnotation) {
                    
                    let dwAnnotation = annotation as! DWAnnotation
                    view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    view.canShowCallout = true
                    view.calloutOffset = CGPoint(x: -5, y: 5)
                    view.image = setAnnotationType(dwAnnotation.valueForKey("jobType") as! String)

                    view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
                    view.layer.shadowColor = UIColor.darkGrayColor().CGColor
                    view.layer.shadowOffset = CGSizeMake(1.0, 1.0)
                    view.layer.shadowOpacity = 0.9

                } else {
                    
                    view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)

                }
            }
        }
        
        return view

    }
    
    func setAnnotationType(jobType: String) -> UIImage {
        
        if jobType == "houseKeeping" {
        
            return UIImage(named: "houseKeepingPoint")!
            
        } else if jobType == "labour" {
            
            return UIImage(named: "labourPoint")!
            
        } else {
            
            return UIImage()
        }
        
    }
    
    func mapView(mapView: MKMapView, annotationView anView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        for job in self.jobsArray {
            // ToDo set tag or subtitel also because maybe some jobs have te same description
            if (job["jobDescription"] as! String) == (anView.annotation?.title)! {
            
                self.jobSearchBar.resignFirstResponder()
                self.OpenJobViewWith(job)
            }
        }
    }
    
    func OpenJobViewWith(job: PFObject) {
        
        let jobView: SFDraggableDialogView = NSBundle.mainBundle().loadNibNamed("SFDraggableDialogView", owner: self, options: nil)[0] as! SFDraggableDialogView
        jobView.frame = view.frame
        jobView.delegate = self
        jobView.messgageLabel.sizeToFit()
        jobView.messageText = NSMutableAttributedString(string: job["jobDescription"] as! String)
        jobView.firstBtnText = "I'm interested"
        jobView.firstBtnBackgroundColor = UIColor.ThosColor()
        jobView.pfObject = job
        
        
        if job["price"] != nil {
            
            jobView.titleText = NSMutableAttributedString(string:"€ \(job["price"] as! NSNumber)")
            
        } else {
            
            jobView.titleText = NSMutableAttributedString(string:"€ tbd")
        }
        if job["jobImage"] != nil {

            let file = job["jobImage"] as! PFFile
            file.getDataInBackgroundWithBlock({ (data, error) -> Void in
            
                if error != nil {
                
                    print(error?.localizedDescription)
                
                } else {
                
                    jobView.photo = UIImage(data: data!)
                }
            
            })
        
        
        } else {
            
            jobView.photo = nil
            
        }
        view.addSubview(jobView)

    }
   
    func draggableDialogView(dialogView: SFDraggableDialogView!, didPressFirstButton firstButton: UIButton!) {
        
        
        let query = PFQuery(className: "Job")
        query.includeKey("user")
        query.getObjectInBackgroundWithId(dialogView.pfObject.objectId!) { (job , error ) -> Void in
            
            if error != nil {
                
                
            } else {
                
                if job!["interestedUsersArray"] != nil {
                    
                    var jobArray: [String] = job!["interestedUsersArray"] as! Array
                   
                    if jobArray.count < 4 {
                        jobArray.append((PFUser.currentUser()?.objectId)!)
                    
                        job!["interestedUsersArray"] = jobArray
                        job?.saveInBackgroundWithBlock({ (saved, error ) -> Void in
                        
                            if error != nil {
                            
                            
                            } else {
                            
                                if saved == true {
                                
                                    self.sendInterestedPush(job!)

                                    self.setNewInterestedArrayCurrentUser((job?.objectId)!)
                                    
                                    self.removeAnnotationAndJobView(dialogView)
                                }
                            }
                        })
                    
                    } else if jobArray.count == 4 {
                        
                        job!["maxUsersReached"] = true
                        job?.saveInBackgroundWithBlock({ (succes, error ) -> Void in
                            
                            if error != nil {

                                print(error?.localizedDescription)
                            } else {
                                
                                print("maxusers reached")
                            }
                        })
                    }
                    
                } else {
                    
                    var jobArray = [String]()
                    
                    jobArray.append((PFUser.currentUser()?.objectId)!)
                    
                    job!["interestedUsersArray"] = jobArray
                    job?.saveInBackgroundWithBlock({ (saved, error ) -> Void in
                        
                        if error != nil {
                            
                            
                        } else {
                            
                            if saved == true {
                                
                                self.sendInterestedPush(job!)

                                self.setNewInterestedArrayCurrentUser((job?.objectId)!)
                                
                                self.removeAnnotationAndJobView(dialogView)

                            }
                        }
                    })

                }
            }
        }

    }
    
    
    func removeAnnotationAndJobView(dialogView: SFDraggableDialogView) {
        
        dialogView.dismissWithFadeOut(true)
        
        for annotation in mapView.selectedAnnotations {
            
            mapView.removeAnnotation(annotation)
        }

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
    
    func setNewInterestedArrayCurrentUser(jobId: String) {
        
        let querie = PFUser.query()
        querie?.whereKey("objectId", equalTo: (PFUser.currentUser()?.objectId)!)
        querie?.getFirstObjectInBackgroundWithBlock({ (currentUser, error) -> Void in
            
            if error != nil {
                
                
            } else {
                
                if currentUser!["jobsAppliedToArray"] != nil {
                    
                    var jobsAppliedToArray: [String] = currentUser!["jobsAppliedToArray"] as! Array
                    jobsAppliedToArray.append(jobId)
                  
                    PFUser.currentUser()!["jobsAppliedToArray"] = jobsAppliedToArray
                    PFUser.currentUser()?.saveInBackground()
                    
                } else {
                    
                    var jobsAppliedToArray = [String]()
                    jobsAppliedToArray.append(jobId)
                    PFUser.currentUser()!["jobsAppliedToArray"] = jobsAppliedToArray
                    PFUser.currentUser()?.saveInBackground()

                }
            }
        })
        
    }
    
    // cllocatationManagerDelagateFunctions
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locationManager.stopUpdatingLocation()
        
//        print("updateing")
        
        if self.geoPoint == nil {
            
            self.geoPoint = PFGeoPoint(location: locationManager.location)
            
            mapView.showsUserLocation = true
            mapView.delegate = self
            MapViewLocationManager.delegate = self
            MapViewLocationManager.startUpdatingLocation()
            mapView.region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: self.geoPoint.latitude, longitude: self.geoPoint.longitude), 40000, 40000)

            let installation = PFInstallation.currentInstallation()
            
            if PFUser.currentUser() != nil {
                
                installation["location"] = self.geoPoint
                
            }
            
            installation.saveInBackground()
            self.getJobs()
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print("failed location")
        
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
//        print("changed")
    }

    // searchbar delegates
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchBar.backgroundColor = UIColor.whiteColor()
        // show all annotations
        if searchBar.text! == "" {
            
            for annotation in self.mapView.annotations {
                
                self.mapView.viewForAnnotation(annotation)?.hidden = false
            }
            
        } else {
            
        
            for annotation in self.mapView.annotations {
                
                let title:NSString = annotation.title!!
                let range = title.rangeOfString(searchBar.text!, options: .CaseInsensitiveSearch)
                
                if range.location != NSNotFound {
                    
                    // add annotation again if not currently on map
                    
                    self.mapView.viewForAnnotation(annotation)?.hidden = false
                    
                } else {
                    
                    // remove annotatoins
                    self.mapView.viewForAnnotation(annotation)?.hidden = true

                }
            }

        }
        
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
        searchBar.backgroundColor = UIColor.whiteColor()
    
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.backgroundColor = UIColor.clearColor()

    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
     
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.backgroundColor = UIColor.clearColor()
        
        for annotation in self.mapView.annotations {
            
            self.mapView.viewForAnnotation(annotation)?.hidden = false
        }

    }
    
    @IBAction func houseKeepingPressed(sender: AnyObject) {
        
        let button = sender as! UIButton
        
        if button.tag == 0 {
           
            self.houseKeepingButton.alpha = 0.3
            self.labourButton.userInteractionEnabled = false
            self.houseKeepingButton.tag = 1
            for annotation in self.mapView.annotations {
        
                if annotation.isKindOfClass(DWAnnotation){
               
                    let dwAnnotation = annotation as! DWAnnotation

                    if dwAnnotation.jobType == "houseKeeping" {
                
                        // add annotation again if not currently on map
                
                        self.mapView.viewForAnnotation(annotation)?.hidden = true
                
                    }
                }
            }
            
        } else if button.tag == 1 {
          
            self.houseKeepingButton.alpha = 1.0
            self.labourButton.userInteractionEnabled = true
            self.houseKeepingButton.tag = 0
            for annotation in self.mapView.annotations {
                
                if annotation.isKindOfClass(DWAnnotation){
                    
                    let dwAnnotation = annotation as! DWAnnotation
                    
                    if dwAnnotation.jobType == "houseKeeping" {
                        
                        // add annotation again if not currently on map
                        
                        self.mapView.viewForAnnotation(annotation)?.hidden = false
                        
                    }
                }
            }

        }
    }

    
    @IBAction func labourButtonPRressed(sender: AnyObject) {
        
        let button = sender as! UIButton
        
        if button.tag == 0 {
           
            self.labourButton.alpha = 0.3
            self.houseKeepingButton.userInteractionEnabled = false
            self.labourButton.tag = 1
            for annotation in self.mapView.annotations {
                
                if annotation.isKindOfClass(DWAnnotation){
                    
                    let dwAnnotation = annotation as! DWAnnotation
                    
                    if dwAnnotation.jobType == "labour" {
                        
                        // add annotation again if not currently on map
                        
                        self.mapView.viewForAnnotation(annotation)?.hidden = true
                        
                    }
                }
            }
            
        } else if button.tag == 1 {
           
            self.labourButton.alpha = 1.0
            self.houseKeepingButton.userInteractionEnabled = true
            self.labourButton.tag = 0
            for annotation in self.mapView.annotations {
                
                if annotation.isKindOfClass(DWAnnotation){
                    
                    let dwAnnotation = annotation as! DWAnnotation
                    
                    if dwAnnotation.jobType == "labour" {
                        
                        // add annotation again if not currently on map
                        
                        self.mapView.viewForAnnotation(annotation)?.hidden = false
                        
                    }
                }
            }
            
        }

        
    }
    
    
}

class DWAnnotation: MKPointAnnotation {
    
    var jobType: String!
}
