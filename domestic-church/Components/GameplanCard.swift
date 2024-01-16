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

	var type: ActivityType { gameplan.activityType }

	@Environment(GameplanScreenViewModel.self) private var gameplanScreenViewModel

	var expanded: Bool { gameplanScreenViewModel.expandedId == gameplan.id }

	var body: some View {
		VStack {
			HStack {
				VStack {
					Image(systemName: TYPE_ICONS[type]!)
						.foregroundColor(TYPE_COLORS[type]!)
						.font(.subheadline)
						.frame(height: 16)
					Spacer()
				}

				VStack(alignment: .leading) {
					Text(TYPE_TITLES[type]!)
						.font(.headline)
						.foregroundColor(TYPE_COLORS[type]!)
						.frame(height: 16)

					Text("\(gameplan.rruleObject.description) at \(gameplan.timeOfDay.formatted(date: .omitted, time: .shortened))")
						.font(.caption)
						.foregroundColor(.gray)
				}
				
				Spacer()

				Image(systemName: "chevron.forward")
					.font(.system(size: 14))
					.rotationEffect(Angle(degrees: expanded ? 90 : 0))
					.padding(.trailing)
				
			}
			.padding(.vertical, 8)
			.contentShape(Rectangle())
			.onTapGesture { withAnimation(.spring(.snappy)) {
				gameplanScreenViewModel.expandedId = expanded ? nil : gameplan.id
			} }

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
