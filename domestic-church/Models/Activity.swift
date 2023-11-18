//
//  Gameplan+Data.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-08-25.
//

import Foundation

struct Activity: Identifiable, Equatable {
	var id: UUID
	var activityType: ActivityType
	var date: Date
	var source: Source?
	var customSourceText: String = ""
	var customSourceTitle: String = ""
}
