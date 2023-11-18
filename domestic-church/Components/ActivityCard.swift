//
//  ActivityCard.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-08-25.
//

import SwiftUI
import SystemColors

struct ActivityCard: View {
	var activity: Activity
	var type: ActivityType { activity.activityType }

	@EnvironmentObject var romcal: Romcal

	var ordoEntry: OrdoEntry? {
		if let liturgicalDate = romcal.findBy(date: activity.date) {
			return Ordo.shared.getOrdoEntry(for: liturgicalDate)
		}

		return nil
	}

	var body: some View {
		NavigationLink {
			ActivityView(activity: activity)
		} label: {
			VStack {
				HStack {
					Image(systemName: TYPE_ICONS[type]!)
						.foregroundColor(TYPE_COLORS[type]!)
						.font(.system(size: 14))

					Text(self.cardTitle)
						.font(.headline)
						.foregroundColor(TYPE_COLORS[type]!)

					Spacer()
					Image(systemName: "chevron.forward")
						.font(.system(size: 14))
						.foregroundStyle(Color.label)
				}
				.frame(minWidth: 0, maxWidth: .infinity)

				Spacer()

				HStack(alignment: .lastTextBaseline) {
					Text(cardDescription)
						.font(.title2)
						.foregroundStyle(Color.label)
					Spacer()
					Text("\(activity.date, formatter: activity.date.isInToday ? timeFormatter : dateFormatter)")
						.font(.caption)
						.foregroundStyle(Color.label)
				}
			}
		}
		.padding(.all, 16)
		.frame(minWidth: 100, idealWidth: .infinity, maxWidth: .infinity)
		.frame(minHeight: 100, idealHeight: 100, maxHeight: 100)
#if os(iOS)
			.background(Color.secondarySystemGroupedBackground)
#endif
			.cornerRadius(16)
	}

	private var cardTitle: String {
		guard let source = activity.source else {
			return activity.activityType.rawValue.localized
		}

		switch source {
		case .dailyGospel, .bibleInAYear:
			return source.rawValue.localized
		case .custom:
			return activity.activityType.rawValue.localized
		}
	}

	private var cardDescription: String {
		guard let source = activity.source else {
			return ""
		}

		switch source {
		case .dailyGospel:
			return ordoEntry?.gospel.formatted ?? ""
		case .bibleInAYear:
			return "FIXME"
		case .custom:
			return activity.customSourceTitle.isEmpty ? source.rawValue.localized : activity.customSourceTitle
		}
	}
}

private let dateFormatter: DateFormatter = {
	let formatter = DateFormatter()
	formatter.doesRelativeDateFormatting = true
	formatter.timeStyle = .none
	formatter.dateStyle = .medium
	return formatter
}()

private let timeFormatter: DateFormatter = {
	let formatter = DateFormatter()
	formatter.timeStyle = .short
	formatter.dateStyle = .none
	return formatter
}()

#Preview {
	let examples = [
		Activity(id: UUID(), activityType: .scripture, date: Date().advanced(by: 60000), source: .dailyGospel),
		Activity(id: UUID(), activityType: .personalPrayer, date: .now, source: .custom),
		Activity(id: UUID(), activityType: .personalPrayer, date: .now, source: .custom, customSourceTitle: "Magnificat"),
		Activity(id: UUID(), activityType: .conjugalPrayer, date: .now),
		Activity(id: UUID(), activityType: .familyPrayer, date: .now),
	]

	return VStack(alignment: .leading) {
		ForEach(examples) { activity in
			ActivityCard(activity: activity)
		}
		Spacer()
	}
	.environmentObject(Romcal.preview)
	.padding(.all)
	.frame(minHeight: 0, maxHeight: .infinity)
#if os(iOS)
		.background(Color.systemGroupedBackground)
#endif
}
