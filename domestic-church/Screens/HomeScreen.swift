//
//  HomeScreen.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-08-25.
//

import SwiftUI
import SystemColors

struct HomeScreen: View {
	@Environment(\.managedObjectContext) private var viewContext

	@FetchRequest(
		sortDescriptors: [NSSortDescriptor(keyPath: \Gameplan.createdAt, ascending: true)],
		animation: .default)
	private var gameplans: FetchedResults<Gameplan>

	private var activities: [Activity] {
		gameplans.compactMap(\.nextOccurrence)
	}

	var body: some View {
		NavigationView {
			ScrollView {
				VStack {
					ForEach(activities) { activity in
						ActivityCard(activity: activity)
					}
				}
				.padding(.all)
				.navigationTitle("Home")
			}
			.frame(minWidth: 0, maxWidth: .infinity)
#if os(iOS)
				.background(Color.systemGroupedBackground)
			#endif
		}
	}
}

struct HomeScreen_Previews: PreviewProvider {
	static var previews: some View {
		HomeScreen()
			.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
	}
}
