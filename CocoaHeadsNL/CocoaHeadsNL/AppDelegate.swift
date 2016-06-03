//
//  AppDelegate.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 07/03/15.
//  Copyright (c) 2016 Stichting CocoaheadsNL. All rights reserved.
//

import UIKit
import CoreSpotlight
import CloudKit

import Fabric
import Crashlytics

let searchNotificationName = "CocoaHeadsNLSpotLightSearchOccured"
let searchPasteboardName = "CocoaHeadsNL-searchInfo-pasteboard"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func applicationDidBecomeActive(application: UIApplication) {
        if let pasteboard = UIPasteboard(name: "searchPasteboardName", create: false) {
            pasteboard.string = ""
        }

        let badgeResetOperation = CKModifyBadgeOperation(badgeValue: 0)
        badgeResetOperation.modifyBadgeCompletionBlock = { (error) -> Void in
            guard error == nil else {
                print("Error resetting badge: \(error)")
                return
            }
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        }
        CKContainer.defaultContainer().addOperation(badgeResetOperation)
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {

    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push Notifications are not supported in the simulator")
        } else {
            print("application didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {

        let cloudKitNotification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String : NSObject])
        if cloudKitNotification.notificationType == .Query,
            let queryNotification = cloudKitNotification as? CKQueryNotification {
            //TODO handle the different notifications to show the correct items
            let recordID = queryNotification.recordID
            print(recordID)
            //...
            self.presentMeetupsViewController()
        }

    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics.self])

        let notificationTypes: UIUserNotificationType = [.Alert, .Badge, .Sound]

        let settings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()

        return true
    }

    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        if #available(iOS 9.0, *) {
            if userActivity.activityType == CSSearchableItemActionType {
                let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as! String
                let components = uniqueIdentifier.componentsSeparatedByString(":")
                let type = components[0]
                let objectId = components[1]
                if type == "job" || type == "meetup" {
                    //post uniqueIdentifier string to paste board
                    let pasteboard = UIPasteboard(name: "searchPasteboardName", create: true)
                    pasteboard?.string = uniqueIdentifier

                    //open tab, select based on uniqueId
                    NSNotificationCenter.defaultCenter().postNotificationName(searchNotificationName, object: self, userInfo: ["type" : type, "objectId": objectId])
                    return true
                }
            }
        }

        return false
    }

    @available(iOS 9.0, *)
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
            handleShortCutItem(shortcutItem)
            completionHandler(true)
    }

    @available(iOS 9.0, *)
    func handleShortCutItem(shortCutItem: UIApplicationShortcutItem) {

        switch shortCutItem.type {
        case "nl.cocoaheads.CocoaHeadsNL.meetup" :
            presentMeetupsViewController()
        case "nl.cocoaheads.CocoaHeadsNL.job" :
            presentJobsViewController()
        case "nl.cocoaheads.CocoaHeadsNL.companies" :
            presentCompaniesViewController()
        default: break
        }
    }

    func presentMeetupsViewController() {
        //print("should open selected tab"

        let splitViewController = self.window?.rootViewController as! SplitViewController
        if let tabBar = splitViewController.viewControllers[0] as? UITabBarController {
        tabBar.selectedIndex = 0
        }

    }

    func presentJobsViewController() {
        let splitViewController = self.window?.rootViewController as! SplitViewController
        if let tabBar = splitViewController.viewControllers[0] as? UITabBarController {
        tabBar.selectedIndex = 1
        }
    }

    func presentCompaniesViewController() {
        let splitViewController = self.window?.rootViewController as! SplitViewController
        if let tabBar = splitViewController.viewControllers[0] as? UITabBarController {
        tabBar.selectedIndex = 2
        }

    }

}
