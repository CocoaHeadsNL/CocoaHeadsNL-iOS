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

class Company {

    init(record: CKRecord) {
        self.recordID = record.recordID as CKRecordID?
        self.name = record["name"] as? String
        self.place = record["place"] as? String
        self.streetAddress = record["streetAddress"] as? String
        self.website = record["website"] as? String
        self.zipCode = record["zipCode"] as? String
        self.companyDescription = record["companyDescription"] as? String
        self.emailAddress = record["emailAddress"] as? String
        self.location = record["location"] as? CLLocation
        self.logo = record["logo"] as? CKAsset
        self.hasApps = record["hasApps"] as? Bool ?? false
        self.smallLogo = record["smallLogo"] as? CKAsset
    }

    let recordID: CKRecordID?
    let name: String?
    let place: String?
    let streetAddress: String?
    let website: String?
    let zipCode: String?
    let companyDescription: String?
    let emailAddress: String?
    let location: CLLocation?
    let logo: CKAsset?
    let hasApps: Bool
    let smallLogo: CKAsset?

    lazy var logoImage: UIImage = {
        if let logo = self.logo, data = NSData(contentsOfURL: logo.fileURL) {
            return UIImage(data:data)!
        } else {
            return UIImage(named: "CocoaHeadsNLLogo")!
        }
    }()

    lazy var smallLogoImage: UIImage = {
        if let logo = self.smallLogo, data = NSData(contentsOfURL: logo.fileURL) {
            return UIImage(data:data)!
        } else {
            return UIImage(named: "CocoaHeadsNLLogo")!
        }
    }()
}

class Contributor {

    let recordID: CKRecordID
    let avatar_url: String
    let contributor_id: Int64
    let name: String
    let url: String

    init(record: CKRecord) {
        self.recordID = record.recordID
        self.name = record["name"] as? String ?? ""
        self.url = record["url"] as? String ?? ""
        self.avatar_url = record["avatar_url"] as? String ?? ""
        self.contributor_id = record["contributor_id"] as? Int64 ?? 0
    }
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

class Meetup {

    init(record: CKRecord) {
        self.recordID = record.recordID
        self.name = record["name"] as? String ?? ""
        self.meetup_id = record["meetup_id"] as? String
        self.meetup_description = record["meetup_description"] as? String ?? ""
        self.geoLocation = record["geoLocation"] as? CLLocation
        self.location = record["location"] as? String ?? ""
        self.locationName = record["locationName"] as? String ?? ""
        self.logo = record["logo"] as? CKAsset
        self.smallLogo = record["smallLogo"] as? CKAsset
        self.time = record["time"] as? NSDate
        self.nextEvent = record["nextEvent"] as? DarwinBoolean

        self.duration = record.objectForKey("duration") as? NSNumber
        self.rsvp_limit = record.objectForKey("rsvp_limit") as? NSNumber
        self.yes_rsvp_count = record.objectForKey("yes_rsvp_count") as? NSNumber
        self.meetupUrl = record.objectForKey("meetup_url") as? String
    }

    let recordID: CKRecordID
    let duration: NSNumber!
    let geoLocation: CLLocation?
    let locationName: String
    let meetup_description: String
    let meetup_id: String?
    let name: String
    let rsvp_limit: NSNumber!
    let time: NSDate?
    let yes_rsvp_count: NSNumber!
    let logo: CKAsset?
    let nextEvent: DarwinBoolean?
    let smallLogo: CKAsset?
    let location: String
    let meetupUrl: String?

    lazy var logoImage: UIImage = {
        let logoImage: UIImage
        if let logo = self.logo, data = NSData(contentsOfURL: logo.fileURL) {
            return UIImage(data:data)!
        } else {
            return UIImage(named: "CocoaHeadsNLLogo")!
        }
    }()

    lazy var smallLogoImage: UIImage = {
        let logoImage: UIImage
        if let logo = self.smallLogo, data = NSData(contentsOfURL: logo.fileURL) {
            return UIImage(data:data)!
        } else {
            return UIImage(named: "CocoaHeadsNLLogo")!
        }
    }()

    @available(iOS 9.0, *)
    var searchableAttributeSet: CSSearchableItemAttributeSet {
        get {
            let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeImage as String)
            attributeSet.title = name
            if let data = meetup_description.dataUsingEncoding(NSUTF8StringEncoding) {
                do {
                    let meetupDescriptionString = try NSAttributedString(data: data, options:[NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding], documentAttributes:nil)

                    attributeSet.contentDescription = meetupDescriptionString.string
                } catch {
                    print("Stuff went crazy!")
                }
            }
            attributeSet.creator = "CocoaHeadsNL"
            let keywords = ["CocoaHeadsNL", locationName, location]

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
                    let item = CSSearchableItem(uniqueIdentifier: "meetup:\(meetup.recordID)", domainIdentifier: "meetup", attributeSet: meetup.searchableAttributeSet)
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
