//
//  Entry+CoreDataProperties.swift
//  Hike
//
//  Created by TJ Barber on 8/21/17.
//  Copyright © 2017 Novel. All rights reserved.
//

import Foundation
import CoreData


extension Entry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entry> {
        return NSFetchRequest<Entry>(entityName: "Entry")
    }

    @NSManaged public var name: String?
    @NSManaged public var text: String?
    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double
    @NSManaged public var location: String?
    @NSManaged public var createdAt: NSDate?
    @NSManaged public var updatedAt: NSDate?

}
