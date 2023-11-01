//
//  TrailingIconLabelStyle.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-10-31.
//

import SwiftUI

struct TrailingIconLabelStyle: LabelStyle {
	func makeBody(configuration: Configuration) -> some View {
		HStack {
			configuration.title
			configuration.icon
		}
	}
}

#Preview {
	Button(action: {}, label: {
		Label(
			title: { Text("Label") },
			icon: { Image(systemName: "chevron.right") }
		)
		.labelStyle(TrailingIconLabelStyle())
	})
}
