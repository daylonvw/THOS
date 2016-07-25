//  SelectNewJobTypeViewController.swift
//  THOS
//
//  Created by daylonvanwel on 07-07-16.
//  Copyright © 2016 daylon wel. All rights reserved.


import UIKit

class SelectNewJobTypeViewController: UIViewController, PayPalPaymentDelegate {
    
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
    
    #if HAS_CARDIO
    var acceptCreditCards: Bool = true {
    didSet {
    payPalConfig.acceptCreditCards = acceptCreditCards
    }
    }
    
    
    #else
    var acceptCreditCards: Bool = false {
        didSet {
            payPalConfig.acceptCreditCards = acceptCreditCards
        }
    }
    #endif
    
    var resultText = "" // empty
    var payPalConfig = PayPalConfiguration() // default

    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        centerX = view.center.x
        centerY = view.center.y
        
        self.showJobOptions()
        
        // Set up payPalConfig
        payPalConfig.acceptCreditCards = true;
        
        payPalConfig.merchantName = "T.H.O.S."
        payPalConfig.merchantPrivacyPolicyURL = NSURL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = NSURL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        
        PayPalMobile.preconnectWithEnvironment(PayPalEnvironmentSandbox)
        
        payPalConfig.languageOrLocale = NSLocale.preferredLanguages()[0]
        
        
        payPalConfig.payPalShippingAddressOption = .PayPal;
        
        NSNotificationCenter.defaultCenter().addObserverForName("userAppliedToJob", object: nil, queue: nil) { (notification: NSNotification) in
            
            self.openPaypalFromNotification(notification)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showJobOptions() {
    
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

    func openPaypalFromNotification(notification: NSNotification) {
        
            let price = notification.object?.valueForKey("price") as! NSNumber
        
        //todo sku
        let item1 = PayPalItem(name: "T.H.O.S.", withQuantity: 1, withPrice: NSDecimalNumber(decimal: price.decimalValue), withCurrency: "EUR", withSku: notification.object?.valueForKey("sku") as? String )
        
        let items = [item1]
        let subtotal = PayPalItem.totalPriceForItems(items)
        
        // Optional: include payment details
        let shipping = NSDecimalNumber(string: "5.99")
        let tax = NSDecimalNumber(string: "2.50")
        
        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
        
        let total = subtotal.decimalNumberByAdding(shipping).decimalNumberByAdding(tax)
        
        let payment = PayPalPayment(amount: total, currencyCode: "EUR", shortDescription: "T.H.O.S. \(notification.object?.valueForKey("description"))", intent: .Sale)
        
        payment.items = items
        payment.paymentDetails = paymentDetails
        
        
        if (payment.processable) {
            
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
            self.presentViewController(paymentViewController!, animated: true, completion: nil)
            
        } else {
            
            print("Payment not processalbe: \(payment)")
            
        }
        
    }
    
    func payPalPaymentDidCancel(paymentViewController: PayPalPaymentViewController) {
        print("PayPal Payment Cancelled")
        resultText = ""
        paymentViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func payPalPaymentViewController(paymentViewController: PayPalPaymentViewController, didCompletePayment completedPayment: PayPalPayment) {
        print("PayPal Payment Success !")
        paymentViewController.dismissViewControllerAnimated(true, completion: { () -> Void in
            // send completed confirmaion to your server
            print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
            
            self.resultText = completedPayment.description
            
            // todo send payment to backend
            
        })
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     
        if segue.destinationViewController.isKindOfClass(CreateJobViewController) {
            
            let createViewController = segue.destinationViewController as! CreateJobViewController
            createViewController.jobType = jobTypeNumber
            createViewController.jobSubType = jobSubTypeNumber
        }
    }
 
}
