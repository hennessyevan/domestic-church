//
//  Gameplan.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-10-10.
//
//

import EventKit
import Foundation
import RWMRecurrenceRule
import SwiftData

enum ActivityType: String, CaseIterable, Codable, Identifiable {
	case scripture
	case personalPrayer
	case conjugalPrayer
	case familyPrayer

	var id: ActivityType { self }
}

enum Source: String, CaseIterable, Codable, Identifiable {
	case dailyGospel
	case bibleInAYear
	case custom

	var id: Source { self }
}

func createRecurrenceRule(frequency: EKRecurrenceFrequency = .weekly, byDayOfWeek: EKWeekday = .sunday) -> EKRecurrenceRule {
	EKRecurrenceRule(
		recurrenceWith: frequency,
		interval: 1,
		daysOfTheWeek: [EKRecurrenceDayOfWeek(byDayOfWeek)],
		daysOfTheMonth: nil,
		monthsOfTheYear: nil,
		weeksOfTheYear: nil,
		daysOfTheYear: nil,
		setPositions: nil,
		end: nil
	)
}

private var defaultRule = createRecurrenceRule(frequency: .weekly, byDayOfWeek: .sunday)

@Model
public final class Gameplan {
	var activityType: ActivityType
	var rrule: String?
	var source: Source
	var createdAt: Date?
	var customSourceText: String = ""
	var customSourceTitle: String = ""

	init(activityType: ActivityType, rrule: String? = nil, source: Source? = nil) {
		let settings = formSettingsForActivityType[activityType] ?? DefaultFormSettings()

		self.activityType = activityType
		self.rrule = rrule
		self.source = source ?? settings.sources.first ?? .custom
		self.createdAt = Date()
	}

	private var rruleObject: EKRecurrenceRule {
		if let rrule = rrule {
			return EKRecurrenceRule(recurrenceWith: rrule) ?? defaultRule
		} else {
			return defaultRule
		}
	}

	var frequency: EKRecurrenceFrequency {
		get { rruleObject.frequency }
		set { rrule = createRecurrenceRule(frequency: newValue, byDayOfWeek: byDayOfWeek).rrule! }
	}

	var byDayOfWeek: EKWeekday {
		get {
			if let byDayOfWeek = rruleObject.daysOfTheWeek?.first {
				return byDayOfWeek.dayOfTheWeek
			}
			return .sunday
		}
		set { rrule = createRecurrenceRule(frequency: frequency, byDayOfWeek: newValue).rrule! }
	}

	var nextOccurrence: Activity? {
		let parser = RWMRuleParser()

		if let rrule = rrule, let rules = parser.parse(rule: rrule) {
			let scheduler = RWMRuleScheduler()
			let calendar = Calendar.current
			let startingDate = calendar.date(byAdding: .day, value: -1, to: .now) ?? .now

			if let date = scheduler.nextDate(after: startingDate, with: rules, startingFrom: startingDate) {
				return Activity(
					id: UUID(),
					activityType: activityType,
					date: date,
					source: source
				)
			}
		}

		return nil
	}
}
