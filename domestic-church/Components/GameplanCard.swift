//
//  GameplanCard.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-08-25.
//

import SwiftData
import SwiftUI
import SystemColors

struct GameplanCard: View {
	var gameplan: Gameplan

	var type: ActivityType { self.gameplan.activityType }

	@State private var expanded = false

	var body: some View {
		VStack {
			HStack {
				Image(systemName: TYPE_ICONS[type]!)
					.foregroundColor(TYPE_COLORS[type]!)
					.font(.system(size: 14))
				Text(TYPE_TITLES[type]!)
					.font(.headline)
					.foregroundColor(TYPE_COLORS[type]!)
				Image(systemName: "chevron.forward")
					.font(.system(size: 14))
					.rotationEffect(Angle(degrees: expanded ? 90 : 0))
				Spacer()
			}
			.padding(.vertical, 8)
			.contentShape(Rectangle())
			.onTapGesture { withAnimation { expanded.toggle() } }

			if expanded {
				Divider()
				GameplanForm(gameplan: gameplan)
					.padding(.vertical, 8)
			}
		}
		.padding(.all)
		.frame(minWidth: 100, idealWidth: .infinity, maxWidth: .infinity)
		#if os(iOS)
			.background(Color.secondarySystemGroupedBackground)
		#endif
			.cornerRadius(12)
	}
}

#Preview {
	do {
		let config = ModelConfiguration(isStoredInMemoryOnly: true)
		let container = try ModelContainer(for: Gameplan.self, configurations: config)

		let examples = [
			Gameplan(activityType: .scripture),
			Gameplan(activityType: .personalPrayer),
			Gameplan(activityType: .conjugalPrayer),
			Gameplan(activityType: .familyPrayer)
		]

		return VStack {
			ForEach(examples, id: \.activityType) { gameplan in
				GameplanCard(gameplan: gameplan)
					.modelContainer(container)
			}
		}
		.padding(.all)
		.frame(minHeight: 0, maxHeight: .infinity)
		#if os(iOS)
			.background(Color(uiColor: UIColor.systemGroupedBackground))
		#endif
	} catch {
		fatalError("Fatal Error")
	}
}
