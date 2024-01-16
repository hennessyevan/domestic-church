//
//  ActivityView.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-08-26.
//

import SwiftUI

struct ActivityView: View {
	var activity: Activity

	@EnvironmentObject var romcal: Romcal

	var passage: Passage? {
		if activity.source == .dailyGospel,
		   let liturgicalDate = romcal.findBy(date: activity.date)
		{
			return Ordo.shared.getPassage(for: liturgicalDate, reading: .gospel)
		}

		return nil
	}

	var commonPrayer: String? {
		if let source = activity.source, CommonPrayerSources.contains(source) {
			return "\(source.rawValue)Text".localized
		}

		return nil
	}

	private var title: String {
		if let passage { return passage.reference }

		if activity.source == .custom, !activity.customSourceTitle.isEmpty {
			return activity.customSourceTitle
		}

		return activity.source?.rawValue.localized ?? ""
	}

	private var subtitle: String {
		activity.activityType.rawValue.localized
	}

	private var text: String {
		if let passage { return passage.verses.joined(separator: " ") }
		if let commonPrayer { return commonPrayer }

		return activity.customSourceText
	}

	var body: some View {
		ZStack {
			ScrollView {
				HStack {
					VStack(alignment: .leading) {
						Text(subtitle)
							.font(.headline)
							.foregroundStyle(TYPE_COLORS[activity.activityType] ?? Color.label)

						Spacer().frame(height: 24)

						Text(LocalizedStringKey(stringLiteral: text))
							.font(.system(size: 20))
							.tint(TYPE_COLORS[activity.activityType] ?? Color.label)
					}

					Spacer()
				}
				.padding()
				.padding(.bottom, 50)
			}
		}.navigationTitle(title)
	}
}

#Preview {
	let activity = Activity(
		id: UUID(),
		activityType: .personalPrayer,
		date: .now,
		source: .angelus,
		customSourceText: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.\n\n Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
		customSourceTitle: "Magnificat"
	)

	return NavigationView {
		ActivityView(activity: activity)
	}.environmentObject(Romcal.preview)
}
