//
//  Persistence.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-08-25.
//

import CoreData

struct PersistenceController {
	static let shared = PersistenceController()

	static var preview: PersistenceController = {
		let result = PersistenceController(inMemory: true)
		let viewContext = result.container.viewContext

		let newItem = Gameplan(context: viewContext)
		newItem.createdAt = Date()
		newItem.wrappedActivityType = .scripture
		newItem.rrule = "RRULE:FREQ=DAILY;INTERVAL=1;BYDAY=TU"

		do {
			try viewContext.save()
		} catch {
			// Replace this implementation with code to handle the error appropriately.
			// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			let nsError = error as NSError
			fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
		}
		return result
	}()

	let container: NSPersistentCloudKitContainer

	init(inMemory: Bool = false) {
		container = NSPersistentCloudKitContainer(name: "domestic_church")
		if inMemory {
			container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
		}
		container.loadPersistentStores(completionHandler: { _, error in
			if let error = error as NSError? {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

				/*
				 Typical reasons for an error here include:
				 * The parent directory does not exist, cannot be created, or disallows writing.
				 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
				 * The device is out of space.
				 * The store could not be migrated to the current model version.
				 Check the error message to determine what the actual problem was.
				 */
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		container.viewContext.automaticallyMergesChangesFromParent = true
	}
	
	static func fetchFirstGameplan(viewContext: NSManagedObjectContext) -> Gameplan? {
		let fetchRequest: NSFetchRequest<Gameplan> = Gameplan.fetchRequest()
		fetchRequest.fetchLimit = 1 // Limit the fetch to one object
		
		do {
			let gameplans = try viewContext.fetch(fetchRequest)
			return gameplans.first
		} catch {
			// Replace with proper error handling
			fatalError("Error fetching data for preview: \(error)")
		}
	}
}
