//
//  Company+CoreDataProperties.swift
//  CocoaHeadsNL
//
//  Created by Jeroen Leenarts on 20-02-18.
//  Copyright © 2018 Stichting CocoaheadsNL. All rights reserved.
//
//

import Foundation
import CoreData

extension Company {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Company> {
        return NSFetchRequest<Company>(entityName: "Company")
    }

    @NSManaged public var recordID: NSObject?
    @NSManaged public var recordName: String?
    @NSManaged public var name: String?
    @NSManaged public var place: String?
    @NSManaged public var website: String?
    @NSManaged public var streetAddress: String?
    @NSManaged public var zipCode: String?
    @NSManaged public var companyDescription: String?
    @NSManaged public var emailAddress: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var logo: NSData?
    @NSManaged public var smallLogo: NSData?
    @NSManaged public var affiliateLinks: Set<AffiliateLink>?

}
