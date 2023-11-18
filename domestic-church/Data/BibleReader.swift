//
//  BibleReader.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-11-17.
//

import Foundation
import GRDB

struct Verse: Codable, FetchableRecord {
	let book_number: Int
	let chapter: Int
	let verse: Int
	let text: String
	let id: String
}

struct Passage {
	let verses: [String]
	let title: String
	let reference: String
}

class BibleReader {
	enum Translation: String {
		case NRSV = "nrsvce"
	}

	let translation: Translation = .NRSV
	var dbq: DatabaseQueue {
		try! DatabaseQueue(path: Bundle.main.url(forResource: translation.rawValue, withExtension: "sqlite")!.path())
	}

	func getVerses(ids: [String]) -> [Verse]? {
		var verses: [Verse]? = nil
		try! dbq.read { db in
			 verses = try! Verse.fetchAll(db, sql: "select * from verses where id in (\(ids.map { "'\($0)'" }.joined(separator: ",")))")
		}

		return verses
	}
}
