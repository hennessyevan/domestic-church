//
//  HomeScreen.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-08-25.
//

import SwiftData
import SwiftUI
import SystemColors

struct LiturgicalDayView: View {
	@EnvironmentObject var romcal: Romcal

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
			.padding(.all)
			.foregroundStyle(romcal.color(from: today.colors.first))
			.background(romcal.color(from: today.colors.first).opacity(0.1))
			.clipShape(RoundedRectangle(cornerRadius: 50))
		}
	}
}

struct HomeScreen: View {
	@Environment(\.modelContext) private var modelContext

	@Query(sort: \Gameplan.createdAt, order: .forward, animation: .default) private var gameplans: [Gameplan]
	@State private var forceRefresh = 0

	private var activities: (today: [Activity], future: [Activity]) {
		let activities = gameplans.compactMap(\.nextOccurrence)
		let today = activities.filter { ($0.date.isInToday && $0.date.isInTheFuture) || ($0.date.isInToday && $0.date.isWithin(2, .hour, of: .now)) }.sorted(by: { $0.date < $1.date })
		let future = activities.subtracting(today)

		return (today, future)
	}

	var body: some View {
		NavigationView {
			ScrollView {
				VStack(alignment: .leading) {
					LiturgicalDayView().padding()

					if !activities.today.isEmpty {
						GroupBox(label: Text("Today"), content: {
							VStack(spacing: 12) {
								ForEach(activities.today) { activity in
									ActivityCard(activity: activity)
								}
							}
						}).groupBoxStyle(SecondaryGroupBoxStyle())
					}

					if !activities.future.isEmpty {
						GroupBox(label: Text("Next"), content: {
							VStack(spacing: 12) {
								ForEach(activities.future) { activity in
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
#if os(iOS)
				.background(Color.systemGroupedBackground)
#endif
				.onAppear {
					Timer.scheduledTimer(withTimeInterval: 60*60*12, repeats: true) { _ in
						forceRefresh = Date.now.hashValue
					}
				}
		}
	}
}

#Preview {
	let config = ModelConfiguration(isStoredInMemoryOnly: true)
	let container = try! ModelContainer(for: Gameplan.self, configurations: config)

	let gameplan = Gameplan(activityType: .personalPrayer)
	gameplan.customSourceText = "Test source text"
	gameplan.customSourceTitle = "Magnificat"
	gameplan.frequency = .daily
	gameplan.byDayOfWeek = .wednesday
	container.mainContext.insert(gameplan)

	return HomeScreen()
		.modelContainer(container)
		.environmentObject(Romcal.preview)
}
