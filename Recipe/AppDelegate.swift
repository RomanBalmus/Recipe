//
//  AppDelegate.swift
//  Recipe
//
//  Created by iOS on 20/11/15.
//  Copyright © 2015 iOS. All rights reserved.
//

import UIKit
import Bolts
import Parse
import FBSDKCoreKit
import ParseFacebookUtilsV4

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Parse.enableLocalDatastore()
        Parse.setApplicationId("xoeiqkiEexXSVut8jI7ZUrcWUFiRLxWvF50IX1Pg", clientKey: "nWJGXP9RdQEPAbw2FUCtC0ErH87TvhTIFYl41FlJ")
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)



        
        
           // Register for Push Notitications
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var pushPayload = false
            if let options = launchOptions {
                pushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
     
     
        
        let q1inst = PFQuery(className: "Recipes")
        q1inst.findObjectsInBackgroundWithBlock({
            (objects: [PFObject]?, error: NSError?) -> Void in
            PFObject.pinAllInBackground(objects)

            })

        let q2inst = PFQuery(className: "Category")
        q2inst.findObjectsInBackgroundWithBlock({
            (objects: [PFObject]?, error: NSError?) -> Void in
            PFObject.pinAllInBackground(objects)
            
        })
        let q3inst = PFQuery(className: "Sub_Category")
        q3inst.findObjectsInBackgroundWithBlock({
            (objects: [PFObject]?, error: NSError?) -> Void in
            PFObject.pinAllInBackground(objects)
            
        })
        
        let q4inst = PFQuery(className: "ToDo")
        q4inst.findObjectsInBackgroundWithBlock({
            (objects: [PFObject]?, error: NSError?) -> Void in
            PFObject.pinAllInBackground(objects)
            
        })
        
       
        return true
    }
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }
    
    func application(application: UIApplication,  didReceiveRemoteNotification userInfo: [NSObject : AnyObject],  fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        if let photoId: String = userInfo["objectId"] as? String {
            let targetPhoto = PFObject(withoutDataWithClassName: "Recipes", objectId: photoId)
            targetPhoto.fetchIfNeededInBackgroundWithBlock { (object: PFObject?, error: NSError?) -> Void in
                // Show photo view controller
                if error != nil {
                    completionHandler(UIBackgroundFetchResult.Failed)
                } else if PFUser.currentUser() != nil {
                    print("show must go on")
                    //let viewController = PhotoVC(withPhoto: object)
                    //self.navController.pushViewController(viewController, animated: true)
                    completionHandler(UIBackgroundFetchResult.NewData)
                } else {
                    completionHandler(UIBackgroundFetchResult.NoData)
                }
            }
        }
        completionHandler(UIBackgroundFetchResult.NoData)
    }
    
    
    func application(application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String?,
        annotation: AnyObject) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(application,
                openURL: url,
                sourceApplication: sourceApplication,
                annotation: annotation)
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
        //FBAppCall.handleDidBecomeActiveWithSession(PFFacebookUtils.session())

        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

