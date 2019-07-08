//
//  Job+CoreDataProperties.swift
//  CocoaHeadsNL
//
//  Created by Jeroen Leenarts on 20-02-18.
//  Copyright © 2018 Stichting CocoaheadsNL. All rights reserved.
//
//

import Foundation
import CoreData

extension Job {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Job> {
        return NSFetchRequest<Job>(entityName: "Job")
    }

    @NSManaged public var recordID: NSObject?
    @NSManaged public var recordName: String?
    @NSManaged public var content: String?
    @NSManaged public var date: Date?
    @NSManaged public var link: String?
    @NSManaged public var title: String?
    @NSManaged public var logoUrlString: String?
    @NSManaged public var logo: NSData?
    @NSManaged public var companyName: String?

}
