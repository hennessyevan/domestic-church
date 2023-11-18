//
//  MarqueeText.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-11-02.

import SwiftUI

struct SizePreferenceKey: PreferenceKey {
	static var defaultValue: CGSize = .zero

	static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
		value = nextValue()
	}
}

public struct MeasureSizeModifier: ViewModifier {
	public func body(content: Content) -> some View {
		content.background(GeometryReader { geometry in
			Color.clear.preference(key: SizePreferenceKey.self,
			                       value: geometry.size)
		})
	}
}

public extension View {
	/// Measures the size of an element and calls the supplied closure.
	func CC_measureSize(perform action: @escaping (CGSize) -> Void) -> some View {
		self.modifier(MeasureSizeModifier())
			.onPreferenceChange(SizePreferenceKey.self, perform: action)
	}
}

public struct MarqueeText: View {
	public var text: String
	public var startDelay: Double
	public var alignment: Alignment

	@Environment(\.font) private var font
	@State private var animate = false
	@State private var textSize: CGSize = .zero

	/// Create a scrolling text view.
	public init(_ text: String, startDelay: Double = 3.0, alignment: Alignment? = nil) {
		self.text = text
		self.startDelay = startDelay
		self.alignment = alignment != nil ? alignment! : .topLeading
	}

	public var body: some View {
		let animation = Animation
			.linear(duration: Double(textSize.width) / 30)
			.delay(startDelay)
			.repeatForever(autoreverses: false)

		let nullAnimation = Animation
			.linear(duration: 0)

		return ZStack {
			GeometryReader { geo in
				if textSize.width > geo.size.width { // don't use self.animate as conditional here
					Group {
						Text(self.text)
							.lineLimit(1)
							.offset(x: self.animate ? -textSize.width - textSize.height * 2 : 0)
							.animation(self.animate ? animation : nullAnimation, value: self.animate)
							.onAppear {
								DispatchQueue.main.async {
									self.animate = geo.size.width < textSize.width
								}
							}
							.fixedSize(horizontal: true, vertical: false)
							.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)

						Text(self.text)
							.lineLimit(1)
							.offset(x: self.animate ? 0 : textSize.width + textSize.height * 2)
							.animation(self.animate ? animation : nullAnimation, value: self.animate)
							.onAppear {
								DispatchQueue.main.async {
									self.animate = geo.size.width < textSize.width
								}
							}
							.fixedSize(horizontal: true, vertical: false)
							.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
					}
					.onChange(of: self.text) {
						self.animate = geo.size.width < textSize.width
					}
					.clipped()
					.frame(width: geo.size.width)

				} else {
					Text(self.text)
						.onChange(of: self.text) {
							self.animate = geo.size.width < textSize.width
						}
						.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: alignment)
				}
			}
		}
		.overlay {
			Text(self.text)
				.lineLimit(1)
				.fixedSize()
				.CC_measureSize(perform: { size in
					self.textSize = size
				})
				.hidden()
		}
		.frame(height: textSize.height)
		.onDisappear { self.animate = false }
	}
}

#Preview {
	MarqueeText("This is an example which hopefully starts to scroll, otherwise we couldn't demonstrate anything...")
}
