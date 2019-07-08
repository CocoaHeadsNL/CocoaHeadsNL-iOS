//
//  Meetup+CoreDataProperties.swift
//  CocoaHeadsNL
//
//  Created by Jeroen Leenarts on 20-02-18.
//  Copyright © 2018 Stichting CocoaheadsNL. All rights reserved.
//
//

import Foundation
import CoreData

extension Meetup {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Meetup> {
        return NSFetchRequest<Meetup>(entityName: "Meetup")
    }

    @NSManaged public var recordID: NSObject?
    @NSManaged public var recordName: String?
    @NSManaged public var duration: Int32
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var locationName: String?
    @NSManaged public var meetupDescription: String?
    @NSManaged public var meetupId: String?
    @NSManaged public var name: String?
    @NSManaged public var rsvpLimit: Int32
    @NSManaged public var time: Date?
    @NSManaged public var yesRsvpCount: Int32
    @NSManaged public var logo: NSData?
    @NSManaged public var nextEvent: Bool
    @NSManaged public var smallLogo: NSData?
    @NSManaged public var location: String?
    @NSManaged public var meetupUrl: String?
    @NSManaged public var year: Int32

}
