//
//  Ordo.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-10-23.
//

import Foundation
import SWXMLHash

struct OrdoJSON: Codable {
	let YEAR_A: [String: OrdoEntry]
	let YEAR_B: [String: OrdoEntry]
	let YEAR_C: [String: OrdoEntry]
	let YEAR_1: [String: OrdoEntry]
	let YEAR_2: [String: OrdoEntry]
}

struct OrdoEntry: Codable {
	let firstReading: Reading
	let responsorialPsalm: Reading
	let gospel: Reading
	let secondReading: Reading?
}

struct Reading: Codable {
	let range: [String]
	let osis: String
	let formatted: String
}

class Ordo {
	let json = loadOrdo()
	static let shared = Ordo()
	let reader = BibleReader()
	
	enum Reading: String {
		case firstReading
		case secondReading
		case reponsorialPsalm
		case gospel
	}
	
	static func loadOrdo() -> OrdoJSON {
		let ordoPath = Bundle.main.path(forResource: "ordo", ofType: "json")
		let ordoJSON = try! String(contentsOfFile: ordoPath!, encoding: .utf8)
		
		let jsonData = Data(ordoJSON.utf8)
		let decoder = JSONDecoder()
		
		return try! decoder.decode(OrdoJSON.self, from: jsonData)
	}
	
	private func getOrdo(for cycle: Romcal.Cycle) -> [String: OrdoEntry] {
		switch cycle {
		case .sundayCycle(.yearA):
			return Ordo.shared.json.YEAR_A
		case .sundayCycle(.yearB):
			return Ordo.shared.json.YEAR_B
		case .sundayCycle(.yearC):
			return Ordo.shared.json.YEAR_C
		case .weekdayCycle(.year1):
			return Ordo.shared.json.YEAR_1
		case .weekdayCycle(.year2):
			return Ordo.shared.json.YEAR_2
		}
	}
	
	func getOrdoEntry(for liturgicalDate: Romcal.LiturgicalDate) -> OrdoEntry? {
		let id = liturgicalDate.id

		let cycles: [Romcal.Cycle] = liturgicalDate.calendar.dayOfWeek == 0
			? [.sundayCycle(liturgicalDate.cycles.sundayCycle), .weekdayCycle(liturgicalDate.cycles.weekdayCycle)]
			: [.sundayCycle(liturgicalDate.cycles.sundayCycle), .weekdayCycle(liturgicalDate.cycles.weekdayCycle)]
		
		let cycle = cycles.first(where: { cycle in
			let ordoCycle = getOrdo(for: cycle)
			let gospel = ordoCycle.first(where: { $0.key == id })?.value.gospel
			return gospel?.range != nil
		})
		
		if let cycle {
			return getOrdo(for: cycle).first(where: { $0.key == id })?.value
		}
		
		return nil
	}
	
	func getPassage(for liturgicalDate: Romcal.LiturgicalDate, reading: Reading) -> Passage? {
		guard let ordoEntry = getOrdoEntry(for: liturgicalDate) else { return nil }
	
		if let verses = reader.getVerses(ids: ordoEntry.gospel.range) {
			return Passage(verses: verses.map(\.text), title: "", reference: ordoEntry.gospel.formatted)
		}
		
		return nil
	}
}
