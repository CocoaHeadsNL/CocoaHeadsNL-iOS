//
//  ModelObjects.swift
//  CocoaHeadsNL
//
//  Created by Jeroen Leenarts on 27-03-15.
//  Copyright (c) 2016 Stichting CocoaheadsNL. All rights reserved.
//

import UIKit
import CoreSpotlight
import MobileCoreServices
import CloudKit
import RealmSwift

let indexQueue = NSOperationQueue()

var jobsIndexBackgroundTaskID = UIBackgroundTaskInvalid
var meetupsIndexBackgroundTaskID = UIBackgroundTaskInvalid


class AffiliateLink {
    let recordID: CKRecordID
    let affiliateId: String?
    let productCreator: String?
    let productName: String?
    let company: CKReference?

    init(record: CKRecord) {
        self.recordID = record.recordID
        self.affiliateId = record["affiliateId"] as? String
        self.productName = record["productName"] as? String
        self.productCreator = record["productCreator"] as? String
        self.company = record["company"] as? CKReference

    }
}

class Company: Object {

    static func company(forRecord record: CKRecord) -> Company {
        let newCompany = Company()
        newCompany.recordName = (record.recordID as CKRecordID?)?.recordName
        newCompany.name = record["name"] as? String
        newCompany.place = record["place"] as? String
        newCompany.streetAddress = record["streetAddress"] as? String
        newCompany.website = record["website"] as? String
        newCompany.zipCode = record["zipCode"] as? String
        newCompany.companyDescription = record["companyDescription"] as? String
        newCompany.emailAddress = record["emailAddress"] as? String
        newCompany.latitude = (record["location"] as? CLLocation)?.coordinate.latitude ?? 0.0
        newCompany.longitude = (record["location"] as? CLLocation)?.coordinate.longitude ?? 0.0
        newCompany.hasApps = record["hasApps"] as? Bool ?? false

        if let logoAsset = record["logo"] as? CKAsset {
            newCompany.logo = NSData(contentsOfURL: logoAsset.fileURL)
        }
        if let logoAsset = record["smallLogo"] as? CKAsset {
            newCompany.smallLogo = NSData(contentsOfURL: logoAsset.fileURL)
        }

        return newCompany
    }
    
    override static func primaryKey() -> String? {
        return "recordName"
    }

    dynamic var recordName: String?
    dynamic var name: String?
    dynamic var place: String?
    dynamic var streetAddress: String?
    dynamic var website: String?
    dynamic var zipCode: String?
    dynamic var companyDescription: String?
    dynamic var emailAddress: String?
    dynamic var latitude: CLLocationDegrees = 0.0
    dynamic var longitude: CLLocationDegrees = 0.0
    dynamic var logo: NSData?
    dynamic var hasApps: Bool = false
    dynamic var smallLogo: NSData?
    
    override static func ignoredProperties() -> [String] {
        return ["logoImage", "smallLogoImage"]
    }

    lazy var logoImage: UIImage = {
        if let logo = self.logo, image = UIImage(data:logo) {
            return image
        } else {
            return UIImage(named: "CocoaHeadsNLLogo")!
        }
    }()

    lazy var smallLogoImage: UIImage = {
        if let logo = self.smallLogo, image = UIImage(data:logo) {
            return image
        } else {
            return UIImage(named: "CocoaHeadsNLLogo")!
        }
    }()
}

class Contributor: Object {
    static func contributor(forRecord record: CKRecord) -> Contributor {
        let contributor = Contributor()
        contributor.recordName = record.recordID.recordName
        contributor.name = record["name"] as? String ?? ""
        contributor.url = record["url"] as? String ?? ""
        contributor.avatar_url = record["avatar_url"] as? String ?? ""
        contributor.contributor_id = record["contributor_id"] as? Int64 ?? 0
        contributor.commit_count = record["commit_count"] as? Int ?? 0
        return contributor
    }

    override static func primaryKey() -> String? {
        return "recordName"
    }

    dynamic var recordName: String?
    dynamic var avatar_url: String?
    dynamic var contributor_id: Int64 = 0
    dynamic var commit_count: Int = 0
    dynamic var name: String?
    dynamic var url: String?
}

class Job {

    let recordID: CKRecordID
    let content: String
    let date: NSDate
    let link: String
    let title: String
    let logoURL: NSURL?

    init(record: CKRecord) {

        self.recordID = record.recordID
        self.content = record["content"] as? String ?? ""
        self.date = record["date"] as? NSDate ?? NSDate()
        self.link = record["link"] as? String ?? ""
        self.title = record["title"] as? String ?? ""
        if let logoURLString = record["logoUrl"] as? String {
            self.logoURL = NSURL(string: logoURLString)
        } else {
            self.logoURL = nil
        }
    }

    lazy var logoImage: UIImage = {
        let logoImage: UIImage
        if let logoURL = self.logoURL, data = NSData(contentsOfURL: logoURL) {
            if let image = UIImage(data:data) {
                return image
            } else {
                return UIImage(named: "CocoaHeadsNLLogo")!
            }
        } else {
            return UIImage(named: "CocoaHeadsNLLogo")!
        }
    }()

    @available(iOS 9.0, *)
    var searchableAttributeSet: CSSearchableItemAttributeSet {
        get {
            let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeImage as String)
            attributeSet.title = title
            if let data = content.dataUsingEncoding(NSUTF8StringEncoding) {
                do {
                    let jobDescriptionString = try NSAttributedString(data: data, options:[NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding], documentAttributes:nil)

                    attributeSet.contentDescription = jobDescriptionString.string
                } catch {
                    print("Stuff went crazy!")
                }
            }
            attributeSet.creator = "CocoaHeadsNL"
            attributeSet.thumbnailData = UIImagePNGRepresentation(logoImage)

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
                    let item = CSSearchableItem(uniqueIdentifier: "job:\(job.recordID)", domainIdentifier: "job", attributeSet: job.searchableAttributeSet)
                    searchableItems.append(item)
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

class Meetup: Object {

    static func meetup(forRecord record: CKRecord) -> Meetup {
        let meetup = Meetup()
        meetup.recordName = (record.recordID as CKRecordID?)?.recordName
        meetup.name = record["name"] as? String ?? ""
        meetup.meetup_id = record["meetup_id"] as? String
        meetup.meetup_description = record["meetup_description"] as? String ?? ""
        meetup.latitude = (record["location"] as? CLLocation)?.coordinate.latitude ?? 0.0
        meetup.longitude = (record["location"] as? CLLocation)?.coordinate.longitude ?? 0.0
        meetup.location = record["location"] as? String ?? ""
        meetup.locationName = record["locationName"] as? String ?? ""
        meetup.time = record["time"] as? NSDate
        meetup.nextEvent = record["nextEvent"] as? Bool ?? false

        meetup.duration = record.objectForKey("duration") as? NSNumber ?? 0
        meetup.rsvp_limit = record.objectForKey("rsvp_limit") as? NSNumber ?? 0
        meetup.yes_rsvp_count = record.objectForKey("yes_rsvp_count") as? NSNumber ?? 0
        meetup.meetupUrl = record.objectForKey("meetup_url") as? String
        
        if let logoAsset = record["logo"] as? CKAsset {
            meetup.logo = NSData(contentsOfURL: logoAsset.fileURL)
        }
        if let logoAsset = record["smallLogo"] as? CKAsset {
            meetup.smallLogo = NSData(contentsOfURL: logoAsset.fileURL)
        }
        
        return meetup
    }

    override static func primaryKey() -> String? {
        return "recordName"
    }

    dynamic var recordName: String?
    dynamic var duration: NSNumber = 0
    dynamic var latitude: CLLocationDegrees = 0.0
    dynamic var longitude: CLLocationDegrees = 0.0
    dynamic var locationName: String?
    dynamic var meetup_description: String?
    dynamic var meetup_id: String?
    dynamic var name: String?
    dynamic var rsvp_limit: NSNumber = 0
    dynamic var time: NSDate?
    dynamic var yes_rsvp_count: NSNumber = 0
    dynamic var logo: NSData?
    dynamic var nextEvent: Bool = false
    dynamic var smallLogo: NSData?
    dynamic var location: String?
    dynamic var meetupUrl: String?
    
    override static func ignoredProperties() -> [String] {
        return ["logoImage", "smallLogoImage", "searchableAttributeSet"]
    }

    lazy var logoImage: UIImage = {
        if let logo = self.logo, image = UIImage(data:logo) {
            return image
        } else {
            return UIImage(named: "CocoaHeadsNLLogo")!
        }
    }()
    
    lazy var smallLogoImage: UIImage = {
        if let logo = self.smallLogo, image = UIImage(data:logo) {
            return image
        } else {
            return UIImage(named: "CocoaHeadsNLLogo")!
        }
    }()

    @available(iOS 9.0, *)
    var searchableAttributeSet: CSSearchableItemAttributeSet {
        get {
            let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeImage as String)
            attributeSet.title = name
            if let data = meetup_description?.dataUsingEncoding(NSUTF8StringEncoding) {
                do {
                    let meetupDescriptionString = try NSAttributedString(data: data, options:[NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding], documentAttributes:nil)

                    attributeSet.contentDescription = meetupDescriptionString.string
                } catch {
                    print("Stuff went crazy!")
                }
            }
            attributeSet.creator = "CocoaHeadsNL"
            var keywords = ["CocoaHeadsNL"]
            if let locationName = locationName {
               keywords.append(locationName)
            }
            
            if let location = location {
                keywords.append(location)
            }

            attributeSet.keywords = keywords
            attributeSet.thumbnailData = UIImagePNGRepresentation(smallLogoImage)

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
                    let item = CSSearchableItem(uniqueIdentifier: "meetup:\(meetup.recordName)", domainIdentifier: "meetup", attributeSet: meetup.searchableAttributeSet)
                    searchableItems.append(item)
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
