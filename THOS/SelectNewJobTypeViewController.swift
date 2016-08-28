//  SelectNewJobTypeViewController.swift
//  THOS
//
//  Created by daylonvanwel on 07-07-16.
//  Copyright © 2016 daylon wel. All rights reserved.


import UIKit

class SelectNewJobTypeViewController: UIViewController, PayPalPaymentDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
    var jobtypeImage: UIImage!
    
    var paidJob: PFObject!
    
    @IBOutlet var collectionView: UICollectionView!
    
    let catagoryArray = ["Binnen het huis", "Buiten het huis", "Afhaal & bezorg"]
    
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
        
        // Set up payPalConfig
        payPalConfig.acceptCreditCards = true;
        
        payPalConfig.merchantName = "T.H.O.S."
        payPalConfig.merchantPrivacyPolicyURL = NSURL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = NSURL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        
        PayPalMobile.preconnectWithEnvironment(PayPalEnvironmentProduction)
        
        payPalConfig.languageOrLocale = NSLocale.preferredLanguages()[0]
        
        
        payPalConfig.payPalShippingAddressOption = .PayPal;
        
        NSNotificationCenter.defaultCenter().addObserverForName("userAppliedToJob", object: nil, queue: nil) { (notification: NSNotification) in
            
            self.openPaypalFromNotification(notification)
        }
        
        
        
        NSNotificationCenter.defaultCenter().addObserverForName("openedFromNewMessage", object: nil, queue: nil) { (notification: NSNotification) -> Void in
            
            self.openChatFromNotification(notification)
        }
        


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            
            return 5
            
        } else if section == 1 {
            
            return 3
            
        } else {
            
            return 2
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        
        for view in cell.subviews {
            
            if view.isKindOfClass(UILabel) || view.isKindOfClass(UIImageView) {
                
                view.removeFromSuperview()
            }
        }
        
        if indexPath.row == 0 {
            
            let label = UILabel( frame: CGRect(x: 10, y: cell.frame.height / 2, width: cell.frame.size.width - 20, height: cell.frame.height / 2))
            label.text = catagoryArray[indexPath.section]
            label.textAlignment = .Left
            label.textColor = UIColor.whiteColor()
            label.font = UIFont(name: "OpenSans-Semibold", size: 30.0)
            label.numberOfLines = 2
            label.adjustsFontSizeToFitWidth = true
           
            cell.addSubview(label)
            cell.backgroundColor = UIColor.ThosColor()
            
        } else {
            
            cell.backgroundColor = UIColor.whiteColor()
           
            let label = UILabel( frame: CGRect(x: 10, y: cell.frame.height - 50, width: cell.frame.size.width - 20, height: 40))
            label.textAlignment = .Center
            label.textColor = UIColor.darkGrayColor()
            label.font = UIFont(name: "OpenSans-Semibold", size: 20.0)
            label.adjustsFontSizeToFitWidth = true

            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.width  / 2, height: cell.frame.width / 2))
            imageView.center = CGPointMake(cell.frame.width / 2, cell.frame.width / 2)
            
            if indexPath.section == 0 {
                
                if indexPath.row == 1 {
                    
                    label.text = "Schoonmaak"
                    imageView.image = UIImage(named: "IndoorCleaning")
                    
                } else if indexPath.row == 2 {
                    
                    label.text = "Oppas"
                    imageView.image = UIImage(named: "nanny")

                    
                } else if indexPath.row == 3 {
                    
                    label.text = "Houtwerk"
                    imageView.image = UIImage(named: "woodWork")


                } else if indexPath.row == 4 {
                    
                    label.text = "Electricien"
                    imageView.image = UIImage(named: "electrician")


                }
                
            } else if indexPath.section == 1 {
                
                if indexPath.row == 1 {
                    
                    label.text = "Rondom het huis"
                    imageView.image = UIImage(named: "aroundTheHouse")


                    
                } else if indexPath.row == 2 {
                    
                    label.text = "In de tuin"
                    imageView.image = UIImage(named: "garden")


                }

            } else if indexPath.section == 2 {
                
                if indexPath.row == 1 {
                    
                    label.text = "Vervoer en verzend"
                    imageView.image = UIImage(named: "pickUp")


                    
                }
            }
            
            cell.addSubview(imageView)
            cell.addSubview(label)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let size = CGSize(width: (view.frame.width / 2) - 10 , height: (view.frame.width / 2) - 10)
        
        return size
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
       
        if indexPath.row != 0 {
            
            jobTypeNumber = indexPath.section
            jobSubTypeNumber = indexPath.row
            
            let cell = collectionView.cellForItemAtIndexPath(indexPath)
            
            for view in (cell?.subviews)! {
                
                if view.isKindOfClass(UIImageView) {
                    
                    let imageView = view as! UIImageView
                    self.jobtypeImage = imageView.image
                }
            }
            
            self.performSegueWithIdentifier("jobTypeToJobInfoSegue", sender: self)

        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.destinationViewController.isKindOfClass(CreateJobViewController) {
            
            let createViewController = segue.destinationViewController as! CreateJobViewController
            createViewController.jobType = jobTypeNumber
            createViewController.jobSubType = jobSubTypeNumber
            createViewController.jobtypeImage = jobtypeImage
        }
    }
    

    func openPaypalFromNotification(notification: NSNotification) {
        
        
        print(notification)
        
        let price = notification.object?.valueForKey("price") as! NSNumber
        let objectString = (notification.object!.valueForKey("sku")) as! String
        let descriptionString = (notification.object!.valueForKey("description")) as! String

        let item1 = PayPalItem(name: "T.H.O.S.", withQuantity: 1, withPrice: 0.1, withCurrency: "EUR", withSku: objectString )
        
        let items = [item1]
        let subtotal = PayPalItem.totalPriceForItems(items)
        
        // Optional: include payment details
        let shipping = NSDecimalNumber(string: "5.99")
        let tax = NSDecimalNumber(string: "2.50")
        
        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: 0, withTax: 0)
        
        let total = subtotal.decimalNumberByAdding(0).decimalNumberByAdding(0)
        
        let payment = PayPalPayment(amount: total, currencyCode: "EUR", shortDescription: descriptionString, intent: .Sale)
        
        payment.items = items
        payment.paymentDetails = paymentDetails
        
        self.paidJob = PFObject(className: "Job")
        self.paidJob.objectId = objectString
        print(self.paidJob.objectId!)
        
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
        self.paidJob = nil
    }
    
    func payPalPaymentViewController(paymentViewController: PayPalPaymentViewController, didCompletePayment completedPayment: PayPalPayment) {
        print("PayPal Payment Success !")
        paymentViewController.dismissViewControllerAnimated(true, completion: { () -> Void in
            // send completed confirmaion to your server
            print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
            
            self.resultText = completedPayment.description
            
            // todo send payment to backend
            
        })
        
        self.paidJob["isPaid"] = true
        self.paidJob.saveInBackground()
    }


    
    func openChatFromNotification(notification: NSNotification) {
        print(notification)
        let query = PFQuery(className: "Job")
        query.whereKey("objectId", equalTo: notification.object as! String)
        query.getFirstObjectInBackgroundWithBlock { (object, error) in
            if error != nil {
                
                print(error)
                
            } else {
                
                let storyBoard  = UIStoryboard(name: "Main", bundle: nil)
                
                let chatController = storyBoard.instantiateViewControllerWithIdentifier("postedJobsChatController") as! JobChatViewController
                
                chatController.jobId = object!.objectId
                chatController.jobDescription = object!.valueForKey("jobDescription") as! String
                chatController.job = object!
                
                
                self.presentViewController(chatController, animated: true, completion: nil)
                
            }
        }
    }
}
