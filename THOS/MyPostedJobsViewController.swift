//
//  MyPostedJobsViewController.swift
//  Jobie
//
//  Created by daylonvanwel on 06-02-16.
//  Copyright © 2016 daylon wel. All rights reserved.
//

import UIKit
import EventKit

class MyPostedJobsCell: UITableViewCell {
    
    @IBOutlet var descriptionTV: UITextView!
    @IBOutlet var acceptedDateLbel: UILabel!
    @IBOutlet var GoToChatButton: UIButton!
    
    @IBOutlet var typeImageView: UIImageView!
    @IBOutlet var subjectLabel: UILabel!
    
    var jobInfoTuppleArray = [(user: PFUser,image: UIImage, job: PFObject)]()
    
}

class MyPostedJobsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FloatRatingViewDelegate, SFDraggableDialogViewDelegate, PayPalPaymentDelegate {

    //todo reload when returning from chat
    
    @IBOutlet var tableView: UITableView!
    
    var myPostedJobsArray = [PFObject]()
    var userView: userPopUpView!
    var acceptedUser: PFUser!
    var selectedJob: PFObject!
    var jobDescription: String!
    var paidJob: PFObject!

    var location: PFGeoPoint!

    var jobIDForSegue: String!
    var jobForChat: PFObject!
    
    var finishUpView = FinishUpView(frame: CGRectZero)
    
    var userToPay: PFUser!
    var newUserRating: NSNumber!
    var ratingToUpdate: PFObject!
    
    var sharedFriendsArray = [String]()
    
    var sharedfriendsView: UIView!
    
    var refreshContol: UIRefreshControl!
    
    var segmentedControl: HMSegmentedControl!
    
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
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        refreshContol = UIRefreshControl()
        refreshContol.addTarget(self, action: #selector(MyPostedJobsViewController.refreshPulled), forControlEvents: .ValueChanged)
        self.tableView.addSubview(refreshContol)
        
        segmentedControl  = HMSegmentedControl(sectionTitles: ["Held geregeld", "Nog geen Held", "Uit te voeren"])
        segmentedControl.frame = CGRectMake(0, 64, view.frame.width, 50)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = UIColor.whiteColor()
        segmentedControl.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        segmentedControl.selectedTitleTextAttributes = [NSForegroundColorAttributeName: UIColor.ThosColor()]
        segmentedControl.selectionIndicatorColor = UIColor.ThosColor()
        segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox
        segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown
    
        segmentedControl.addTarget(self, action: #selector(self.statusChanged(_:)), forControlEvents: .ValueChanged)
        self.view.addSubview(segmentedControl)
    
        self.getMyPlannedJobs()
        
        // Set up payPalConfig
        payPalConfig.acceptCreditCards = true;
        
        payPalConfig.merchantName = "T.H.O.S."
        payPalConfig.merchantPrivacyPolicyURL = NSURL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = NSURL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        
        PayPalMobile.preconnectWithEnvironment(PayPalEnvironmentProduction)
        
        payPalConfig.languageOrLocale = NSLocale.preferredLanguages()[0]
        
        
        payPalConfig.payPalShippingAddressOption = .PayPal;
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(true)
        NSNotificationCenter.defaultCenter().postNotificationName("chechForNewChats", object: nil)

    }
    
    func refreshPulled () {

        self.refreshContol.beginRefreshing()
        
        if myPostedJobsArray.count > 0 {
            
            myPostedJobsArray.removeAll(keepCapacity: true)
            self.tableView.reloadData()
        }
        
        if self.segmentedControl.selectedSegmentIndex == 0 {
            
            self.getMyPlannedJobs()
            
        } else if self.segmentedControl.selectedSegmentIndex == 1 {
            
            self.getMyOpenWithInterestedUsersJobs()
            
        } else if self.segmentedControl.selectedSegmentIndex == 2 {
            
            self.getMyJobsToBeDone()

        }


    }
    
    func statusChanged(sender: HMSegmentedControl) {
        
        if myPostedJobsArray.count > 0 {
            
            myPostedJobsArray.removeAll(keepCapacity: true)
            self.tableView.reloadData()
        }
        
        if sender.selectedSegmentIndex == 0 {
            
            self.getMyPlannedJobs()
            
        } else if sender.selectedSegmentIndex == 1 {
            
            self.getMyOpenWithInterestedUsersJobs()
            
        } else if sender.selectedSegmentIndex == 2 {
            
            self.getMyJobsToBeDone()
        }

    }
    
    func getMyPlannedJobs() {
        
        let querie = PFQuery(className: "Job")
        querie.whereKey("user", equalTo: PFUser.currentUser()!)
        querie.whereKey("jobTypeNumber", lessThan: 3)
        querie.whereKey("open", equalTo: false)
        querie.includeKey("acceptedUser")
        querie.findObjectsInBackgroundWithBlock { (jobs, error ) -> Void in
            
            if error != nil {
                
                print(error?.localizedDescription)
                
            } else {
                
                if ((jobs?.count) != nil) {
                    
                    for job in jobs! {
                        
                        if job["posterReadLastText"] as! Bool == false && self.myPostedJobsArray.count != 0 {
                        
                            self.myPostedJobsArray.insert(job, atIndex: 0)
                            self.tableView.reloadData()
                            self.refreshContol.endRefreshing()
                            
                        } else {
                        
                            self.myPostedJobsArray.append(job)
                            self.tableView.reloadData()
                            self.refreshContol.endRefreshing()
                        }
                    }
                    
                }
            }
            
        }

    }
    
    func getMyOpenWithInterestedUsersJobs() {
        
        let querie = PFQuery(className: "Job")
        querie.whereKey("user", equalTo: PFUser.currentUser()!)
        querie.whereKey("open", equalTo: true)
        querie.whereKey("jobTypeNumber", lessThan: 3)

        querie.findObjectsInBackgroundWithBlock { (jobs, error ) -> Void in
            
            if error != nil {
                
                print(error?.localizedDescription)
                
            } else {
                
                if ((jobs?.count) != nil) {
                    
                    for job in jobs! {
                        
                        self.myPostedJobsArray.append(job)
                        self.tableView.reloadData()
                        self.refreshContol.endRefreshing()
                    }
                    
                } 
            }
            
        }

    }

    func getMyJobsToBeDone() {
        
        let querie = PFQuery(className: "Job")
        querie.whereKey("acceptedUser", equalTo: PFUser.currentUser()!)
        querie.whereKey("open", equalTo: false)
        querie.whereKey("jobTypeNumber", lessThan: 3)
        querie.includeKey("user")

        querie.findObjectsInBackgroundWithBlock { (jobs, error ) -> Void in
            
            if error != nil {
                
                print(error?.localizedDescription)
                
            } else {
                                
                if ((jobs?.count) != nil) {
                    // todo unread text to top
                    for job in jobs! {
                        
                        self.myPostedJobsArray.append(job)
                        self.tableView.reloadData()
                        self.refreshContol.endRefreshing()
                        
                    }
                }
            }
            
        }
        
    }

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return myPostedJobsArray.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! MyPostedJobsCell
        cell.acceptedDateLbel.adjustsFontSizeToFitWidth =  true
        let object  = self.myPostedJobsArray[indexPath.row]
        
        let description = object["jobDescription"] as! String
        let price = object["price"] as! NSNumber
        let text = "\(description) €\(price)"
        
        cell.descriptionTV.attributedText = getColoredText(text)
        cell.descriptionTV.font = UIFont.systemFontOfSize(18, weight: UIFontWeightSemibold)
        
        let jobtype = object["jobTypeNumber"] as! NSNumber
        let jobSubType = object["jobSubTypeNumber"] as! NSNumber

        cell.typeImageView.image = getJotTypeMedia(jobtype, subtype: jobSubType).0
        
        cell.subjectLabel.text = object["jobSubject"] as? String
        
        cell.GoToChatButton.contentHorizontalAlignment = .Left
        cell.GoToChatButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        cell.GoToChatButton.titleLabel?.adjustsFontSizeToFitWidth = true

        if self.segmentedControl.selectedSegmentIndex == 0 {
            
//            if object["posterReadLastText"] as! Bool == false {
//                
//                let pulseAnimation = CABasicAnimation(keyPath: "opacity")
//                pulseAnimation.duration = 0.5
//                pulseAnimation.fromValue = 0
//                pulseAnimation.toValue = 1
//                pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//                pulseAnimation.autoreverses = true
//                pulseAnimation.repeatCount = FLT_MAX
//                cell.GoToChatButton.layer.addAnimation(pulseAnimation, forKey: nil)
//                
//            }
            
            cell.GoToChatButton.hidden = false
            
            if object["isPaid"] as! Bool == false {
                
                
                let user = object["acceptedUser"] as! PFUser
                let userName = user["displayName"] as! String

                let underlineCreateAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue, NSForegroundColorAttributeName: UIColor.ThosColor(),NSFontAttributeName: UIFont(name: "OpenSans", size: 24.0)!]
                let underlineCreateAttributedString = NSAttributedString(string: "Betaal \(userName) nu met Paypal", attributes: underlineCreateAttribute)
                cell.GoToChatButton.setAttributedTitle(underlineCreateAttributedString, forState: .Normal)

                
              
                cell.GoToChatButton.addTarget(self, action: #selector(MyPostedJobsViewController.buttonPressed(_:)), forControlEvents: .TouchUpInside)
                    
            } else if object["isPaid"] as! Bool == true {
                
                let user = object["acceptedUser"] as! PFUser
                let userName = user["displayName"] as! String
                    
                let underlineCreateAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue, NSForegroundColorAttributeName: UIColor.ThosColor(),NSFontAttributeName: UIFont(name: "OpenSans", size: 24.0)!]
                let underlineCreateAttributedString = NSAttributedString(string: "Chat met \(userName)", attributes: underlineCreateAttribute)
                cell.GoToChatButton.setAttributedTitle(underlineCreateAttributedString, forState: .Normal)
                
                cell.GoToChatButton.addTarget(self, action: #selector(MyPostedJobsViewController.buttonPressed(_:)), forControlEvents: .TouchUpInside)
            }
                
            
            let formatter = NSDateFormatter()
            formatter.dateStyle = .MediumStyle
            let dateString = formatter.stringFromDate(object["acceptedDate"] as! NSDate)
            cell.acceptedDateLbel.text = "De Held komt op \(dateString)"
            
        } else if self.segmentedControl.selectedSegmentIndex == 1 {
            
            cell.GoToChatButton.hidden = true
            
            cell.acceptedDateLbel.text = ""

            
        } else if self.segmentedControl.selectedSegmentIndex == 2 {
            
//            if object["posterReadLastText"] as! Bool == false {
//                
//                let pulseAnimation = CABasicAnimation(keyPath: "opacity")
//                pulseAnimation.duration = 0.5
//                pulseAnimation.fromValue = 0
//                pulseAnimation.toValue = 1
//                pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//                pulseAnimation.autoreverses = true
//                pulseAnimation.repeatCount = FLT_MAX
//                cell.GoToChatButton.layer.addAnimation(pulseAnimation, forKey: nil)
//                
//            }
            
            if object["isPaid"] as! Bool == false {
                
                cell.GoToChatButton.hidden = true
                
            } else if object["isPaid"] as! Bool == true {
                
                let user = object["user"] as! PFUser
                let userName = user["displayName"] as! String
                
                let underlineCreateAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue, NSForegroundColorAttributeName: UIColor.ThosColor(),NSFontAttributeName: UIFont(name: "OpenSans", size: 24.0)!]
                let underlineCreateAttributedString = NSAttributedString(string: "Chat met \(userName)", attributes: underlineCreateAttribute)
                cell.GoToChatButton.setAttributedTitle(underlineCreateAttributedString, forState: .Normal)
                
                cell.GoToChatButton.addTarget(self, action: #selector(MyPostedJobsViewController.buttonPressed(_:)), forControlEvents: .TouchUpInside)
                cell.GoToChatButton.hidden = false

            }
            

            let formatter = NSDateFormatter()
            formatter.dateStyle = .MediumStyle
            let dateString = formatter.stringFromDate(object["acceptedDate"] as! NSDate)
            cell.acceptedDateLbel.text = "Deze klus moet je uitvoeren op \(dateString)"
                    
        }

        return cell
        
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        if self.segmentedControl.selectedSegmentIndex == 1 {
            
            return .Delete
            
        } else {
            
            return .None
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if self.segmentedControl.selectedSegmentIndex == 1 {
            
            if editingStyle == .Delete {
                
                let jobObjectToDelete = self.myPostedJobsArray[indexPath.row]
                self.myPostedJobsArray.removeAtIndex(indexPath.row)
                jobObjectToDelete.deleteInBackgroundWithBlock({ (suceeded, error) in
                    
                    if error == nil {
                        
                        if suceeded == true {
                            
                            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                        }
                    }
                })
            }
        }
    }
    
    func buttonPressed(sender: UIButton) {
        
        let jobCell = sender.superview?.superview as! MyPostedJobsCell
        
        let indexPath = self.tableView.indexPathForCell(jobCell)
        
        let jobObject = myPostedJobsArray[(indexPath?.row)!]
        
        
        if jobObject["isPaid"] as! Bool == false {
            
            self.payButtonPressed(jobObject)
            
        } else if jobObject["isPaid"] as! Bool == true {
            
            self.chatButtonPressed(jobObject)
        }
        
    }
    
    func payButtonPressed(jobObject: PFObject) {
        
        let price = jobObject["price"] as! NSNumber
        
        let item1 = PayPalItem(name: "T.H.O.S.", withQuantity: 1, withPrice: 0.1, withCurrency: "EUR", withSku: jobObject["sku"] as? String )
        
        let items = [item1]
        let subtotal = PayPalItem.totalPriceForItems(items)
        
        let shipping = NSDecimalNumber(string: "5.99")
        let tax = NSDecimalNumber(string: "2.50")
        // shipping and tax here
        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: 0, withTax: 0)
        //and here
        let total = subtotal.decimalNumberByAdding(0).decimalNumberByAdding(0)
        
        let payment = PayPalPayment(amount: total, currencyCode: "EUR", shortDescription: "T.H.O.S. \(jobObject["jobDescription"])", intent: .Sale)
        
        payment.items = items
        payment.paymentDetails = paymentDetails
        
        self.paidJob = jobObject
        
        if (payment.processable) {
            
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
            self.presentViewController(paymentViewController!, animated: true, completion: nil)
            
        } else {
            
            print("Payment not processalbe: \(payment)")
            
        }

    }
    
    func chatButtonPressed(jobObject: PFObject) {
        
        self.jobDescription = jobObject["jobDescription"] as! String

        self.jobForChat = jobObject
        self.jobIDForSegue = jobObject.objectId
        
        goToChatVC()
        
        
    }
    
    func goToChatVC(){
        
        self.performSegueWithIdentifier("myPostedJobsToChatSegue", sender: self)

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
        self.paidJob.saveInBackgroundWithBlock { (succeded, error) in
            
            if error  == nil {
                
                if succeded == true {
                    
                    if self.myPostedJobsArray.count > 0 {
                        
                        self.myPostedJobsArray.removeAll(keepCapacity: true)
                        self.tableView.reloadData()
                        self.getMyPlannedJobs()

                    }

                }
            }
        }
        
       
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let controller = segue.destinationViewController as! JobChatViewController
        controller.jobId = self.jobIDForSegue
        controller.jobDescription = self.jobDescription
        controller.job = self.jobForChat
    }
    
    func floatRatingView(ratingView: FloatRatingView, isUpdating rating:Float) {
        
        
        
    }
    
    func floatRatingView(ratingView: FloatRatingView, didUpdate rating: Float) {
        
        self.newUserRating = NSNumber(float: rating)
    
    }
    
    
    func getColoredText(text: String) -> NSMutableAttributedString {
       
        let string:NSMutableAttributedString = NSMutableAttributedString(string: text)
        let words:[String] = text.componentsSeparatedByString(" ")
        
        for word in words {
         
            if (word.hasPrefix("€")) {
                
                string.beginEditing()
                let range:NSRange = (string.string as NSString).rangeOfString(word)
                string.addAttribute(NSForegroundColorAttributeName, value: UIColor.ThosColor(), range: range)
                
                string.endEditing()
                
            } else if (!word.hasPrefix("€")) {
                
                string.beginEditing()
                let range:NSRange = (string.string as NSString).rangeOfString(word)
                string.addAttribute(NSForegroundColorAttributeName, value: UIColor.darkGrayColor(), range: range)
                
                string.endEditing()

            }
        }
        return string
    }

}
