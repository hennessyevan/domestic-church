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
	@State var selection = "home"
	@StateObject var romcal = Romcal()

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
			.environmentObject(romcal)
			.modelContainer(for: [Gameplan.self])
		}
	}
}
