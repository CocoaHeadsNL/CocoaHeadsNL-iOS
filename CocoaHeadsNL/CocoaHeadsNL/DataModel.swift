//
//  DataModel.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 22/03/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation


class DataModel: NSObject {
    
    var companiesArray = NSMutableArray()
    var jobsArray = NSMutableArray()
    //var meetupArray = NSMutableArray()
    
    override init() {
        
        super.init()
        
        self.parseSetupForDataModel()
        //self.fetchMeetupObjectsFromParse()
        self.fetchCompaniesObjectsFromParse()
        self.fetchJobObjectsFromParse()
    }
    
    func parseSetupForDataModel()
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
    
//    func fetchMeetupObjectsFromParse() -> NSMutableArray
//    {
//        let query = PFQuery(className: "Meetup")
//        query.cachePolicy = PFCachePolicy.CacheThenNetwork
//        query.findObjectsInBackgroundWithBlock { (tArray, error) -> Void in
//            if (error != nil) {
//                print(error)
//            } else {
//                //objects should be in array
//                self.meetupArray = NSMutableArray(array: tArray)
//                //print(self.companiesArray)
//            }
//        }
//        return self.meetupArray
//    }
    
    func fetchCompaniesObjectsFromParse() -> NSMutableArray
    {
        let query = PFQuery(className: "Companies")
        query.cachePolicy = PFCachePolicy.CacheThenNetwork
        query.findObjectsInBackgroundWithBlock { (tArray, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                //objects should be in array
                self.companiesArray = NSMutableArray(array: tArray)
                //print(self.companiesArray)
            }
        }
        return self.companiesArray
    }
    
    func fetchJobObjectsFromParse() -> NSMutableArray
    {
        let query = PFQuery(className: "Job")
        query.cachePolicy = PFCachePolicy.CacheThenNetwork
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