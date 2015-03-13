//
//  CompaniesModel.swift
//  CocoaHeadsNL
//
//  Created by Bart Hoffman on 13/03/15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import Foundation

class CompaniesModel: NSObject {
    
    var companiesArray = NSMutableArray()
    
    override init() {
        
        super.init()
        
        self.parseSetupForCompaniesModel()
        self.fetchCompaniesObjectsFromParse()
    }
    
    func parseSetupForCompaniesModel()
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
    
    func fetchCompaniesObjectsFromParse() -> NSMutableArray
    {
        let query = PFQuery(className: "Companies")
        query.findObjectsInBackgroundWithBlock { (tArray, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                //objects should be in array
                self.companiesArray = NSMutableArray(array: tArray)
                print(self.companiesArray)
            }
        }
        return self.companiesArray
    }
}