//
//  Router.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-11-20.
//

import Foundation
import SwiftUI

enum Tab: Equatable, Hashable {
	case home
	case checkin
	case gameplan
}

enum Page: Equatable, Hashable {
	case root
	case activityView(id: UUID)
	case gameplanSetting(id: UUID)
}

// protocol UrlHandler {
//	func handle(_ url: URL, mutating: inout NavigationPath)
// }
//
// protocol ActivityHandler {
//	func handle(_ activity: NSUserActivity, mutating: inout NavigationPath)
// }

@Observable final class Router {
	static let shared = Router()
	var tab: Tab = .home
	var homePath = NavigationPath()

	private let decoder = JSONDecoder()
	private let encoder = JSONEncoder()

	func tabClicked(_ newTab: Tab) {
		if newTab == tab, tab == .home {
			homePath.removeLast(homePath.count)
		}
		tab = newTab
	}
	
	func goToActivity(_ activity: Activity) {
		homePath.removeLast(homePath.count)
		tab = .home
		homePath.append(activity)
	}

//	private let urlHandler: UrlHandler
//	private let activityHandler: ActivityHandler

//	init(urlHandler: UrlHandler, activityHandler: ActivityHandler) {
//		self.urlHandler = urlHandler
//		self.activityHandler = activityHandler
//	}

//	func handle(_ activity: NSUserActivity) {
//		activityHandler.handle(activity, mutating: &path)
//	}
//
//	func handle(_ url: URL) {
//		urlHandler.handle(url, mutating: &path)
//	}
}

extension Binding {
	func onUpdate(_ closure: @escaping () -> Void) -> Binding {
		Binding(get: {
			wrappedValue
		}, set: { newValue in
			wrappedValue = newValue
			closure()
		})
	}
}
