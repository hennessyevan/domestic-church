//
//  String+Extensions.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-10-11.
//

import Foundation

extension String {
	var localized: String {
		return NSLocalizedString(self, comment: "")
	}
}
