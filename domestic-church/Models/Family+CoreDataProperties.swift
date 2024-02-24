//
//  Family+CoreDataProperties.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2024-02-24.
//
//

import Foundation
import CoreData


extension Family {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Family> {
        return NSFetchRequest<Family>(entityName: "Family")
    }

    @NSManaged public var gameplans: NSSet?

}

// MARK: Generated accessors for gameplans
extension Family {

    @objc(addGameplansObject:)
    @NSManaged public func addToGameplans(_ value: Gameplan)

    @objc(removeGameplansObject:)
    @NSManaged public func removeFromGameplans(_ value: Gameplan)

    @objc(addGameplans:)
    @NSManaged public func addToGameplans(_ values: NSSet)

    @objc(removeGameplans:)
    @NSManaged public func removeFromGameplans(_ values: NSSet)

}

extension Family : Identifiable {

}
