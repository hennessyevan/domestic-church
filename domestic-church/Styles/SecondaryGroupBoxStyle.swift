import SwiftUI

struct SecondaryGroupBoxStyle: GroupBoxStyle {
	func makeBody(configuration: Configuration) -> some View {
		VStack(alignment: .leading) {
			configuration.label.fontWeight(.medium)
			configuration.content
		}
		.padding()
		.background(Color.systemGroupedBackground)
		.clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
	}
}
