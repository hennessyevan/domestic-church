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
		if let liturgicalDate = romcal.findBy(date: activity.date) {
			return Ordo().getPassage(for: liturgicalDate, reading: .gospel)
		}

		return nil
	}

	var body: some View {
		ZStack {
			ScrollView {
				if let passage {
					VStack(alignment: .leading) {
						Text(passage.title)
							.font(.headline)
							.foregroundStyle(Color("scripture"))
						Spacer().frame(height: 24)
						Text(passage.verses)
					}
					.padding()
					.padding(.bottom, 50)
				}
			}
		}.navigationTitle(activity.source?.rawValue.localized ?? "")
	}
}

#Preview {
	NavigationView {
		ActivityView(activity: Activity(id: UUID(), activityType: .scripture, date: .now))
	}.environmentObject(Romcal.preview)
}
