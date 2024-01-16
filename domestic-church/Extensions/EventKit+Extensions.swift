//
//  EventKit+Extensions.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-12-19.
//

import Foundation
import EventKit

public extension EKRecurrenceRule {
	override var description: String {
		switch self.frequency {
		case .daily:
			return recurrenceFrequencyToString(self.frequency)
		case .weekly:
			if let firstDayOfTheWeekEntry = self.daysOfTheWeek?.first {
				return "\(recurrenceFrequencyToString(self.frequency)) on \(weekdayToString(firstDayOfTheWeekEntry.dayOfTheWeek))"
			}
		default:
			return ""
		}

		return ""
	}
}
