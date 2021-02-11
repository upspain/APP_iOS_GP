//
//  AppDelegate.swift
//  HEYPLEASE_20170403
//
//  Created by GasPay Services on 3/4/17.
//  Copyright © 2017 CamareroApp S.L. All rights reserved.
//

import UIKit
import Mixpanel
import UserNotifications
import Firebase
//import FBSDKCoreKit
//import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var mixpanel: Mixpanel?
    let defaults = UserDefaults.standard
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("Init Mix panel")
        InitializeMixpanel()
        registerForRemoteNotification()
        InitFirebase()
        return true;
    }
    
    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink){
        guard let url = dynamicLink.url else {
            print("That's weird. My dinamic link object has no url")
            return
        }
        print("Your incoming link parameter is \(url.absoluteString)")
        defaults.set(url.absoluteString, forKey: "url_coming")
    }
    
    private func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if let incomingURL = userActivity.webpageURL {
            print("Incoming URL is \(incomingURL)")
            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL)
            { (dynamicLink, error) in
                guard error == nil else {
                    print("Found an error! \(error!.localizedDescription)")
                    return
                }
                
                if let dynamicLink = dynamicLink {
                    self.handleIncomingDynamicLink(dynamicLink)
                }
            }
            if linkHandled {
                return true
            } else {
                return false
            }
        }
        
        return false
    }
    
    func InitFirebase(){
        FirebaseApp.configure()
    }
    
    func InitializeMixpanel() {
        print("******************************")
        print("InitializeMixpanel")
        print("******************************")
        Mixpanel.sharedInstance(withToken: "3d50e9e5a2f44cbe31d2db5be1d6f44a")
        mixpanel?.showNotificationOnActive = true
    }
    
    func registerForRemoteNotification() {
        print("register Remote Notification")
        if #available(iOS 10.0, *) {
            print("ios > 8")
            let center  = UNUserNotificationCenter.current()
            center.delegate = self as? UNUserNotificationCenterDelegate
            center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                if error == nil{
                    DispatchQueue.main.async {
                        print("register ui application")
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        }
        else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground")
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication){
        print("applicationDidBecomeActive")
        /*let settings = UIUserNotificationSettings(types: [ .badge, .sound, .alert], categories:nil)
         application.registerUserNotificationSettings(settings)
         application.registerForRemoteNotifications() */
        //FBSDKAppEvents.activateApp()
        (window?.rootViewController as? ViewController)?.checkStatus()
    }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("applicationWillTerminate")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        /*let loginManager: FBSDKLoginManager = FBSDKLoginManager()/Users/gourmetpay/Documents/GourmetPay_produccion/HeyPlease/HeyPlease/AppDelegate.swift
         loginManager.logOut()*/
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("token")
        print("******************************")
        print(deviceToken)
        print("******************************")
        
        defaults.set(deviceToken, forKey: "token")
        defaults.synchronize()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Remote notification support is unavailable due to error:"+error.localizedDescription)
    }
}


