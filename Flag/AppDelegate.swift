//
//  AppDelegate.swift
//  Flag
//
//  Created by marky RE on 11/24/2559 BE.
//  Copyright © 2559 marky RE. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import OneSignal
import FBSDKLoginKit
import Fabric
import DigitsKit
import SwiftyDrop
import BRYXBanner

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        print("did touch the notification")
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Digits.self])
        FIRApp.configure()
        FIRDatabase.database().persistenceEnabled = true
       // OneSignal.initWithLaunchOptions(launchOptions, appId: "45ce7556-1418-42c4-be8a-b7d9c3be3dca")
        OneSignal.registerForPushNotifications()
       /* OneSignal.initWithLaunchOptions( appId: "45ce7556-1418-42c4-be8a-b7d9c3be3dca", handleNotificationAction: { (result) in
            let payload: OSNotificationPayload? = result?.notification.payload
            
            var fullMessage: String? = payload?.body
            if payload?.additionalData != nil {
                var additionalData: [AnyHashable: Any]? = payload?.additionalData
               /* if additionalData!["actionSelected"] != nil {
                    fullMessage = fullMessage! + "\nPressed ButtonId:\(additionalData!["actionSelected"])"
                } */
            }
            Drop.down(fullMessage!, state: .success)
        }) */
        OneSignal.initWithLaunchOptions(launchOptions, appId: "45ce7556-1418-42c4-be8a-b7d9c3be3dca", handleNotificationReceived: { (notification) in
            print("notification receive")
            let fullMessage: String? = notification?.payload.body
            let header = notification!.payload.title
            var temp = UIImage(named: "trump")
            if let list = UserDefaults.standard.object(forKey: header!) as? Data {
                temp = NSKeyedUnarchiver.unarchiveObject(with: list) as! UIImage
            }
           //let img = UIImage().maskRoundedImage(image: temp!, radius: Float(CGFloat((temp?.size.width)!/2.0)))
            let banner = Banner(title: "yoyo", subtitle: fullMessage, image: temp, backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
            banner.shouldTintImage = false
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
        }, handleNotificationAction: { (result) in
        }, settings: [kOSSettingsKeyAutoPrompt : true,kOSSettingsKeyInFocusDisplayOption: OSNotificationDisplayType.none.rawValue])
        return true
    }
   /* func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {

        let application = UIApplication.shared
            application.applicationIconBadgeNumber+=1
        
        switch application.applicationState {
        case .active:
            //app is currently active, can update badges count here
            break
        case .inactive:
            //app is transitioning from background to foreground (user taps notification), do what you need when user taps here
            break
        case .background:
            //app is in background, if content-available key of your notification is set to 1, poll to your backend to retrieve data and update your interface here
            break
        default:
            break
        }
    } */

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url as URL!, sourceApplication: sourceApplication, annotation: annotation)
    }


}

