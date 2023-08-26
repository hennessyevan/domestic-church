//
//  Gameplan+Data.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-08-25.
//

import EventKit
import Foundation
import RWMRecurrenceRule

public func weekdayToString(_ weekday: EKWeekday) -> String {
	switch weekday {
	case .sunday: return "Sunday"
	case .monday: return "Monday"
	case .tuesday: return "Tuesday"
	case .wednesday: return "Wednesday"
	case .thursday: return "Thursday"
	case .friday: return "Friday"
	case .saturday: return "Saturday"
	default: return "Unknown" // Handle unexpected cases
	}
}

public func recurrenceFrequencyToString(_ frequency: EKRecurrenceFrequency) -> String {
	switch frequency {
	case .daily: return "Daily"
	case .weekly: return "Weekly"
	case .monthly: return "Monthly"
	case .yearly: return "Yearly"
	default: return "Unknown" // Handle unexpected cases
	}
}

struct Activity: Identifiable {
	var id: UUID
	var activityType: Gameplan.ActivityType = .none
	var date: Date
}

extension Gameplan {
	enum ActivityType: String, CaseIterable {
		case scripture
		case none
	}

	enum Source: String, CaseIterable {
		case dailygospel
		case none
	}

	private var rruleObject: EKRecurrenceRule? {
		if let rrule = self.rrule {
			return EKRecurrenceRule(recurrenceWith: rrule)
		} else { return nil }
	}

	var wrappedActivityType: ActivityType {
		get {
			if let aType = self.activityType {
				return ActivityType(rawValue: String(aType)) ?? .none
			} else { return .none }
		}
		set {
			self.activityType = String(newValue.rawValue)
		}
	}

	var wrappedSource: Source {
		get {
			if let aSource = self.source {
				return Source(rawValue: String(aSource)) ?? .none
			} else { return .none }
		}
		set {
			self.source = String(newValue.rawValue)
		}
	}

	var frequency: EKRecurrenceFrequency? {
		if let rruleObject {
			return rruleObject.frequency
		}
		return nil
	}

	var byDayOfWeek: EKWeekday? {
		if let byDayOfWeek = rruleObject?.daysOfTheWeek?.first {
			return byDayOfWeek.dayOfTheWeek
		}
		return nil
	}

	var nextOccurrence: Activity? {
		let parser = RWMRuleParser()

		if let rrule = self.rrule, let rules = parser.parse(rule: rrule) {
			let scheduler = RWMRuleScheduler()
			if let date = scheduler.nextDate(after: .now, with: rules, startingFrom: .now) {
				return Activity(id: UUID(), activityType: self.wrappedActivityType, date: date)
			}
		}

		return nil
	}
}
