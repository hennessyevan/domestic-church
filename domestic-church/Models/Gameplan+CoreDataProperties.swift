//
//  Gameplan+CoreDataProperties.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2024-02-24.
//
//

import Foundation
import CoreData


extension Gameplan {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Gameplan> {
        return NSFetchRequest<Gameplan>(entityName: "Gameplan")
    }

    @NSManaged public var activityTypeRawValue: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var customSourceTextRawValue: String?
    @NSManaged public var customSourceTitleRawValue: String?
    @NSManaged public var rrule: String?
    @NSManaged public var sourceRawValue: String?
    @NSManaged public var timeOfDayRawValue: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var uuidRawValue: UUID?
    @NSManaged public var activityEntries: NSSet?
    @NSManaged public var family: Family?

}

// MARK: Generated accessors for activityEntries
extension Gameplan {

    @objc(addActivityEntriesObject:)
    @NSManaged public func addToActivityEntries(_ value: ActivityEntry)

    @objc(removeActivityEntriesObject:)
    @NSManaged public func removeFromActivityEntries(_ value: ActivityEntry)

    @objc(addActivityEntries:)
    @NSManaged public func addToActivityEntries(_ values: NSSet)

    @objc(removeActivityEntries:)
    @NSManaged public func removeFromActivityEntries(_ values: NSSet)

}

extension Gameplan : Identifiable {

}
