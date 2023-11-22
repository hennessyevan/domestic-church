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
		daysOfTheWeek: frequency == .weekly ? [EKRecurrenceDayOfWeek(byDayOfWeek)] : nil,
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
	private(set) var uuid = UUID()
	var activityType: ActivityType
	var rrule: String?
	var timeOfDay: Date = Date.now
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
		if let rrule {
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
			let timeOfDay = calendar.dateComponents([.hour, .minute, .second], from: timeOfDay)
			let timeAdjustedToday = calendar.date(bySettingHour: timeOfDay.hour!, minute: timeOfDay.minute!, second: 0, of: .now) ?? .now
			let startingDate = calendar.date(byAdding: .day, value: -2, to: timeAdjustedToday)!
			let after = calendar.date(byAdding: .hour, value: -2, to: .now)!

			if let date = scheduler.nextDate(after: after, with: rules, startingFrom: startingDate) {
				return Activity(
					id: UUID(),
					gameplan: self,
					activityType: activityType,
					date: date,
					source: source,
					customSourceText: customSourceText,
					customSourceTitle: customSourceTitle
				)
			}
		}

		return nil
	}

	var notificationDateComponents: DateComponents? {
		let calendar = Calendar.current
		var dateComponents = DateComponents()
		let timeComponents = calendar.dateComponents([.day, .hour, .minute], from: self.timeOfDay)
		
		dateComponents.hour = timeComponents.hour
		dateComponents.minute = timeComponents.minute
		dateComponents.timeZone = calendar.timeZone
		
		if rruleObject.frequency == .weekly {
			dateComponents.weekday = rruleObject.daysOfTheWeek?.first.hashValue
		}
		
		return dateComponents
	}
}


