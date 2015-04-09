//
//  ModelObjects.swift
//  CocoaHeadsNL
//
//  Created by Jeroen Leenarts on 27-03-15.
//  Copyright (c) 2015 Stichting CocoaheadsNL. All rights reserved.
//

class AffiliateLink : PFObject, PFSubclassing {
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }

    class func parseClassName() -> String {
        return "affiliateLinks"
    }

    @NSManaged var affiliateId: String?
    @NSManaged var productCreator: String?
    @NSManaged var productName: String?
}

class APIKey : PFObject, PFSubclassing {
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
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
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
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
    @NSManaged var companyDiscription: String?
    @NSManaged var emailAddress: String?
    @NSManaged var location: PFGeoPoint?
    @NSManaged var logo: PFFile?
}

class Job : PFObject, PFSubclassing {
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
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
}

class Meetup : PFObject, PFSubclassing {
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }

    class func parseClassName() -> String {
        return "Meetup"
    }

    @NSManaged var content: String?
    @NSManaged var geoLocation: PFGeoPoint?
    @NSManaged var locationName: String?
    @NSManaged var meetup_description: String?
    @NSManaged var meetup_id: String?
    @NSManaged var name: String?
    @NSManaged var rsvp_limit: Int
    @NSManaged var time: NSDate?
    @NSManaged var yes_rsvp_count: Int
    @NSManaged var logo: PFFile?
    @NSManaged var nextEvent: Boolean

}
