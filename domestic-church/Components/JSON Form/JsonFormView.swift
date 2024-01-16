//
//  JsonFormView.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-11-29.
//

import SwiftUI

enum FormValue: Hashable, Codable {
	case string(String)
	case int(Int)

	var stringValue: String {
		switch self {
		case .string(let string):
			return string
		case .int(let int):
			return String(int)
		}
	}

	var intValue: Int {
		switch self {
		case .string(let string):
			return Int(string) ?? 0
		case .int(let int):
			return int
		}
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		switch self {
		case .string(let string):
			try container.encode(string)
		case .int(let int):
			try container.encode(int)
		}
	}
}

@Observable class FormState {
	var values: [String: FormValue] = [:]

	func setValue(key: String, value: AnyHashable) {
		if let string = value as? String {
			values[key] = .string(string)
		} else if let int = value as? Int {
			values[key] = .int(int)
		} else {
			print("Couldn't set value for key: \(key)")
		}
	}
}

let emptyNode = ViewNode(type: .group, data: nil, children: [], modifiers: [], id: "1")

struct JsonFormView: View {
	var nodes: [ViewNode]
	@State private var formState = FormState()

	init(json: String) {
		if let jsonData = json.data(using: .utf8), let node = JSONHelper.node(fromData: jsonData) {
			nodes = node
		} else {
			nodes = [emptyNode]
		}
	}

	var body: some View {
		Form {
			ViewDecoder.viewsForNodes(nodes)
				.environment(formState)
				.onChange(of: formState.values) { _, newValue in
					let encoder = JSONEncoder()
					if let jsonData = try? encoder.encode(newValue) {
						if let jsonString = String(data: jsonData, encoding: .utf8) {
							print(jsonString)
						}
					}
				}
		}
	}
}

let testjson = """
[
	{
		"id": "1",
		"type": "TextField",
		"label": "Title",
		"children": [],
		"modifiers": []
	}
]
"""

#Preview {
	JsonFormView(json: testjson)
}
