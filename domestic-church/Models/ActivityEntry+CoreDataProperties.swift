//
//  ActivityEntry+CoreDataProperties.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2024-02-24.
//
//

import Foundation
import CoreData


extension ActivityEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ActivityEntry> {
        return NSFetchRequest<ActivityEntry>(entityName: "ActivityEntry")
    }

    @NSManaged public var gameplan: Gameplan?

}

extension ActivityEntry : Identifiable {

}
