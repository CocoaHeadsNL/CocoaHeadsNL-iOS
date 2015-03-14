//
//  JobsModel.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 13/03/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation

class JobsModel: NSObject {
    
    var jobsArray = NSMutableArray()
    
    override init() {
        
        super.init()
        
        self.parseSetupForJobsModel()
        self.fetchJobObjectsFromParse()
    }
    
    func parseSetupForJobsModel()
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
    }
    
    func fetchJobObjectsFromParse() -> NSMutableArray
    {
        let query = PFQuery(className: "Job")
        query.findObjectsInBackgroundWithBlock { (tempArray, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                //objects should be in array
                self.jobsArray = NSMutableArray(array: tempArray)
                //print(self.jobsArray)
            }
        }
        return self.jobsArray
    }
}