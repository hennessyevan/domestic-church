//
//  Array+Extensions.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-11-17.
//

import Foundation

extension Array where Element: Equatable {
	func subtracting(_ array: [Element]) -> [Element] {
		var result: [Element] = []
		var toSub = array

		for i in self {
			if let index = toSub.firstIndex(of: i) {
				toSub.remove(at: index)
				continue
			}
			else {
				result.append(i)
			}
		}
		return result
	}
}
