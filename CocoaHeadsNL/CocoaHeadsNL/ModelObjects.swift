//
//  ModelObjects.swift
//  CocoaHeadsNL
//
//  Created by Jeroen Leenarts on 27-03-15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

import CoreSpotlight
import MobileCoreServices

let indexQueue = NSOperationQueue()

class AffiliateLink : PFObject, PFSubclassing {
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }

    class func parseClassName() -> String {
        return "affiliateLinks"
    }

    @NSManaged var affiliateId: String?
    @NSManaged var productCreator: String?
    @NSManaged var productName: String?
    @NSManaged var company: Company?
}

class APIKey : PFObject, PFSubclassing {
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }

    class func parseClassName() -> String {
        return "APIKey"
    }

    @NSManaged var apiKeyString: String?
    @NSManaged var serviceName: String?
}

class Company : PFObject, PFSubclassing {
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }

    class func parseClassName() -> String {
        return "Companies"
    }

    @NSManaged var name: String?
    @NSManaged var place: String?
    @NSManaged var streetAddress: String?
    @NSManaged var website: String?
    @NSManaged var zipCode: String?
    @NSManaged var companyDescription: String?
    @NSManaged var emailAddress: String?
    @NSManaged var location: PFGeoPoint?
    @NSManaged var logo: PFFile?
    @NSManaged var hasApps: Bool
    @NSManaged var smallLogo: PFFile?
}

class Contributor : PFObject, PFSubclassing {
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    class func parseClassName() -> String {
        return "Contributor"
    }
    
    @NSManaged var avatar_url: String?
    @NSManaged var contributor_id: Int
    @NSManaged var name: String?
    @NSManaged var url: String?
}

class Job : PFObject, PFSubclassing {
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }

    class func parseClassName() -> String {
        return "Job"
    }

    @NSManaged var content: String?
    @NSManaged var date: String?
    @NSManaged var link: String?
    @NSManaged var title: String?
    @NSManaged var logo: PFFile?
    
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
                guard let imageData = try logo?.getData() else {
                    return attributeSet
                }
                
                if let smallLogoImage = UIImage(data:imageData)
                {
                    attributeSet.thumbnailData = UIImagePNGRepresentation(smallLogoImage);
                }
            } catch {
                
            }
            return attributeSet
        }
    }
    
    class func index(jobs: [Job]) {
        if #available(iOS 9.0, *) {
            indexQueue.addOperationWithBlock({ () -> Void in
                var searchableItems = [CSSearchableItem]()
                for job in jobs {
                    let item = CSSearchableItem(uniqueIdentifier: "job:\(job.objectId)", domainIdentifier: "job", attributeSet: job.searchableAttributeSet)
                    searchableItems.append(item)
                }
                
                CSSearchableIndex.defaultSearchableIndex().deleteSearchableItemsWithDomainIdentifiers(["job"], completionHandler: { (error: NSError?) -> Void in
                    if let error = error {
                        print(error)
                    }
                })

                
                CSSearchableIndex.defaultSearchableIndex().indexSearchableItems(searchableItems, completionHandler: { (error: NSError?) -> Void in
                    if let error = error {
                        print(error)
                    }
                })
            })
        }
    }
}

class Meetup : PFObject, PFSubclassing {
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }

    class func parseClassName() -> String {
        return "Meetup"
    }

    @NSManaged var duration: Int
    @NSManaged var geoLocation: PFGeoPoint?
    @NSManaged var locationName: String?
    @NSManaged var meetup_description: String?
    @NSManaged var meetup_id: String?
    @NSManaged var name: String?
    @NSManaged var rsvp_limit: Int
    @NSManaged var time: NSDate?
    @NSManaged var yes_rsvp_count: Int
    @NSManaged var logo: PFFile?
    @NSManaged var nextEvent: DarwinBoolean
    @NSManaged var smallLogo: PFFile?
    @NSManaged var location: String?
    
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
                guard let imageData = try smallLogo?.getData() else {
                    return attributeSet
                }

                if let smallLogoImage = UIImage(data:imageData)
                {
                    attributeSet.thumbnailData = UIImagePNGRepresentation(smallLogoImage);
                }
            } catch {
                
            }
            return attributeSet
        }
    }

    class func index(meetups: [Meetup]) {
        if #available(iOS 9.0, *) {
            indexQueue.addOperationWithBlock({ () -> Void in
                var searchableItems = [CSSearchableItem]()
                for meetup in meetups {
                    let item = CSSearchableItem(uniqueIdentifier: "meetup:\(meetup.objectId)", domainIdentifier: "meetup", attributeSet: meetup.searchableAttributeSet)
                    searchableItems.append(item)
                }
                
                CSSearchableIndex.defaultSearchableIndex().deleteSearchableItemsWithDomainIdentifiers(["meetup"], completionHandler: { (error: NSError?) -> Void in
                    if let error = error {
                        print(error)
                    }
                })
                
                CSSearchableIndex.defaultSearchableIndex().indexSearchableItems(searchableItems, completionHandler: { (error: NSError?) -> Void in
                    if let error = error {
                        print(error)
                    }
                })
            })
        }
    }
}
