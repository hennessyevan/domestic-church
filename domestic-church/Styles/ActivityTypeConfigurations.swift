//
//  ActivityTypeConfigurations.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-10-31.
//

import SwiftUI
import SystemColors

let TYPE_TITLES: [ActivityType: String] = [
	.scripture: "Scripture",
	.personalPrayer: "Personal Prayer",
	.conjugalPrayer: "Couple Prayer",
	.familyPrayer: "Family Prayer"
]

let TYPE_COLORS: [ActivityType: Color] = [
	.scripture: Color("scripture"),
	.personalPrayer: Color("personalPrayer"),
	.conjugalPrayer: Color("personalPrayer"),
	.familyPrayer: Color("personalPrayer"),
]

let TYPE_ICONS: [ActivityType: String] = [
	.scripture: "book.closed.fill",
	.personalPrayer: "person.fill",
	.conjugalPrayer: "figure.2.arms.open",
	.familyPrayer: "figure.2.and.child.holdinghands"
]
