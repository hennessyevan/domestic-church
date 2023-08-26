//
//  GameplanForm.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-08-25.
//

import Combine
import CoreData
import RWMRecurrenceRule
import SwiftUI
import EventKit

class GameplanFormModel: ObservableObject {
	@Published var frequency: EKRecurrenceFrequency = .weekly
	@Published var byDayOfWeek: EKWeekday = .tuesday
	@Published var source: String? = ""

	private var gameplan: Gameplan

	init(gameplan: Gameplan) {
		self.gameplan = gameplan
		mapPublishedToCoreDataProperties()
	}

	private func mapPublishedToCoreDataProperties() {
		Publishers.CombineLatest($frequency, $byDayOfWeek)
			.map { frequency, byDayOfWeek in
				return EKRecurrenceRule(recurrenceWith: frequency, interval: 1, daysOfTheWeek: [EKRecurrenceDayOfWeek(byDayOfWeek)], daysOfTheMonth: nil, monthsOfTheYear: nil, weeksOfTheYear: nil, daysOfTheYear: nil, setPositions: nil, end: nil).rrule!
			}
			.sink { [weak self] ruleString in
				self?.gameplan.rrule = ruleString
				self?.saveContext()
			}
			.store(in: &cancellables)
		$source.assign(to: \.source, on: gameplan).store(in: &cancellables)
	}

	private var cancellables: Set<AnyCancellable> = []

	private func saveContext() {
		do {
			try PersistenceController.shared.container.viewContext.save()
		} catch {
			// Handle the error appropriately
			print("Error saving context: \(error)")
		}
	}
}

private let SPACING: CGFloat = 8

struct GameplanForm: View {
	var gameplan: Gameplan
	@ObservedObject var form: GameplanFormModel

	init(gameplan: Gameplan) {
		self.gameplan = gameplan
		self.form = GameplanFormModel(gameplan: gameplan)
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 30) {
			VStack(alignment: .leading, spacing: SPACING) {
				Label("Frequency", systemImage: "clock.arrow.circlepath").labelStyle(.titleOnly).fontWeight(.medium)
				Picker("Frequency", selection: $form.frequency) {
					ForEach([EKRecurrenceFrequency.daily,
					         EKRecurrenceFrequency.weekly,
					         EKRecurrenceFrequency.monthly], id: \.self) { frequency in
						Text(recurrenceFrequencyToString(frequency).capitalized).tag(frequency)
					}
				}.pickerStyle(.segmented)
			}

			if form.frequency != .daily {
				VStack(alignment: .leading, spacing: SPACING) {
					Label("Day of Week", systemImage: "calendar").labelStyle(.titleOnly).fontWeight(.medium)
					Picker("Day of Week", selection: $form.byDayOfWeek) {
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
		}
	}
}

struct GameplanForm_Previews: PreviewProvider {
	static var previews: some View {
		if let gameplan = PersistenceController.fetchFirstGameplan(viewContext: PersistenceController.preview.container.viewContext) {
			GameplanForm(gameplan: gameplan)
		}
	}
}
