//
//  Trail+CoreDataProperties.swift
//  MyLocations
//
//  Created by Toni Itkonen on 14.10.2021.
//
//

import Foundation
import CoreData
import CoreLocation

extension Trail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Trail> {
        return NSFetchRequest<Trail>(entityName: "Trail")
    }

    @NSManaged public var paiva: Date?
    @NSManaged public var time: Double
    @NSManaged public var distance: Double
    @NSManaged public var photoIDtrail: NSNumber? /// For photo
    @NSManaged public var sportsType: String? /// In location this is not optional ?
    @NSManaged public var trailDescription: String? /// In location this is not optional ?

}

extension Trail : Identifiable {

}
