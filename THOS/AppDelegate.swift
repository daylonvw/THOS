//
//  AppDelegate.swift
//  Jobie
//
//  Created by daylonvanwel on 05-02-16.
//  Copyright © 2016 daylon wel. All rights reserved.
//

import UIKit
import ParseFacebookUtilsV4

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let BraintreeDemoAppDelegatePaymentsURLScheme = "dapper.THOS.payments"

    var userFriendsArray = [String]()
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.\
        
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge , .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        application.applicationIconBadgeNumber = 0
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        Parse.setApplicationId("95JkWTOujhkZNxbuVgIeCzOkN99VxR2Kli1s64HS", clientKey: "YXiPbEl8GGh4U0Bi2gDCETS3dvFXbMHToz2ByVjk")
        
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        
        let dataDIC:[String: AnyObject] = [
            
            PayPalEnvironmentProduction  : "AZQBwHitGqLUtLqmAF1Bhtu3EHWeSWg4qLieqkGq3P2cH6AyfBv1_in96k1ES0k1SH3SmtJBW_-Jt22d",
            PayPalEnvironmentSandbox     : "ATm4QyVrD6ijwAi_em8qvHUIA4Noa3f0IOhiCV478Mo7e7t9t7YRaXHzLj-pQJeepI-DH1HRgoyLHzIB"
        ]
        
        PayPalMobile.initializeWithClientIdsForEnvironments(dataDIC)

        
//        BTAppSwitch.setReturnURLScheme(BraintreeDemoAppDelegatePaymentsURLScheme)

//        Parse.initializeWithConfiguration(ParseClientConfiguration(block: { (configuration:ParseMutableClientConfiguration) -> Void in
//            
//            configuration.server = "https://jobies.herokuapp.com/parse"
//            configuration.applicationId = "Jobie1234"
//            configuration.clientKey = "345hb3jb34tweavasd"
//            
//            
//        }))
        
//        PFUser.logOut()
    
        if PFUser.currentUser() != nil {
            
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
           
            let helpController = storyBoard.instantiateViewControllerWithIdentifier("helpSeekertabBarVC")
            let seekController = storyBoard.instantiateViewControllerWithIdentifier("SeekingJobTabbarVC")

            let userType = PFUser.currentUser()!["userType"] as! String

            if userType == "seeker"{
                
                self.window?.rootViewController = helpController

            } else if userType == "helper" {
                
                self.window?.rootViewController = seekController
            }
            
            self.upDataFacebookFriends()
        }
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        FBSDKAppEvents.activateApp()

    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
    
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
//    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
    
//      return BTAppSwitch.handleOpenURL(url, options: options)
//    }
    
    // paypal example
    
//    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
//    - (BOOL)application:(__unused UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
//    if ([[url.scheme lowercaseString] isEqualToString:[BraintreeDemoAppDelegatePaymentsURLScheme lowercaseString]]) {
//    return [BTAppSwitch handleOpenURL:url options:options];
//    }
//    return YES;
//    }
//    #endif
//    
//    // Deprecated in iOS 9, but necessary to support < versions
//    - (BOOL)application:(__unused UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(__unused id)annotation {
//    if ([[url.scheme lowercaseString] isEqualToString:[BraintreeDemoAppDelegatePaymentsURLScheme lowercaseString]]) {
//    return [BTAppSwitch handleOpenURL:url sourceApplication:sourceApplication];
//    }
//    return YES;
//    }

    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        
        if PFUser.currentUser() != nil {
          
            installation["user"] = PFUser.currentUser()

        }
        
        installation.saveInBackground()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
//        PFPush.handlePush(userInfo)
        
//        print(userInfo)
        if application.applicationState == .Active {
            
            let typeString = userInfo["type"] as! String
          
            if typeString == "jobHelperMessage" {
                
                print("helper message")
                
                let notification = NSNotification(name: "message", object: typeString, userInfo: userInfo)
                NSNotificationCenter.defaultCenter().postNotificationName("messageFromJobHelperRecieved", object: notification)
                
            } else if typeString == "jobPosterMessage" {
                
                print("poster message")
                
                let notification = NSNotification(name: "message", object: typeString, userInfo: userInfo)
                NSNotificationCenter.defaultCenter().postNotificationName("messageFromJobPosterRecieved", object: notification)
            }
        }
    }
    
    func upDataFacebookFriends() {
        
//        if PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!){
//        
//        FBSDKGraphRequest.init(graphPath: "/me", parameters: ["fields": "friends"], HTTPMethod: "GET").startWithCompletionHandler { (connection, result, error) -> Void in
//
//            //  todo crasht when no internet connectoin
//            if result.valueForKey("friends") != nil {
//                
//                
//                var index = 0
//                
//                let friendsArray: AnyObject? = result.valueForKey("friends")?.valueForKey("data")
//                
//                while index < friendsArray?.count {
//                    
//                    let userID = friendsArray?[index].valueForKey("id") as! String
//                    
//                    self.userFriendsArray.append(userID)
//                    index += 1
//                }
//            }
//            
//            
//            PFUser.currentUser()!["friendsArray"] = self.userFriendsArray
//            
//            PFUser.currentUser()?.saveInBackgroundWithBlock({ (succes, error ) -> Void in
//                
//                if error != nil {
//                    
//                    print(error?.localizedDescription)
//                } else {
//                    
//                    if succes == true {
//                        
//                        print("saved")
//                    }
//                }
//            })
//     
//            }
//        }
    }
}

