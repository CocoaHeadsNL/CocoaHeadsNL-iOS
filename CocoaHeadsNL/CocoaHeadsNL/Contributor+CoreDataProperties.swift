//
//  Contributor+CoreDataProperties.swift
//  CocoaHeadsNL
//
//  Created by Jeroen Leenarts on 20-02-18.
//  Copyright © 2018 Stichting CocoaheadsNL. All rights reserved.
//
//

import Foundation
import CoreData


extension Contributor {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contributor> {
        return NSFetchRequest<Contributor>(entityName: "Contributor")
    }

    @NSManaged public var recordID: NSObject?
    @NSManaged public var recordName: String?
    @NSManaged public var avatarUrl: String?
    @NSManaged public var contributorId: Int64
    @NSManaged public var commitCount: Int32
    @NSManaged public var name: String?
    @NSManaged public var url: String?

}
