//
//  GameplanFormSettings.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-11-20.
//

import Foundation

protocol FormSettings {
	var sources: [Source] { get }
}

struct DefaultFormSettings: FormSettings {
	var sources: [Source] = []
}

struct ScriptureFormSettings: FormSettings {
	var sources: [Source] = ScriptureSources
}

struct PrayerFormSettings: FormSettings {
	var sources: [Source] = CommonPrayerSources + [.custom]
}

var formSettingsForActivityType: [ActivityType: FormSettings] = [
	.scripture: ScriptureFormSettings(),
	.personalPrayer: PrayerFormSettings(),
	.conjugalPrayer: PrayerFormSettings(),
	.familyPrayer: PrayerFormSettings(),
]
