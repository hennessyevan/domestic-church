//
//  GameplanSchedule.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-08-25.
//

import EventKit
import Foundation
import RWMRecurrenceRule

func listDates() -> [Date] {
	let endDate = try! Date("2023-10-14T20:15:00Z", strategy: .iso8601)
	let rule = EKRecurrenceRule(
		recurrenceWith: .weekly,
		interval: 1,
		daysOfTheWeek: [EKRecurrenceDayOfWeek(.tuesday)],
		daysOfTheMonth: nil,
		monthsOfTheYear: nil,
		weeksOfTheYear: nil,
		daysOfTheYear: nil,
		setPositions: nil,
		end: EKRecurrenceEnd(end: endDate)
	)
	.rrule!
	let parser = RWMRuleParser()
	var returnDates: [Date] = []

	if let rules = parser.parse(rule: rule) {
		let scheduler = RWMRuleScheduler()
		let start = Date()
		scheduler.enumerateDates(with: rules, startingFrom: start, using: { date, _ in
			if let date = date {
				returnDates.append(date)
			}
		})
	}

	return returnDates
}
