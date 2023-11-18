//
//  GameplanForm.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-08-25.
//

import EventKit
import Observation
import RWMRecurrenceRule
import SwiftData
import SwiftUI

protocol FormSettings {
	var sources: [Source] { get }
}

struct DefaultFormSettings: FormSettings {
	var sources: [Source] = []
}

struct ScriptureFormSettings: FormSettings {
	var sources: [Source] = [.dailyGospel, .bibleInAYear]
}

struct PersonalPrayerFormSettings: FormSettings {
	var sources: [Source] = [.custom]
}

var formSettingsForActivityType: [ActivityType: FormSettings] = [
	.scripture: ScriptureFormSettings(),
	.personalPrayer: PersonalPrayerFormSettings(),
]

private let SPACING: CGFloat = 8

struct GameplanForm: View {
	@Environment(\.modelContext) private var modelContext
	@Bindable var gameplan: Gameplan

	@State private var showCustomSourceEditor = false

	var settings: any FormSettings

	init(gameplan: Gameplan) {
		self.gameplan = gameplan
		self.settings = formSettingsForActivityType[gameplan.activityType] ?? DefaultFormSettings()
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 30) {
			VStack(alignment: .leading, spacing: SPACING) {
				Label("Frequency", systemImage: "clock.arrow.circlepath").labelStyle(.titleOnly).fontWeight(.medium)
				Picker("Frequency", selection: $gameplan.frequency) {
					ForEach([EKRecurrenceFrequency.daily,
					         EKRecurrenceFrequency.weekly,
					         EKRecurrenceFrequency.monthly], id: \.self)
					{ frequency in
						Text(recurrenceFrequencyToString(frequency).capitalized).tag(frequency)
					}
				}.pickerStyle(.segmented)
			}

			if gameplan.frequency == .weekly {
				VStack(alignment: .leading, spacing: SPACING) {
					Label("Day of Week", systemImage: "calendar").labelStyle(.titleOnly).fontWeight(.medium)
					Picker("Day of Week", selection: $gameplan.byDayOfWeek) {
						ForEach([
							EKWeekday.sunday,
							EKWeekday.monday,
							EKWeekday.tuesday,
							EKWeekday.wednesday,
							EKWeekday.thursday,
							EKWeekday.friday,
							EKWeekday.saturday,
						], id: \.self) { weekday in
							Text(weekdayToString(weekday).prefix(2).uppercased()).tag(weekday)
						}

					}.pickerStyle(.segmented)
				}
			}

			DatePicker("Time of Day", selection: $gameplan.timeOfDay, displayedComponents: .hourAndMinute)

			if !settings.sources.isEmpty {
				VStack(alignment: .leading, spacing: SPACING) {
					Label("Source", systemImage: "clock.arrow.circlepath").labelStyle(.titleOnly).fontWeight(.medium)

					HStack {
						Picker("Source", selection: $gameplan.source) {
							ForEach(settings.sources) { source in
								Text(source.rawValue.localized).tag(source)
							}
						}

						if gameplan.source == .custom {
							Spacer()
							Button(action: { showCustomSourceEditor = true }) {
								Label(
									title: { Text("Edit".uppercased()) },
									icon: { Image(systemName: "chevron.right") }
								).labelStyle(TrailingIconLabelStyle())
							}
							.buttonStyle(BorderedButtonStyle())
							.font(.caption)
						}
					}
				}
			}
		}
		.animation(.easeOut, value: gameplan.frequency)
		.sheet(isPresented: $showCustomSourceEditor, content: {
			NavigationView {
				Form {
					TextField("Title", text: $gameplan.customSourceTitle)

					ZStack(alignment: .topLeading) {
						TextEditor(text: $gameplan.customSourceText)
							.frame(minHeight: 100)

						if gameplan.customSourceText.isEmpty {
							Text("Enter some text")
								.foregroundColor(Color(.placeholderText))
								.padding(.horizontal, 4)
								.padding(.vertical, 8)
						}
					}
					.navigationBarTitleDisplayMode(.inline)
					.navigationTitle("Custom \(gameplan.activityType.rawValue.localized)")
				}
				.toolbar {
					ToolbarItem(placement: .confirmationAction) {
						Button(action: { showCustomSourceEditor = false }) {
							Label("Done", systemImage: "checkmark")
								.labelStyle(TitleOnlyLabelStyle())
						}
					}
				}
			}
		})
		.tint(TYPE_COLORS[gameplan.activityType])
	}
}

#Preview {
	let config = ModelConfiguration(isStoredInMemoryOnly: true)
	let container = try! ModelContainer(for: Gameplan.self, configurations: config)

	let gameplan = Gameplan(activityType: .personalPrayer, source: .custom)
	container.mainContext.insert(gameplan)

	return GameplanForm(gameplan: gameplan)
}
