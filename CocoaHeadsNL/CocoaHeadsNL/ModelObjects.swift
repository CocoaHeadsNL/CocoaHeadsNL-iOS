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

let indexQueue = OperationQueue()

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
            newCompany.logo = try? Data(contentsOf: logoAsset.fileURL)
        }
        if let logoAsset = record["smallLogo"] as? CKAsset {
            newCompany.smallLogo = try? Data(contentsOf: logoAsset.fileURL)
        }

        return newCompany
    }
    
    override static func primaryKey() -> String? {
        return "recordName"
    }

    @objc dynamic var recordName: String?
    @objc dynamic var name: String?
    @objc dynamic var place: String?
    @objc dynamic var streetAddress: String?
    @objc dynamic var website: String?
    @objc dynamic var zipCode: String?
    @objc dynamic var companyDescription: String?
    @objc dynamic var emailAddress: String?
    @objc dynamic var latitude: CLLocationDegrees = 0.0
    @objc dynamic var longitude: CLLocationDegrees = 0.0
    @objc dynamic var logo: Data?
    @objc dynamic var hasApps: Bool = false
    @objc dynamic var smallLogo: Data?
    
    override static func ignoredProperties() -> [String] {
        return ["logoImage", "smallLogoImage"]
    }

    lazy var logoImage: UIImage = {
        if let logo = self.logo, let image = UIImage(data:logo) {
            return image
        } else {
            return UIImage(named: "CocoaHeadsNLLogo")!
        }
    }()

    lazy var smallLogoImage: UIImage = {
        if let logo = self.smallLogo, let image = UIImage(data:logo) {
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

    @objc dynamic var recordName: String?
    @objc dynamic var avatar_url: String?
    @objc dynamic var contributor_id: Int64 = 0
    @objc dynamic var commit_count: Int = 0
    @objc dynamic var name: String?
    @objc dynamic var url: String?
}

class Job: Object {
    static func job(forRecord record: CKRecord) -> Job {
        let job = Job()
        
        job.recordName = record.recordID.recordName
        job.content = record["content"] as? String ?? ""
        job.date = record["date"] as? Date ?? Date()
        job.link = record["link"] as? String ?? ""
        job.title = record["title"] as? String ?? ""
        job.logoUrlString = record["logoUrl"] as? String
        
        if let logoURLString = job.logoUrlString, let logoURL = URL(string: logoURLString), let data = try? Data(contentsOf: logoURL) {
            job.logo = data
        }

        if let companyName = record["author"] as? String, companyName.count > 0 {
            job.companyName = companyName
        } else {
            job.companyName = nil
        }
        return job
    }

    override static func primaryKey() -> String? {
        return "recordName"
    }
    
    @objc dynamic var recordName: String?
    @objc dynamic var content: String = ""
    @objc dynamic var date: Date?
    @objc dynamic var link: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var logoUrlString: String?
    @objc dynamic var logo: Data?
    @objc dynamic var companyName: String?

    override static func ignoredProperties() -> [String] {
        return ["logoImage"]
    }
    
    lazy var logoImage: UIImage = {
        if let logo = self.logo, let image = UIImage(data:logo) {
            return image
        } else {
            return UIImage(named: "CocoaHeadsNLLogo")!
        }
    }()

    var searchableAttributeSet: CSSearchableItemAttributeSet {
        get {
            let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeImage as String)
            attributeSet.title = title
            if let data = content.data(using: String.Encoding.utf8) {
                do {
                    let jobDescriptionString = try NSAttributedString(data: data, options:[NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html, NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8], documentAttributes:nil)

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

    class func index(_ jobs: [Job]) {
        if #available(iOS 9.0, *) {
            indexQueue.addOperation({ () -> Void in

                guard jobsIndexBackgroundTaskID == UIBackgroundTaskInvalid else {
                    return
                }

                jobsIndexBackgroundTaskID = UIApplication.shared.beginBackgroundTask(expirationHandler: { () -> Void in
                    UIApplication.shared.endBackgroundTask(jobsIndexBackgroundTaskID)
                    jobsIndexBackgroundTaskID = UIBackgroundTaskInvalid
                })

                var searchableItems = [CSSearchableItem]()
                for job in jobs {
                    let item = CSSearchableItem(uniqueIdentifier: "job:\(String(describing: job.recordName))", domainIdentifier: "job", attributeSet: job.searchableAttributeSet)
                    searchableItems.append(item)
                }

//                CSSearchableIndex.defaultSearchableIndex().deleteSearchableItemsWithDomainIdentifiers(["job"], completionHandler: { (error: NSError?) -> Void in
//                    if let error = error {
//                        print(error)
//                    }
//                })

                CSSearchableIndex.default().indexSearchableItems(searchableItems, completionHandler: { (error: Swift.Error?) -> Void in
                    if let error = error {
                        print(error)
                    }
                })

                UIApplication.shared.endBackgroundTask(jobsIndexBackgroundTaskID)
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
        meetup.latitude = (record["geoLocation"] as? CLLocation)?.coordinate.latitude ?? 0.0
        meetup.longitude = (record["geoLocation"] as? CLLocation)?.coordinate.longitude ?? 0.0
        meetup.location = record["location"] as? String ?? ""
        meetup.locationName = record["locationName"] as? String ?? ""
        meetup.time = record["time"] as? Date
        meetup.nextEvent = record["nextEvent"] as? Bool ?? false

        meetup.duration = record.object(forKey: "duration") as? NSNumber ?? 0
        meetup.rsvp_limit = record.object(forKey: "rsvp_limit") as? NSNumber ?? 0
        meetup.yes_rsvp_count = record.object(forKey: "yes_rsvp_count") as? NSNumber ?? 0
        meetup.meetupUrl = record.object(forKey: "meetup_url") as? String
        
        if let logoAsset = record["logo"] as? CKAsset {
            meetup.logo = try? Data(contentsOf: logoAsset.fileURL)
        }
        if let logoAsset = record["smallLogo"] as? CKAsset {
            meetup.smallLogo = try? Data(contentsOf: logoAsset.fileURL)
        }
        
        return meetup
    }

    override static func primaryKey() -> String? {
        return "recordName"
    }

    @objc dynamic var recordName: String?
    @objc dynamic var duration: NSNumber = 0
    @objc dynamic var latitude: CLLocationDegrees = 0.0
    @objc dynamic var longitude: CLLocationDegrees = 0.0
    @objc dynamic var locationName: String?
    @objc dynamic var meetup_description: String?
    @objc dynamic var meetup_id: String?
    @objc dynamic var name: String?
    @objc dynamic var rsvp_limit: NSNumber = 0
    @objc dynamic var time: Date?
    @objc dynamic var yes_rsvp_count: NSNumber = 0
    @objc dynamic var logo: Data?
    @objc dynamic var nextEvent: Bool = false
    @objc dynamic var smallLogo: Data?
    @objc dynamic var location: String?
    @objc dynamic var meetupUrl: String?
    
    override static func ignoredProperties() -> [String] {
        return ["logoImage", "smallLogoImage", "searchableAttributeSet"]
    }

    lazy var logoImage: UIImage = {
        if let logo = self.logo, let image = UIImage(data:logo) {
            return image
        } else {
            return UIImage(named: "CocoaHeadsNLLogo")!
        }
    }()
    
    lazy var smallLogoImage: UIImage = {
        if let logo = self.smallLogo, let image = UIImage(data:logo) {
            return image
        } else {
            return UIImage(named: "CocoaHeadsNLLogo")!
        }
    }()

    var isToday: Bool {
        guard let time = time else { return false }

        let today = dateOnlyFormatter.string(from: Date())
        return dateOnlyFormatter.string(from: time) == today
    }

    var isUpcoming: Bool {
        guard let time = time else { return false }

        return time.timeIntervalSinceNow > 0
    }

    @available(iOS 9.0, *)
    var searchableAttributeSet: CSSearchableItemAttributeSet {
        get {
            let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeImage as String)
            attributeSet.title = name
            if let data = meetup_description?.data(using: String.Encoding.utf8) {
                do {
                    let meetupDescriptionString = try NSAttributedString(data: data, options:[NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html, NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8], documentAttributes:nil)

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

    class func index(_ meetups: [Meetup]) {
        if #available(iOS 9.0, *) {
            indexQueue.addOperation({ () -> Void in

                guard meetupsIndexBackgroundTaskID == UIBackgroundTaskInvalid else {
                    return
                }

                meetupsIndexBackgroundTaskID = UIApplication.shared.beginBackgroundTask(expirationHandler: { () -> Void in
                    UIApplication.shared.endBackgroundTask(jobsIndexBackgroundTaskID)
                    meetupsIndexBackgroundTaskID = UIBackgroundTaskInvalid
                })

                var searchableItems = [CSSearchableItem]()
                for meetup in meetups {
                    let item = CSSearchableItem(uniqueIdentifier: "meetup:\(String(describing: meetup.recordName))", domainIdentifier: "meetup", attributeSet: meetup.searchableAttributeSet)
                    searchableItems.append(item)
                }

//                CSSearchableIndex.defaultSearchableIndex().deleteSearchableItemsWithDomainIdentifiers(["meetup"], completionHandler: { (error: NSError?) -> Void in
//                    if let error = error {
//                        print(error)
//                    }
//                })

                CSSearchableIndex.default().indexSearchableItems(searchableItems, completionHandler: { (error: Swift.Error?) -> Void in
                    if let error = error {
                        print(error)
                    }
                })

                UIApplication.shared.endBackgroundTask(jobsIndexBackgroundTaskID)
                meetupsIndexBackgroundTaskID = UIBackgroundTaskInvalid
            })
        }
    }
}

private let dateOnlyFormatter: DateFormatter = {
    let amsterdam = TimeZone(identifier: "Europe/Amsterdam")!
    let nl_NL = Locale(identifier: "nl-NL")

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.locale = nl_NL
    dateFormatter.timeZone = amsterdam

    return dateFormatter
}()
