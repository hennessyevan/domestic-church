//
//  RomCal.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-08-26.
//

import Foundation
import JavaScriptCore
import SwiftUI
import SystemColors

extension JSContext {
	func callAsyncFunction(key: String, withArguments: [Any] = []) async throws -> JSValue {
		try await withCheckedThrowingContinuation { continuation in
			let onFulfilled: @convention(block) (JSValue) -> Void = {
				continuation.resume(returning: $0)
			}
			let onRejected: @convention(block) (JSValue) -> Void = {
				let error = NSError(domain: key, code: 0, userInfo: [NSLocalizedDescriptionKey: "\($0)"])
				continuation.resume(throwing: error)
			}
			let promiseArgs = [unsafeBitCast(onFulfilled, to: JSValue.self), unsafeBitCast(onRejected, to: JSValue.self)]

			let promise = self.objectForKeyedSubscript(key).call(withArguments: withArguments)
			promise?.invokeMethod("then", withArguments: promiseArgs)
		}
	}
}

let regionLocaleDict = [
	"us-en": "UnitedStates_En"
]

class Romcal: ObservableObject {
	@Published var context: JSContext!

	#if DEBUG
	static var preview: Romcal { Romcal() }
	#endif

	private func initContext() {
		let bundle = Bundle(for: Romcal.self)
		let country = Locale.current.region?.identifier
		let localeCode = Locale.current.language.languageCode?.identifier
		let locale = regionLocaleDict["\(country?.lowercased() ?? "us")-\(localeCode?.lowercased() ?? "en")"] ?? "UnitedStates_En"

		guard let romcal3FileUrl = bundle.url(forResource: "romcal3", withExtension: ".js"),
		      let localeFileUrl = bundle.url(forResource: locale, withExtension: ".js"),
		      let js = try? String(contentsOf: romcal3FileUrl, encoding: .utf8),
		      let localeJs = try? String(contentsOf: localeFileUrl, encoding: .utf8),
		      let context = JSContext()
		else {
			fatalError()
		}

		context.evaluateScript("window=global=this")
		context.evaluateScript(js)
		context.evaluateScript(localeJs)
		context.evaluateScript("var Romcal = window.Romcal")
		context.evaluateScript("var localizedCalendar = window.\(locale)")

		context.evaluateScript("""
		async function generateCalendar() {
			console.log()
			const romcal = new Romcal({ localizedCalendar: window.localizedCalendar, strictMode: true })
			window.calendar = await romcal.generateCalendar()
			const values = Object.values(window.calendar).flat().map(o => ({
				...o,
				name: o.name,
				seasonNames: o.seasonNames,
				colorNames: o.colorNames,
				rankName: o.rankName
			}))
			return JSON.stringify(values)
		}
		""")

		self.context = context
	}

	init() {
		self.initContext()
		Task {
			await self.generateCalendar()
			self.loaded = true
		}
	}

	private(set) static var loaded: Bool = false
	var loaded: Bool = false

	private func generateCalendar() async {
		var data: LiturgicalDates = []
		do {
			if let json = try await self.context.callAsyncFunction(key: "generateCalendar").toString() {
				let jsonData = Data(json.utf8)
				let decoder = JSONDecoder()

				let formatter = DateFormatter()
				formatter.calendar = Calendar(identifier: .iso8601)
				formatter.locale = Locale(identifier: "en_US_POSIX")
				formatter.timeZone = TimeZone.current

				enum DateError: String, Error {
					case invalidDate
				}

				decoder.dateDecodingStrategy = .custom { decoder -> Date in
					let container = try decoder.singleValueContainer()
					let dateStr = try container.decode(String.self)

					formatter.dateFormat = "yyyy-MM-dd"
					if let date = formatter.date(from: dateStr) {
						return date
					}
					throw DateError.invalidDate
				}

				data = try decoder.decode(LiturgicalDates.self, from: jsonData)
				DispatchQueue.main.async { [data] in
					let updatedData = data
					self.calendar = updatedData
				}
			}
		} catch DecodingError.dataCorrupted(let context) {
			print(context)
		} catch DecodingError.keyNotFound(let key, let context) {
			print("Key '\(key)' not found:", context.debugDescription)
			print("codingPath:", context.codingPath)
		} catch DecodingError.valueNotFound(let value, let context) {
			print("Value '\(value)' not found:", context.debugDescription)
			print("codingPath:", context.codingPath)
		} catch DecodingError.typeMismatch(let type, let context) {
			print("Type '\(type)' mismatch:", context.debugDescription)
			print("codingPath:", context.codingPath)
		} catch {
			print("error: ", error)
		}
	}

	@Published var calendar: LiturgicalDates = []

	var today: LiturgicalDate? {
		self.calendar.first(where: { liturgicalDate in
			liturgicalDate.date.isInSameCalendarDay(as: .now)
		})
	}

	func findBy(date: Date) -> LiturgicalDate? {
		self.calendar.first(where: { liturgicalDate in
			liturgicalDate.date.isInSameCalendarDay(as: date)
		})
	}

	func findBy(id: String) -> LiturgicalDate? {
		self.calendar.first(where: { liturgicalDate in
			liturgicalDate.id == id
		})
	}
}

extension Romcal {
	struct LiturgicalDate: Codable {
		let id: String
		let date: Date
		let precedence: String
		let rank: Rank
		/// The localized rank
		let rankName: String
		let allowSimilarRankItems: Bool
		let isHolyDayOfObligation: Bool
		let isOptional: Bool
		let i18nDef: [I18NDefElement]
		let seasons: [Season]
		/// The localized season names
		let seasonNames: [String]
		let periods: [Period]
		let colors: [Color]
		/// The localized color
		let colorNames: [String]
		let calendar: LiturgicalCalendar
		/// The localized name
		let name: String
		let cycles: Cycles
		let fromCalendarID: FromCalendarID?
		let titles: [String]
	}

	// MARK: - LiturgicalCalendar

	struct LiturgicalCalendar: Codable {
		let weekOfSeason: Int
		let dayOfSeason: Int
		let dayOfWeek: Int
		let nthDayOfWeekInMonth: Int
		let startOfSeason: Date
		let endOfSeason: Date
		let startOfLiturgicalYear: Date
		let endOfLiturgicalYear: Date
	}

	enum Color: String, Codable {
		case green = "GREEN"
		case red = "RED"
		case white = "WHITE"
		case black = "BLACK"
		case gold = "GOLD"
		case purple = "PURPLE"
		case rose = "ROSE"
	}

	// MARK: - Cycles

	struct Cycles: Codable {
		let properCycle: ProperCycle
		let sundayCycle: SundayCycle
		let weekdayCycle: WeekdayCycle
		let psalterWeek: PsalterWeek
	}

	enum ProperCycle: String, Codable {
		case properOfSaints = "PROPER_OF_SAINTS"
		case properOfTime = "PROPER_OF_TIME"
	}

	enum PsalterWeek: String, Codable {
		case week1 = "WEEK_1"
		case week2 = "WEEK_2"
		case week3 = "WEEK_3"
		case week4 = "WEEK_4"
	}

	enum SundayCycle: String, Codable {
		case yearA = "YEAR_A"
		case yearB = "YEAR_B"
		case yearC = "YEAR_C"
	}

	enum WeekdayCycle: String, Codable {
		case year1 = "YEAR_1"
		case year2 = "YEAR_2"
	}

	enum Cycle: Codable, Hashable {
		case sundayCycle(SundayCycle)
		case weekdayCycle(WeekdayCycle)
	}

	enum FromCalendarID: String, Codable {
		case pr
		case generalRoman = "GeneralRoman"
		case properOfTime = "ProperOfTime"
	}

	enum I18NDefElement: Codable {
		case i18NDefClass(I18NDefClass)
		case string(String)

		init(from decoder: Decoder) throws {
			let container = try decoder.singleValueContainer()
			if let x = try? container.decode(String.self) {
				self = .string(x)
				return
			}
			if let x = try? container.decode(I18NDefClass.self) {
				self = .i18NDefClass(x)
				return
			}
			throw DecodingError.typeMismatch(I18NDefElement.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for I18NDefElement"))
		}

		func encode(to encoder: Encoder) throws {
			var container = encoder.singleValueContainer()
			switch self {
			case .i18NDefClass(let x):
				try container.encode(x)
			case .string(let x):
				try container.encode(x)
			}
		}
	}

	// MARK: - I18NDefClass

	struct I18NDefClass: Codable {
		let day: Int?
		let dow: Int?
		let week: Int?
	}

	enum Period: String, Codable {
		case christmasOctave = "CHRISTMAS_OCTAVE"
		case christmasToPresentationOfTheLord = "CHRISTMAS_TO_PRESENTATION_OF_THE_LORD"
		case daysBeforeEpiphany = "DAYS_BEFORE_EPIPHANY"
		case daysFromEpiphany = "DAYS_FROM_EPIPHANY"
		case earlyOrdinaryTime = "EARLY_ORDINARY_TIME"
		case easterOctave = "EASTER_OCTAVE"
		case holyWeek = "HOLY_WEEK"
		case lateOrdinaryTime = "LATE_ORDINARY_TIME"
		case presentationOfTheLordToHolyThursday = "PRESENTATION_OF_THE_LORD_TO_HOLY_THURSDAY"
	}

	enum Rank: String, Codable {
		case memorial = "MEMORIAL"
		case solemnity = "SOLEMNITY"
		case sunday = "SUNDAY"
		case weekday = "WEEKDAY"
		case feast = "FEAST"
	}

	enum Season: String, Codable {
		case advent = "ADVENT"
		case christmasTime = "CHRISTMAS_TIME"
		case ordinaryTime = "ORDINARY_TIME"
		case lent = "LENT"
		case paschalTriduum = "PASCHAL_TRIDUUM"
		case easterTime = "EASTER_TIME"
	}

	typealias LiturgicalDates = [LiturgicalDate]
}

struct DictionaryWithKeyValue: Decodable {
	let key: String
	let value: String
}

protocol ValueRepresentable: RawRepresentable, Decodable where RawValue == String {
	init?(rawValue: RawValue)
}

extension ValueRepresentable {
	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let dictionaryWithValue = try container.decode(DictionaryWithKeyValue.self)
		if let result = Self(rawValue: dictionaryWithValue.value) {
			self = result
		} else {
			throw DecodingError.dataCorruptedError(
				in: container,
				debugDescription: "Invalid value: \(dictionaryWithValue.value)"
			)
		}
	}
}

protocol KeyRepresentable: RawRepresentable, Decodable where RawValue == String {
	init?(rawValue: RawValue)
}

extension KeyRepresentable {
	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let dictionaryWithKey = try container.decode(DictionaryWithKeyValue.self)
		if let result = Self(rawValue: dictionaryWithKey.key) {
			self = result
		} else {
			throw DecodingError.dataCorruptedError(
				in: container,
				debugDescription: "Invalid value: \(dictionaryWithKey.key)"
			)
		}
	}
}

extension Romcal {
	func color(from color: Color?) -> SwiftUI.Color {
		switch color {
		case .black: return .label
		case .gold: return .yellow
		case .green: return .green
		case .purple: return .purple
		case .red: return .red
		case .rose: return .pink
		case .white: return .label
		default: return .label
		}
	}
}
