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
	/// Scripture
	case dailyGospel
	case bibleInAYear
	/// Prayer
	case ourFather
	case hailMary
	case guardianAngel
	case morningOffering
	case angelus
	case hailHolyQueen
	case benedictus
	case magnificat
	case memorare
	case eveningPrayer
	case animaChristi
	case comeHolySpirit
	case saintJoseph
	case saintMichael

	case custom

	var id: Source { self }
}

let CommonPrayerSources: [Source] = [
	.ourFather,
	.hailMary,
	.ourFather,
	.hailMary,
	.guardianAngel,
	.morningOffering,
	.angelus,
	.hailHolyQueen,
	.benedictus,
	.magnificat,
	.memorare,
	.eveningPrayer,
	.animaChristi,
	.comeHolySpirit,
	.saintJoseph,
	.saintMichael,
]
let ScriptureSources: [Source] = [
	.dailyGospel,
//	.bibleInAYear
]

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

extension Gameplan {
	var uuid: UUID {
		get { uuidRawValue ?? UUID() }
		set { uuidRawValue = newValue }
	}

	var activityType: ActivityType {
		get { ActivityType(rawValue: activityTypeRawValue ?? "scripture") ?? .scripture }
		set { activityTypeRawValue = newValue.rawValue }
	}

	var timeOfDay: Date {
		get { timeOfDayRawValue ?? Date() }
		set { timeOfDayRawValue = newValue }
	}

	var source: Source {
		get { Source(rawValue: sourceRawValue ?? "dailyGospel") ?? .dailyGospel }
		set { sourceRawValue = newValue.rawValue }
	}

	var customSourceText: String {
		get { customSourceTextRawValue ?? "" }
		set { customSourceTextRawValue = newValue }
	}

	var customSourceTitle: String {
		get { customSourceTitleRawValue ?? "" }
		set { customSourceTitleRawValue = newValue }
	}

	var rruleObject: EKRecurrenceRule {
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

		if let rrule, let rules = parser.parse(rule: rrule) {
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
		let timeComponents = calendar.dateComponents([.day, .hour, .minute], from: timeOfDay)

		dateComponents.hour = timeComponents.hour
		dateComponents.minute = timeComponents.minute
		dateComponents.timeZone = calendar.timeZone

		if rruleObject.frequency == .weekly {
			dateComponents.weekday = rruleObject.daysOfTheWeek?.first.hashValue
		}

		return dateComponents
	}
}
