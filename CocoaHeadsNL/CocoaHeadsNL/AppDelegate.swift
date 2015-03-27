//
//  AppDelegate.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 07/03/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        var parseApplicationId : String?
        var parseClientKey : String?
        
        if let path = NSBundle.mainBundle().pathForResource("ParseConfig", ofType: "plist") {
            var myDict = NSDictionary(contentsOfFile: path)
            if let dict = myDict {
                parseApplicationId = dict.objectForKey("applicationId") as? String
                parseClientKey = dict.objectForKey("clientKey") as? String
            }
        }
        assert(parseApplicationId != nil || parseClientKey != nil, "Parse credentials not configured. Please see README.md.")

        // Enable Crash Reporting
        ParseCrashReporting.enable()
        // Setup Parse
        Parse.setApplicationId(parseApplicationId!, clientKey: parseClientKey!)
        
        PFUser.enableAutomaticUser()
        PFUser.currentUser().saveInBackgroundWithBlock(nil)
        
        PFConfig.getConfigInBackgroundWithBlock(nil)
        
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
        
        return true
    }
}

