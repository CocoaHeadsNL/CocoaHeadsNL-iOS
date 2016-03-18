//
//  ModelObjects.swift
//  CocoaHeadsNL
//
//  Created by Jeroen Leenarts on 27-03-15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import UIKit
import CoreSpotlight
import MobileCoreServices
import CloudKit

let indexQueue = NSOperationQueue()

var jobsIndexBackgroundTaskID = UIBackgroundTaskInvalid
var meetupsIndexBackgroundTaskID = UIBackgroundTaskInvalid


class AffiliateLink : NSObject {
    
    var recordID: CKRecordID?
    var affiliateId: String?
    var productCreator: String?
    var productName: String?
    var company: Company?
}

//class APIKey : PFObject, PFSubclassing {
//    override class func initialize() {
//        struct Static {
//            static var onceToken : dispatch_once_t = 0;
//        }
//        dispatch_once(&Static.onceToken) {
//            self.registerSubclass()
//        }
//    }
//
//    class func parseClassName() -> String {
//        return "APIKey"
//    }
//
//    @NSManaged var apiKeyString: String?
//    @NSManaged var serviceName: String?
//}

class Company : NSObject {
    
    var recordID: CKRecordID?
    var name: String?
    var place: String?
    var streetAddress: String?
    var website: String?
    var zipCode: String?
    var companyDescription: String?
    var emailAddress: String?
    var location: CLLocation?
    var logo: CKAsset?
    var hasApps: Bool = false
    var smallLogo: CKAsset?
}

class Contributor : NSObject {
    
    var recordID: CKRecordID?
    var avatar_url: String?
    var contributor_id: Int64?
    var name: String?
    var url: String?
}

class Job : NSObject {
   
    var recordID: CKRecordID?
    var content: String?
    var date: String?
    var link: String?
    var title: String?
    var logo: CKAsset?
    
    @available(iOS 9.0, *)
    var searchableAttributeSet: CSSearchableItemAttributeSet {
        get {
            let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeImage as String)
            attributeSet.title = title
            if let data = content?.dataUsingEncoding(NSUTF8StringEncoding) {
                do {
                    let jobDescriptionString = try NSAttributedString(data: data, options:[NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding], documentAttributes:nil)
                    
                    attributeSet.contentDescription = jobDescriptionString.string;
                } catch {
                    print("Stuff went crazy!")
                }
            }
            attributeSet.creator = "CocoaHeadsNL";
            do {
                guard let url = logo?.fileURL else {
                    return attributeSet
                }
                
                if let smallLogoImage = UIImage(data: NSData(contentsOfURL: url)!) {
                    attributeSet.thumbnailData = UIImagePNGRepresentation(smallLogoImage);
                }
            }
            
            return attributeSet
        }
    }
    
    class func index(jobs: [Job]) {
        if #available(iOS 9.0, *) {
            indexQueue.addOperationWithBlock({ () -> Void in
                
                guard jobsIndexBackgroundTaskID == UIBackgroundTaskInvalid else {
                    return
                }
                
                jobsIndexBackgroundTaskID = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
                    UIApplication.sharedApplication().endBackgroundTask(jobsIndexBackgroundTaskID)
                    jobsIndexBackgroundTaskID = UIBackgroundTaskInvalid
                })
                
                var searchableItems = [CSSearchableItem]()
                for job in jobs {
                    if let recordID = job.recordID {
                        let item = CSSearchableItem(uniqueIdentifier: "job:\(recordID)", domainIdentifier: "job", attributeSet: job.searchableAttributeSet)
                        searchableItems.append(item)
                    }
                }
                
//                CSSearchableIndex.defaultSearchableIndex().deleteSearchableItemsWithDomainIdentifiers(["job"], completionHandler: { (error: NSError?) -> Void in
//                    if let error = error {
//                        print(error)
//                    }
//                })

                
                CSSearchableIndex.defaultSearchableIndex().indexSearchableItems(searchableItems, completionHandler: { (error: NSError?) -> Void in
                    if let error = error {
                        print(error)
                    }
                })
                
                UIApplication.sharedApplication().endBackgroundTask(jobsIndexBackgroundTaskID)
                jobsIndexBackgroundTaskID = UIBackgroundTaskInvalid
            })
        }
    }
}

class Meetup : NSObject {
  
    var recordID: CKRecordID?
    var duration: NSNumber!
    var geoLocation: CLLocation?
    var locationName: String?
    var meetup_description: String?
    var meetup_id: String?
    var name: String?
    var rsvp_limit: NSNumber!
    var time: NSDate?
    var yes_rsvp_count: NSNumber!
    var logo: CKAsset?
    var nextEvent: DarwinBoolean?
    var smallLogo: CKAsset?
    var location: String?
    
    @available(iOS 9.0, *)
    var searchableAttributeSet: CSSearchableItemAttributeSet {
        get {
            let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeImage as String)
            attributeSet.title = name
            if let data = meetup_description?.dataUsingEncoding(NSUTF8StringEncoding) {
                do {
                    let meetupDescriptionString = try NSAttributedString(data: data, options:[NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding], documentAttributes:nil)
                    
                    attributeSet.contentDescription = meetupDescriptionString.string;
                } catch {
                    print("Stuff went crazy!")
                }
            }
            attributeSet.creator = "CocoaHeadsNL";
            var keywords = ["CocoaHeadsNL"]
            if let locationName = locationName {
                keywords.append(locationName)
            }
            if let location = location {
                keywords.append(location)
            }

            attributeSet.keywords = keywords
            do {
                guard let url = smallLogo?.fileURL else {
                    return attributeSet
                }
                
                if let smallLogoImage = UIImage(data: NSData(contentsOfURL: url)!) {
                    attributeSet.thumbnailData = UIImagePNGRepresentation(smallLogoImage);
                }
            }
            
            return attributeSet
        }
    }

    class func index(meetups: [Meetup]) {
        if #available(iOS 9.0, *) {
            indexQueue.addOperationWithBlock({ () -> Void in
                
                guard meetupsIndexBackgroundTaskID == UIBackgroundTaskInvalid else {
                    return
                }

                meetupsIndexBackgroundTaskID = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
                    UIApplication.sharedApplication().endBackgroundTask(jobsIndexBackgroundTaskID)
                    meetupsIndexBackgroundTaskID = UIBackgroundTaskInvalid
                })

                var searchableItems = [CSSearchableItem]()
                for meetup in meetups {
                    if let recordID = meetup.recordID {
                        let item = CSSearchableItem(uniqueIdentifier: "meetup:\(recordID)", domainIdentifier: "meetup", attributeSet: meetup.searchableAttributeSet)
                        searchableItems.append(item)
                    }
                }
                
//                CSSearchableIndex.defaultSearchableIndex().deleteSearchableItemsWithDomainIdentifiers(["meetup"], completionHandler: { (error: NSError?) -> Void in
//                    if let error = error {
//                        print(error)
//                    }
//                })
                
                CSSearchableIndex.defaultSearchableIndex().indexSearchableItems(searchableItems, completionHandler: { (error: NSError?) -> Void in
                    if let error = error {
                        print(error)
                    }
                })
                
                UIApplication.sharedApplication().endBackgroundTask(jobsIndexBackgroundTaskID)
                meetupsIndexBackgroundTaskID = UIBackgroundTaskInvalid
            })
        }
    }
}
