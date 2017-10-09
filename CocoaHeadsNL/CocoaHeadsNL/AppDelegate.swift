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

    func applicationDidBecomeActive(_ application: UIApplication) {
        if let pasteboard = UIPasteboard(name: UIPasteboardName(rawValue: "searchPasteboardName"), create: false) {
            pasteboard.string = ""
        }

        let badgeResetOperation = CKModifyBadgeOperation(badgeValue: 0)
        badgeResetOperation.modifyBadgeCompletionBlock = { (error) -> Void in
            guard error == nil else {
                print("Error resetting badge: \(String(describing: error))")
                return
            }
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        }
        CKContainer.default().add(badgeResetOperation)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        if error._code == 3010 {
            print("Push Notifications are not supported in the simulator")
        } else {
            print("application didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {

        let cloudKitNotification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String : NSObject])
        if cloudKitNotification.notificationType == .query,
            let queryNotification = cloudKitNotification as? CKQueryNotification {
            //TODO handle the different notifications to show the correct items
            let recordID = queryNotification.recordID
            print(recordID as Any)
            //...
            self.presentMeetupsViewController()
        }

    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])

        let notificationTypes: UIUserNotificationType = [.alert, .badge, .sound]

        let settings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()

        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if #available(iOS 9.0, *) {
            if userActivity.activityType == CSSearchableItemActionType {
                let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as! String
                let components = uniqueIdentifier.components(separatedBy: ":")
                let type = components[0]
                let objectId = components[1]
                if type == "job" || type == "meetup" {
                    //post uniqueIdentifier string to paste board
                    let pasteboard = UIPasteboard(name: UIPasteboardName(rawValue: "searchPasteboardName"), create: true)
                    pasteboard?.string = uniqueIdentifier

                    //open tab, select based on uniqueId
                    NotificationCenter.default.post(name: Notification.Name(rawValue: searchNotificationName), object: self, userInfo: ["type" : type, "objectId": objectId])
                    return true
                }
            }
        }

        return false
    }

    @available(iOS 9.0, *)
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
            handleShortCutItem(shortcutItem)
            completionHandler(true)
    }

    @available(iOS 9.0, *)
    func handleShortCutItem(_ shortCutItem: UIApplicationShortcutItem) {

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
