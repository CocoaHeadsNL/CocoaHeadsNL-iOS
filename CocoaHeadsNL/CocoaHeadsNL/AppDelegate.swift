//
//  AppDelegate.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 07/03/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import UIKit
import CoreSpotlight

let searchNotificationName = "CocoaHeadsNLSpotLightSearchOccured"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    struct ParseConfiguration {
        let applicationId: String
        let clientKey: String
    }

    func loadParseConfiguration() -> ParseConfiguration {
        if let path = NSBundle.mainBundle().pathForResource("ParseConfig", ofType: "plist"),
               dict = NSDictionary(contentsOfFile: path),
               applicationId = dict.objectForKey("applicationId") as? String,
               clientKey = dict.objectForKey("clientKey") as? String {
            return ParseConfiguration(applicationId: applicationId, clientKey: clientKey)
        }
        fatalError("Parse credentials not configured. Please see README.md.")
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        ParseCrashReporting.enable()

        let config = loadParseConfiguration()
        Parse.setApplicationId(config.applicationId, clientKey: config.clientKey)

        PFUser.enableRevocableSessionInBackground()
        if let user = PFUser.currentUser() where PFAnonymousUtils.isLinkedWithUser(user) {
            PFUser.logOut()
        }

        PFConfig.getConfigInBackground()

        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)

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
                    //TODO open tab, select based on uniqueId
                    NSNotificationCenter.defaultCenter().postNotificationName(searchNotificationName, object: self, userInfo: ["type" : type, "objectId": objectId])
                    return true
                }
            }
        }
        
        return false
    }
}
