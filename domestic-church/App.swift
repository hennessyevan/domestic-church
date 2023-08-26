//
//  domestic_churchApp.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-08-25.
//

import SwiftUI

@main
struct domestic_churchApp: App {
	let persistenceController = PersistenceController.shared

	@State var selection = "home"

	var body: some Scene {
		WindowGroup {
			TabView(selection: $selection) {
				HomeScreen()
					.tabItem {
						Label("Home", systemImage: "house.fill")
					}.tag("home")

				HStack {}.tabItem {
					Label("Check In", systemImage: "person.badge.shield.checkmark.fill")
				}.tag("checkin")

				GameplanView()
					.tabItem {
						Label("Gameplan", systemImage: "list.bullet.rectangle.portrait.fill")
					}.tag("gameplan")
			}
			.environment(\.managedObjectContext, persistenceController.container.viewContext)
		}
	}
}
