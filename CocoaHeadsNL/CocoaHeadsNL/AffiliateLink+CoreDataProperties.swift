//
//  AffiliateLink+CoreDataProperties.swift
//  CocoaHeadsNL
//
//  Created by Jeroen Leenarts on 20-02-18.
//  Copyright © 2018 Stichting CocoaheadsNL. All rights reserved.
//
//

import Foundation
import CoreData


extension AffiliateLink {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AffiliateLink> {
        return NSFetchRequest<AffiliateLink>(entityName: "AffiliateLink")
    }

    @NSManaged public var recordID: NSObject?
    @NSManaged public var affiliateId: String?
    @NSManaged public var productCreator: String?
    @NSManaged public var productName: String?
    @NSManaged public var company: Company?

}
