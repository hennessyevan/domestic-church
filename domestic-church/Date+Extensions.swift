//
//  Date+Extensions.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-09-01.
//

import Foundation

extension Date {

	func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
		calendar.isDate(self, equalTo: date, toGranularity: component)
	}

	func isInSameYear(as date: Date) -> Bool { isEqual(to: date, toGranularity: .year) }
	func isInSameMonth(as date: Date) -> Bool { isEqual(to: date, toGranularity: .month) }
	func isInSameWeek(as date: Date) -> Bool { isEqual(to: date, toGranularity: .weekOfYear) }
	func isInSameCalendarDay(as date: Date) -> Bool {
		isInSameDay(as: date) && isInSameMonth(as: date) && isInSameYear(as: date)
	}
	
	func isAfter(date: Date) -> Bool { self > date }
	func isBefore(date: Date) -> Bool { self < date }

	func isInSameDay(as date: Date) -> Bool { Calendar.current.isDate(self, inSameDayAs: date) }
	func isWithin(_ count: Int, _ component: Calendar.Component, of date: Date) -> Bool {
		let upperBound = Calendar.current.date(byAdding: component, value: count, to: date)!
		let lowerBound = Calendar.current.date(byAdding: component, value: -count, to: date)!
		return self > lowerBound && self < upperBound
	}

	var isInThisYear:  Bool { isInSameYear(as: Date()) }
	var isInThisMonth: Bool { isInSameMonth(as: Date()) }
	var isInThisWeek:  Bool { isInSameWeek(as: Date()) }

	var isInYesterday: Bool { Calendar.current.isDateInYesterday(self) }
	var isInToday:     Bool { Calendar.current.isDateInToday(self) }
	var isInTomorrow:  Bool { Calendar.current.isDateInTomorrow(self) }

	var isInTheFuture: Bool { self > Date() }
	var isInThePast:   Bool { self < Date() }
}
