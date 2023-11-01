//
//  Recurrence+Helpers.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-10-10.
//

import EventKit
import Foundation

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
