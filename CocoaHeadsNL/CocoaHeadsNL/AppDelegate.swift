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
import UserNotifications

import RealmSwift
import Fabric
import Crashlytics

let searchNotificationName = "CocoaHeadsNLSpotLightSearchOccured"
let searchPasteboardName = "CocoaHeadsNL-searchInfo-pasteboard"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])

        handleRealmMigration()
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in

            guard error == nil else {
                //Display Error.. Handle Error.. etc..
                return
            }

            if granted {
                //Do stuff here..
                self.setCategories()
                self.subscribe()
                self.subscribeToItems()
                //Register for RemoteNotifications. Your Remote Notifications can display alerts now :)
                DispatchQueue.main.async {
                application.registerForRemoteNotifications()
                    print("registered for notifications")
                }
            }
            else {
                //Handle user denying permissions..
                DispatchQueue.main.async {
                    application.unregisterForRemoteNotifications()
                    print("unregistered for notifications")
                }
                
                //not using the deletion in production, but very handy during debugging.
//                //Deleting al previous cloudkit subscriptions for a user.
//                let publicDB = CKContainer.default().publicCloudDatabase
//
//                publicDB.fetchAllSubscriptions(completionHandler: {subscriptions, error in
//
//                    if let subs = subscriptions {
//                        //Removing the subscriptions in any other case than authorized
//                        for subscription in subs {
//                            publicDB.delete(withSubscriptionID: subscription.subscriptionID, completionHandler: {subscriptionId, error in
//                            })
//                        }
//                        print("removed subscriptions")
//                    }
//                })
            }
        }
        
        //if app was not running or in the background, didFinishLoading will receive the notification. Starting same behaviour here.
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {

            let aps = notification["aps"] as! [String: AnyObject]
            print("DidLaunch: \(aps)")
            
            if aps["category"] as? String == "nl.cocoaheads.app.CocoaHeadsNL.generalNotification" {
                print("general notification")
            } else if aps["category"] as? String == "nl.cocoaheads.app.CocoaHeadsNL.itemNotification" {
               print("item Notification")
            } else if aps["category"] as? String == "MEETUP" {
                self.presentMeetupsViewController()
            } else if aps["category"] as? String == "JOB" {
                self.presentJobsViewController()
            } else if aps["category"] as? String == "COMPANY" {
                self.presentCompaniesViewController()
            }
            
        }
        return true
    }

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
    
     // MARK: Register categories and subscribtion
    
    func setCategories() {
        
        let itemCategory = UNNotificationCategory(identifier: "nl.cocoaheads.app.CocoaHeadsNL.itemNotification",
                                                     actions: [],
                                                     intentIdentifiers: [],
                                                     options: .customDismissAction)
        
        let generalCategory = UNNotificationCategory(identifier: "nl.cocoaheads.app.CocoaHeadsNL.generalNotification",
                                                     actions: [],
                                                     intentIdentifiers: [],
                                                     options: .customDismissAction)
        
        // Create the custom actions for the category.
        let openAction = UNNotificationAction(identifier: "OPEN_MEETUP",
                                              title: "Open Events",
                                              options: [.foreground])
        
        let meetupCategory = UNNotificationCategory(identifier: "MEETUP",
                                                    actions: [openAction],
                                                    intentIdentifiers: [],
                                                    options: [.customDismissAction])
        
        let openJobAction = UNNotificationAction(identifier: "OPEN_JOB",
                                                 title: "Open Jobs",
                                                 options: [.foreground])
        
        let jobCategory = UNNotificationCategory(identifier: "JOB",
                                                 actions: [openJobAction],
                                                 intentIdentifiers: [],
                                                 options: [.customDismissAction])
        
        let openCompanyAction = UNNotificationAction(identifier: "OPEN_COMPANY",
                                                     title: "Open Companies",
                                                     options: [.foreground])
        
        let companyCategory = UNNotificationCategory(identifier: "COMPANY",
                                                     actions: [openCompanyAction],
                                                     intentIdentifiers: [],
                                                     options: [.customDismissAction])
        
        // Register the notification categories.
        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories([itemCategory, generalCategory, meetupCategory, jobCategory, companyCategory])
    }
    
    func subscribeToItems() {
         let publicDB = CKContainer.default().publicCloudDatabase
        
        let subscription = CKQuerySubscription(recordType: "Items", predicate: NSPredicate(format: "TRUEPREDICATE"), options: .firesOnRecordCreation)
        
        //if the subscription does not have a title, subtitle ,alertbody it wont get priority. IS received in the content service extension.
        let info = CKNotificationInfo()
        info.title = "A new item was posted"
        info.subtitle = "by CocoaHeadsNL"
        info.alertBody = "Want to know more?"
        info.desiredKeys = ["title","name","imageUrl"]
        info.shouldSendMutableContent = true
        info.category = "nl.cocoaheads.app.CocoaHeadsNL.itemNotification"
        
        subscription.notificationInfo = info
        
        publicDB.save(subscription, completionHandler: { subscription, error in
            if error == nil {
                // Subscription saved successfully
            } else {
                // An error occurred
                //print(error)
            }
        })
    }
    
    func subscribe() {
        let publicDB = CKContainer.default().publicCloudDatabase
        
        let subscription = CKQuerySubscription(recordType: "Test", predicate: NSPredicate(format: "TRUEPREDICATE"), options: .firesOnRecordCreation)
        
        //silent notification which gets handled by the generalNotification Extension. IS received in the app.
        let info = CKNotificationInfo()
        info.desiredKeys = ["title","subtitle","body"]
        info.shouldBadge = true
        info.shouldSendContentAvailable = true
        info.category = "nl.cocoaheads.app.CocoaHeadsNL.generalNotification"

        subscription.notificationInfo = info
        
        publicDB.save(subscription, completionHandler: { subscription, error in
            if error == nil {
                // Subscription saved successfully
            } else {
                // An error occurred
                //print(error)
            }
        })
    }

    // MARK: Notifications

    //func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //Note that CloudKit does handle device tokens for you, so you don't need to implement the application(_:didRegisterForRemoteNotificationsWithDeviceToken:) method, unless you need that for another purpose.
    //}

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        if error._code == 3010 {
            print("Push Notifications are not supported in the simulator")
        } else {
            print("application didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            //not using willPresent will prevent any Pushnotifications to show when the app is active.
           completionHandler([.alert, .badge, .sound])
    }
    
  
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        //Only remoteNotifications (content-available) will trigger this and depending on type should change behaviour.
        // remoteNotifications (mutable-content) wont.
        let ck = CKQueryNotification.init(fromRemoteNotificationDictionary: userInfo)

        switch application.applicationState {
            
        case .inactive:
            print("Inactive")
            //Show the view with the content of the push
            self.handleRemoteNotification(notification: ck)
            completionHandler(.newData)

        case .background:
            print("Background")
            //Refresh the local model
            self.handleRemoteNotification(notification: ck)
            completionHandler(.newData)
            
        case .active:
            print("Active")
            self.handleRemoteNotification(notification: ck)
            completionHandler(.newData)
        }
    }
    
    func handleRemoteNotification(notification:CKQueryNotification? ) {
        
        let content = UNMutableNotificationContent()
        
        if let category = notification?.category {
            
            if category == "nl.cocoaheads.app.CocoaHeadsNL.generalNotification" {
                
                if let note = notification, let category = note.category, let title = note.recordFields?["title"] as? String, let subtitle = note.recordFields?["subtitle"] as? String, let body = note.recordFields?["body"] as? String {
                    
                    content.categoryIdentifier = category
                    content.title = title
                    content.subtitle = subtitle
                    content.body = body
                    content.sound = UNNotificationSound.default()

                    //for now using a local image file as attachment.
                    if let path = Bundle.main.path(forResource: "CocoaHeadsNL500", ofType: "png") {
                        let url = URL(fileURLWithPath: path)
                        
                        do {
                            let attachment = try UNNotificationAttachment(identifier: "logo", url: url, options: nil)
                            content.attachments = [attachment]
                        } catch {
                            print("The attachment was not loaded.")
                        }
                    }
                    
                    let request = UNNotificationRequest(identifier: "generalNotification", content: content, trigger: nil) // Schedule the notification.
                    let center = UNUserNotificationCenter.current()
                    center.add(request) { (error : Error?) in
                        if let theError = error {
                            // Handle any errors
                            print(theError)
                        }
                    }
                }
            } else {
                
                if let note = notification, let category = note.category, let title = note.recordFields?["title"] as? String, let subtitle = note.recordFields?["subtitle"] as? String, let body = note.recordFields?["body"] as? String {
                    
                    content.categoryIdentifier = category
                    content.title = title
                    content.subtitle = subtitle
                    content.body = body
                    content.sound = UNNotificationSound.default()
                    
                    let request = UNNotificationRequest(identifier: "showNotification", content: content, trigger: nil) // Schedule the notification.
                    let center = UNUserNotificationCenter.current()
                    center.add(request) { (error : Error?) in
                        if let theError = error {
                            // Handle any errors
                            print(theError)
                        }
                    }
                }
            }
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.actionIdentifier == UNNotificationDismissActionIdentifier {
            // The user dismissed the notification without taking action
        } else if response.actionIdentifier == "OPEN_MEETUP" {
               self.presentMeetupsViewController()
        } else if response.actionIdentifier == "OPEN_JOB" {
            self.presentJobsViewController()
        } else if response.actionIdentifier == "OPEN_COMPANY" {
            self.presentCompaniesViewController()
        } else if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            // The user launched the app
        }
        
        //Deprecated in ios11, still to find a replacement
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
        
        completionHandler()
    }

     // MARK: UserActivity

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

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
            handleShortCutItem(shortcutItem)
            completionHandler(true)
    }

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

    // MARK: Open ViewControllers
    //Opening the right tab (could make this the correct item though)
    
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

    // MARK: Realm

    func handleRealmMigration() {

        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 1,

            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })

        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config

        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        let _ = try! Realm()
    }
}

extension Notification.Name {
    static let apiServerUnreachable = Notification.Name("apiServerUnreachable")
    static let itemsLoaded = Notification.Name("itemsLoaded")
}
