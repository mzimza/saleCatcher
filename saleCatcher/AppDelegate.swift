//
//  AppDelegate.swift
//  saleCatcher
//
//  Created by Maja Zalewska on 01/08/16.
//  Copyright © 2016 Maja Zalewska. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //request authorization for notifications
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            // Enable or disable features based on authorization.
            print("Notifications granted")
        }
        
        center.getPendingNotificationRequests(completionHandler: {
        tab in
            for x in tab {
                print(x)
            }
        })
        
        
        // Background fetch
        UIApplication.shared.setMinimumBackgroundFetchInterval(
            UIApplicationBackgroundFetchIntervalMinimum)
        
        
        
        let tabBarController = UITabBarController()
        let productsVC = ProductsViewController() //nibName: "ProductsViewController", bundle: nil)
        let selectedVC = SelectedViewController()
        let controllers = [productsVC, selectedVC]
        tabBarController.viewControllers = controllers
        window?.rootViewController = tabBarController
       // let firstImage = UIImage(named: "pie bar icon")
       // let secondImage = UIImage(named: "pizza bar icon")
        productsVC.tabBarItem = UITabBarItem(
            title: "All",
            image: nil,
            tag: 1)
        selectedVC.tabBarItem = UITabBarItem(
            title: "Selected",
            image: nil,
            tag:2)

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // Support for background fetch
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let tabBarController = window?.rootViewController as? UITabBarController,
            let viewControllers = tabBarController.viewControllers {
            for viewController in viewControllers {
                if let productsViewController = viewController as? ProductsViewController {
                    productsViewController.fetch {
                        productsViewController.refresh(productsViewController.refreshControl)
                        completionHandler(.newData)
                    }
                }
            }
        }

    }
   
   
}

