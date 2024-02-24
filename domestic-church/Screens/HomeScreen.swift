//
//  HomeScreen.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-08-25.
//

import SwiftData
import SwiftUI
import SystemColors

import EventKit

struct LiturgicalDayView: View {
	@EnvironmentObject var romcal: Romcal
	@Environment(\.scenePhase) var scenePhase

	var today: Romcal.LiturgicalDate? { romcal.today }

	var body: some View {
		if let today = romcal.today {
			HStack {
				MarqueeText(today.name.isEmpty ? "Week \(today.calendar.weekOfSeason) of \(today.seasonNames.first ?? "")" : today.name)
					.lineLimit(1)
					.fontWeight(.semibold)
					.font(.caption)
					.fontDesign(.rounded)
					.textCase(.uppercase)

				//				Image(systemName: "chevron.forward")
				//					.font(.system(size: 14))
				//					.foregroundStyle(romcal.color(from: today.colors.first))

				//				Spacer()
			}
			.frame(minWidth: 100, maxWidth: .infinity)
			.padding(.all, 16)
			.foregroundStyle(romcal.color(from: today.colors.first))
			.background(romcal.color(from: today.colors.first).opacity(0.1))
			.clipShape(RoundedRectangle(cornerRadius: 50))
		}
	}
}

struct HomeScreen: View {
	@Binding var router: Router

	@Environment(\.scenePhase) private var scenePhase

	@State private var reload = 0
	@Environment(\.managedObjectContext) private var viewContext

	@FetchRequest(
		sortDescriptors: [NSSortDescriptor(keyPath: \Gameplan.createdAt, ascending: true)],
		animation: .default) private var gameplans: FetchedResults<Gameplan>

	private var activityFeed: (today: [Activity], future: [Activity]) {
		let activities = gameplans.compactMap(\.nextOccurrence).sorted(by: { $0.date < $1.date })
		let today = activities.filter(\.date.isInToday)
		let future = activities.subtracting(today)

		return (today, future)
	}

	var body: some View {
		NavigationStack(path: $router.homePath) {
			ScrollView {
				VStack(alignment: .leading) {
					LiturgicalDayView().padding()

					if !activityFeed.today.isEmpty {
						GroupBox(label: Text("Today"), content: {
							VStack(spacing: 12) {
								ForEach(activityFeed.today) { activity in
									ActivityCard(activity: activity)
								}
							}
						}).groupBoxStyle(SecondaryGroupBoxStyle())
					}

					if !activityFeed.future.isEmpty {
						GroupBox(label: Text("Next"), content: {
							VStack(spacing: 12) {
								ForEach(activityFeed.future) { activity in
									ActivityCard(activity: activity)
								}
							}
						}).groupBoxStyle(SecondaryGroupBoxStyle())
					}
				}
				.frame(minWidth: 0, maxWidth: .infinity)
				.navigationTitle("Home")
			}
			.frame(minWidth: 0, maxWidth: .infinity)
			.onChange(of: scenePhase, initial: false) { _, phase in
				if phase == .active {
					reload += 1
				}
			}
			.background(Color.systemGroupedBackground)
			.navigationDestination(for: Activity.self) { activity in
				ActivityView(activity: activity)
			}
		}
	}
}

// #Preview {
//	let config = ModelConfiguration(isStoredInMemoryOnly: true)
//	let container = try! ModelContainer(for: Gameplan.self, configurations: config)
//
//	let weekdays: [EKWeekday] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
//
//	[
//		Gameplan(activityType: .personalPrayer),
//		Gameplan(activityType: .personalPrayer),
//		Gameplan(activityType: .scripture),
//		Gameplan(activityType: .conjugalPrayer),
//		Gameplan(activityType: .familyPrayer),
//	].forEach {
//		$0.timeOfDay = Date().addingTimeInterval(TimeInterval.random(in: 0...86400))
//		$0.source = PrayerFormSettings().sources.randomElement()!
//		$0.frequency = Bool.random() ? .daily : .weekly
//		$0.byDayOfWeek = weekdays.randomElement()!
//
//		if $0.activityType == .scripture {
//			$0.source = .dailyGospel
//		}
//
//		container.mainContext.insert($0)
//	}
//
//	return HomeScreen(router: .constant(Router.shared))
//		.modelContainer(container)
//		.environmentObject(Romcal.preview)
// }
