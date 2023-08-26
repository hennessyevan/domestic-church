//
//  ActivityCard.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-08-25.
//

import SwiftUI

struct ActivityCard: View {
	var activity: Activity
	var type: Gameplan.ActivityType { self.activity.activityType }

	var body: some View {
		VStack {
			HStack {
				Image(systemName: TYPE_ICONS[type]!)
					.foregroundColor(TYPE_COLORS[type]!)
					.font(.system(size: 14))
				Text(TYPE_TITLES[type]!)
					.font(.headline)
					.foregroundColor(TYPE_COLORS[type]!)
				Spacer()
				Image(systemName: "chevron.forward")
					.font(.system(size: 14))
			}
			.frame(minWidth: 0, maxWidth: .infinity)
			#if os(iOS)
				.background(Color.systemBackground)
			#endif

			Spacer()

			HStack(alignment: .lastTextBaseline) {
				Text("Matthew 12:32").font(.title2)
				Spacer()
				Text("\(activity.date, formatter: relativeDateFormatter)").font(.caption)
			}
		}
		.padding(.all, 16)
		.frame(minWidth: 100, idealWidth: .infinity, maxWidth: .infinity)
		.frame(height: 100)
		#if os(iOS)
			.background(Color.systemBackground)
		#endif
			.cornerRadius(16)
			.shadow(color: .systemGray.opacity(0.2), radius: 2, x: 0, y: 0)
	}
}

private let relativeDateFormatter: RelativeDateTimeFormatter = {
	let formatter = RelativeDateTimeFormatter()
	formatter.dateTimeStyle = .named
	return formatter
}()


struct ActivityCard_Previews: PreviewProvider {
	static var previews: some View {
		if let gameplan = PersistenceController.fetchFirstGameplan(viewContext: PersistenceController.preview.container.viewContext), let activity = gameplan.nextOccurrence {
			VStack {
				ActivityCard(activity: activity)
			}
			.padding(.all)
			.frame(minHeight: 0, maxHeight: .infinity)
#if os(iOS)
			.background(Color(uiColor: UIColor.systemGroupedBackground))
#endif
		}
	}
}

