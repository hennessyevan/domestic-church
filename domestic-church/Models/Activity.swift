//
//  Gameplan+Data.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-08-25.
//

import Foundation

struct Activity: Identifiable, Equatable, Hashable {
	var id: UUID
	var gameplan: Gameplan? = nil
	var activityType: ActivityType
	var date: Date
	var source: Source?
	var customSourceText: String = ""
	var customSourceTitle: String = ""
}
