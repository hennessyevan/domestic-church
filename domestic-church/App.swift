//
//  domestic_churchApp.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-08-25.
//

import Combine
import SwiftData
import SwiftUI

@main
struct domestic_churchApp: App {
	let persistenceController = PersistenceController.shared

	@StateObject var romcal = Romcal()

//	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

	@State var router = Router.shared
	@State private var activeTab: Tab = .home

	var body: some Scene {
		WindowGroup {
			TabView(selection: $activeTab.onUpdate {
				router.tabClicked(activeTab)
			}) {
				HomeScreen(router: $router)
					.tabItem { Label("Home", systemImage: "house.fill") }
					.tag(Tab.home)

				JsonFormView(json: testjson).tabItem {
					Label("Check In", systemImage: "person.badge.shield.checkmark.fill")
				}.tag(Tab.checkin)

				GameplanView(router: $router)
					.tabItem { Label("Gameplan", systemImage: "list.bullet.rectangle.portrait.fill") }
					.tag(Tab.gameplan)
			}
			.onChange(of: router.tab) { _, newTab in
				activeTab = newTab
			}
			.environmentObject(romcal)
			.environment(\.managedObjectContext, persistenceController.container.viewContext)
		}
	}
}

// class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
//	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//		print("Notification tapped for activityID: \(response.notification.request.identifier)")
//
//		// fetch gameplan by id from CoreData
//		let container = try! ModelContainer(for: Gameplan.self)
//		let context = container.mainContext
//
//		var fetchDescriptor = FetchDescriptor<Gameplan>()
//		fetchDescriptor.fetchLimit = 1
//		let gameplans = try! context.fetch(fetchDescriptor)
//		let gameplan = gameplans.first
//
//		if let activity = gameplan?.nextOccurrence {
//			Router.shared.goToActivity(activity)
//		}
//
//		completionHandler()
//	}
//
//	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//		UNUserNotificationCenter.current().delegate = self
//		// Your other setup code
//		return true
//	}
// }
