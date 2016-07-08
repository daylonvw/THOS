//  SelectNewJobTypeViewController.swift
//  THOS
//
//  Created by daylonvanwel on 07-07-16.
//  Copyright © 2016 daylon wel. All rights reserved.


import UIKit

class SelectNewJobTypeViewController: UIViewController {
    
    var questionLabel: UILabel!
    var outdoorHeroButton: UIButton!
    var indoorHeroButton: UIButton!
    var centerX: CGFloat!
    var centerY: CGFloat!
    
    var carpenterButton: UIButton!
    var electricianButton: UIButton!
    var tutorButton: UIButton!
    
    var gardenerButton: UIButton!
    var jobsAroundTheHouseButton: UIButton!
    var deliveryButton: UIButton!
    
    var backButton: UIButton!

    var jobTypeNumber: Int!
    var jobSubTypeNumber: Int!
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        centerX = view.center.x
        centerY = view.center.y
        
        self.showJobOptions()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showJobOptions() {
        
        let companyLabel = UILabel(frame: CGRect(x: 10, y: 20, width: view.frame.size.width - 20, height: 40))
        companyLabel.textColor = UIColor.ThosColor()
        companyLabel.text = "The house of service"
        companyLabel.adjustsFontSizeToFitWidth = true
        companyLabel.textAlignment = .Center
        companyLabel.font = UIFont.systemFontOfSize(24, weight: UIFontWeightThin)
        
        questionLabel = UILabel(frame: CGRect(x: 10, y: 70, width: view.frame.size.width - 20, height: 60))
        questionLabel.textColor = UIColor.ThosColor()
        questionLabel.text = "Zoek je een Held voor klussen binnen het het of voor buiten het huis?"
        questionLabel.numberOfLines = 2
        questionLabel.adjustsFontSizeToFitWidth = true
        questionLabel.textAlignment = .Center
        questionLabel.font = UIFont.systemFontOfSize(16, weight: UIFontWeightMedium)
        
        outdoorHeroButton = UIButton(frame: CGRect(x: 20, y: centerY - 30, width: view.frame.size.width - 40, height: 50))
        outdoorHeroButton.backgroundColor = UIColor.ThosColor()
        outdoorHeroButton.setTitle("Klussen buiten het huis", forState: .Normal)
        outdoorHeroButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        outdoorHeroButton.addTarget(self, action: #selector(self.jobTypeButtonPressed(_:)), forControlEvents: .TouchUpInside)
        outdoorHeroButton.tag = 0
        
        indoorHeroButton = UIButton(frame: CGRect(x: 20, y: centerY + 25, width: view.frame.size.width - 40, height: 50))
        indoorHeroButton.backgroundColor = UIColor.ThosColor()
        indoorHeroButton.setTitle("Klussen binnen het huis", forState: .Normal)
        indoorHeroButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        indoorHeroButton.addTarget(self, action: #selector(self.jobTypeButtonPressed(_:)), forControlEvents: .TouchUpInside)
        indoorHeroButton.tag = 1
        
        backButton = UIButton(frame: CGRect(x: 10, y: view.frame.size.height - 100, width: 60, height: 60))
        backButton.setTitle("Annuleer", forState: .Normal)
        backButton.setTitleColor(UIColor.ThosColor(), forState: .Normal)
        backButton.addTarget(self, action: #selector(self.backButtonPressed(_:)), forControlEvents: .TouchUpInside)
        backButton.titleLabel?.adjustsFontSizeToFitWidth = true
        backButton.hidden = true
        
        view.addSubview(companyLabel)
        view.addSubview(questionLabel)
        view.addSubview(outdoorHeroButton)
        view.addSubview(indoorHeroButton)
        view.addSubview(backButton)

    }
    
    func jobTypeButtonPressed(sender: UIButton)  {
        
        UIView.animateWithDuration(0.2, animations: { 
            
            self.outdoorHeroButton.transform = CGAffineTransformMakeTranslation(-400, 0.1)
            self.indoorHeroButton.transform = CGAffineTransformMakeTranslation(-400, 0.1)

            }) { (Bool) in
               
                self.outdoorHeroButton.removeFromSuperview()
                self.indoorHeroButton.removeFromSuperview()
                
                if sender.tag == 0 {
                    
                    self.showOutdoorSubTypesOptions()
                    
                } else if sender.tag == 1 {
                    
                    self.showIndoorSubTypesOptions()
                }
                
                self.jobTypeNumber = sender.tag
                self.backButton.hidden = false

        }

        
    }
    
    func showOutdoorSubTypesOptions() {
        
        questionLabel.text = "Wat voor klus moet de Held doen rondom uw huis?"

        gardenerButton = UIButton(frame: CGRect(x: 20, y: centerY - 80, width: view.frame.size.width - 40, height: 50))
        gardenerButton.backgroundColor = UIColor.ThosColor()
        gardenerButton.setTitle("Hovenier", forState: .Normal)
        gardenerButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        gardenerButton.addTarget(self, action: #selector(self.subTypeButtonPressed(_:)), forControlEvents: .TouchUpInside)
        gardenerButton.tag = 0
        gardenerButton.transform = CGAffineTransformMakeTranslation(+400, 0.1)

        jobsAroundTheHouseButton = UIButton(frame: CGRect(x: 20, y: centerY - 25, width: view.frame.size.width - 40, height: 50))
        jobsAroundTheHouseButton.backgroundColor = UIColor.ThosColor()
        jobsAroundTheHouseButton.setTitle("Klussen aan het huis", forState: .Normal)
        jobsAroundTheHouseButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        jobsAroundTheHouseButton.addTarget(self, action: #selector(self.subTypeButtonPressed(_:)), forControlEvents: .TouchUpInside)
        jobsAroundTheHouseButton.tag = 1
        jobsAroundTheHouseButton.transform = CGAffineTransformMakeTranslation(+400, 0.1)

        deliveryButton = UIButton(frame: CGRect(x: 20, y: centerY + 30, width: view.frame.size.width - 40, height: 50))
        deliveryButton.backgroundColor = UIColor.ThosColor()
        deliveryButton.setTitle("Ophaal/bezorg diensten", forState: .Normal)
        deliveryButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        deliveryButton.addTarget(self, action: #selector(self.subTypeButtonPressed(_:)), forControlEvents: .TouchUpInside)
        deliveryButton.tag = 2
        deliveryButton.transform = CGAffineTransformMakeTranslation(+400, 0.1)

        view.addSubview(gardenerButton)
        view.addSubview(jobsAroundTheHouseButton)
        view.addSubview(deliveryButton)
        
        UIView.animateWithDuration(0.2, animations: {
            
            self.gardenerButton.transform = CGAffineTransformIdentity
            self.jobsAroundTheHouseButton.transform = CGAffineTransformIdentity
            self.deliveryButton.transform = CGAffineTransformIdentity
            
        })
   

    }
    
    func showIndoorSubTypesOptions()  {
        
        questionLabel.text = "Wat voor klus moet de Held in uw huis?"

        carpenterButton = UIButton(frame: CGRect(x: 20, y: centerY - 80, width: view.frame.size.width - 40, height: 50))
        carpenterButton.backgroundColor = UIColor.ThosColor()
        carpenterButton.setTitle("Klusjes man", forState: .Normal)
        carpenterButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        carpenterButton.addTarget(self, action: #selector(self.subTypeButtonPressed(_:)), forControlEvents: .TouchUpInside)
        carpenterButton.tag = 0
        carpenterButton.transform = CGAffineTransformMakeTranslation(+400, 0.1)

        electricianButton = UIButton(frame: CGRect(x: 20, y: centerY - 25, width: view.frame.size.width - 40, height: 50))
        electricianButton.backgroundColor = UIColor.ThosColor()
        electricianButton.setTitle("Elektricien", forState: .Normal)
        electricianButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        electricianButton.addTarget(self, action: #selector(self.subTypeButtonPressed(_:)), forControlEvents: .TouchUpInside)
        electricianButton.tag = 1
        electricianButton.transform = CGAffineTransformMakeTranslation(+400, 0.1)

        tutorButton = UIButton(frame: CGRect(x: 20, y: centerY + 30, width: view.frame.size.width - 40, height: 50))
        tutorButton.backgroundColor = UIColor.ThosColor()
        tutorButton.setTitle("Bijles", forState: .Normal)
        tutorButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        tutorButton.addTarget(self, action: #selector(self.subTypeButtonPressed(_:)), forControlEvents: .TouchUpInside)
        tutorButton.tag = 2
        tutorButton.transform = CGAffineTransformMakeTranslation(+400, 0.1)

        view.addSubview(carpenterButton)
        view.addSubview(electricianButton)
        view.addSubview(tutorButton)
        
        UIView.animateWithDuration(0.2, animations: {
            
            self.carpenterButton.transform = CGAffineTransformIdentity
            self.electricianButton.transform = CGAffineTransformIdentity
            self.tutorButton.transform = CGAffineTransformIdentity
            
        })

    }
    
    func subTypeButtonPressed(sender: UIButton)  {
        
        jobSubTypeNumber = sender.tag
        
        self.performSegueWithIdentifier("jobTypeToJobInfoSegue", sender: self)
        
    }
    
    func backButtonPressed(sender: UIButton)  {
        

        for subView in view.subviews {
            
            subView.removeFromSuperview()
        }
        
        self.showJobOptions()
        
    
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     
        if segue.destinationViewController.isKindOfClass(CreateJobViewController) {
            
            let createViewController = segue.destinationViewController as! CreateJobViewController
            createViewController.jobType = jobTypeNumber
            createViewController.jobSubType = jobSubTypeNumber
        }
    }
 
}
