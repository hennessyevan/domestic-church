//
//  GameplanCard.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-08-25.
//

import SwiftUI
import SystemColors

let TYPE_TITLES: [Gameplan.ActivityType: String] = [
	.scripture: "Scripture"
]

let TYPE_COLORS: [Gameplan.ActivityType: Color] = [
	.scripture: Color("scripture")
]

let TYPE_ICONS: [Gameplan.ActivityType: String] = [
	.scripture: "book.closed.fill"
]

struct GameplanCard: View {
	var gameplan: Gameplan
	
	var type: Gameplan.ActivityType { self.gameplan.wrappedActivityType }

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
			.frame(minWidth: 0, maxWidth: .infinity)
#if os(iOS)
			.background(Color.systemBackground)
#endif
			.onTapGesture { withAnimation { expanded.toggle() } }
			

			if expanded {
				Divider()
				Spacer().frame(height: 20)
				GameplanForm(gameplan: gameplan)
			}
		}
		.padding(.all, 24)
		.frame(minWidth: 100, idealWidth: .infinity, maxWidth: .infinity)
#if os(iOS)
		.background(Color.systemBackground)
#endif
		.cornerRadius(16)
		.shadow(color: .systemGray.opacity(0.2), radius: 2, x: 0, y: 0)
		.shadow(color: .gray.opacity(0.24), radius: 5, x: 0, y: 5)
	}
}

struct GameplanCard_Previews: PreviewProvider {
	static var previews: some View {
		if let gameplan = PersistenceController.fetchFirstGameplan(viewContext: PersistenceController.preview.container.viewContext) {
			VStack {
				GameplanCard(gameplan: gameplan)
			}
			.padding(.all)
			.frame(minHeight: 0, maxHeight: .infinity)
#if os(iOS)
			.background(Color(uiColor: UIColor.systemGroupedBackground))
#endif
		}
	}
}
