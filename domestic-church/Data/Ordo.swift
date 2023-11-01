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

struct Passage {
	let verses: String
	let title: String
}

class Ordo {
	let ordo: OrdoJSON
	
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
	
	init() {
		self.ordo = Self.loadOrdo()
	}
	
	private func getOrdo(for cycle: Romcal.Cycle) -> [String: OrdoEntry] {
		switch cycle {
		case .sundayCycle(.yearA):
			return ordo.YEAR_A
		case .sundayCycle(.yearB):
			return ordo.YEAR_B
		case .sundayCycle(.yearC):
			return ordo.YEAR_C
		case .weekdayCycle(.year1):
			return ordo.YEAR_1
		case .weekdayCycle(.year2):
			return ordo.YEAR_2
		}
	}
	
	func getOrdoEntry(for liturgicalDate: Romcal.LiturgicalDate) -> OrdoEntry? {
		let id = liturgicalDate.id
		let cycle: Romcal.Cycle = liturgicalDate.calendar.dayOfWeek == 0 ? .sundayCycle(liturgicalDate.cycles.sundayCycle) : .weekdayCycle(liturgicalDate.cycles.weekdayCycle)
		let ordoCycle = getOrdo(for: cycle)
		
		return ordoCycle.first(where: { $0.key == id })?.value
	}
	
	func getPassage(for liturgicalDate: Romcal.LiturgicalDate, reading: Reading) -> Passage? {
		let id = liturgicalDate.id
		guard let ordoEntry = getOrdoEntry(for: liturgicalDate) else { return nil }
		
		let parser = BibleParser()
		let passage = parser.getVerses(verses: ordoEntry.gospel.range)
		
		return Passage(verses: passage, title: ordoEntry.gospel.formatted)
	}
}

class BibleParser {
	var bibleXML: String
	var passage: [String] = []
	
	init() {
		let biblePath = Bundle.main.path(forResource: "rsv", ofType: "xml")
		let bibleXML = try! String(contentsOfFile: biblePath!, encoding: .utf8)
		self.bibleXML = bibleXML
	}
	
	func getVerses(verses: [String]) -> String {
		let xmlParser = XMLHash.config { config in
			config.caseInsensitive = true
			config.shouldProcessLazily = true
			config.shouldProcessNamespaces = false
		}
		let xml = xmlParser.parse(bibleXML)
		
		var passage: [String] = []
		
		func enumerate(indexer: XMLIndexer) {
			for child in indexer.children {
				if child.element?.name == "verse", let osisID = child.element?.attribute(by: "osisID")?.text, verses.contains(osisID) {
					passage.append(child.element!.text)
					if passage.count.isMultiple(of: 2) {
						passage.append("\n\n")
					} else {
						passage.append(" ")
					}
				}
				enumerate(indexer: child)
			}
		}

		enumerate(indexer: xml)
		
		return passage.joined(separator: "")
	}
}
