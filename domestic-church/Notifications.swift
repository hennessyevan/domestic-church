//
//  Notifications.swift
//  domestic-church
//
//  Created by Evan Hennessy on 2023-11-20.
//

import Foundation
import NotificationCenter

class NotificationHelper {
	static func requestNotificationPermissions() {
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, error in
			if let error {
				print(error.localizedDescription)
			}
		}
	}
	
	static func hasNotificationPermissions() -> Bool {
		var hasNotificationPermissions = false
		
		UNUserNotificationCenter.current().getNotificationSettings { settings in
			if settings.authorizationStatus == .authorized {
				hasNotificationPermissions = true
			}
		}
		
		return hasNotificationPermissions
	}
	
	static func hasNotification(with id: String) -> Bool {
		var hasNotification = false
		
		UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
			for request in requests {
				if request.identifier == id {
					hasNotification = true
				}
			}
		}
		
		return hasNotification
	}
	
	static func clearAllNotifications() {
		UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
	}
}

extension Gameplan {
	func scheduleNotification() {
		if !NotificationHelper.hasNotificationPermissions() {
			NotificationHelper.requestNotificationPermissions()
		}
		
		if self.hasNotification() {
			self.cancelNotification()
		}
		
		let content = UNMutableNotificationContent()
		content.title = "Time for \(self.activityType.rawValue.localized)!".localized
		content.subtitle = "Tap to open Domestic Church".localized
		content.sound = UNNotificationSound.default
		
		if let notificationDateComponents = self.notificationDateComponents {
			let trigger = UNCalendarNotificationTrigger(dateMatching: notificationDateComponents, repeats: true)
			let request = UNNotificationRequest(identifier: self.uuid.uuidString, content: content, trigger: trigger)
			
			UNUserNotificationCenter.current().add(request)
		}
		
		#if DEBUG
		self.printExistingNotifications()
		#endif
	}
	
	#if DEBUG
	func triggerTestNotification() {
		if !NotificationHelper.hasNotificationPermissions() {
			NotificationHelper.requestNotificationPermissions()
		}
		
		let content = UNMutableNotificationContent()
		content.title = "Time for \(self.activityType.rawValue.localized)!".localized
		content.subtitle = "Tap to open Domestic Church".localized
		content.sound = UNNotificationSound.default
		
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
		let request = UNNotificationRequest(identifier: self.uuid.uuidString, content: content, trigger: trigger)
		
		UNUserNotificationCenter.current().add(request)
	}
	#endif
	
	func printExistingNotifications() {
		UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
			print(requests.count)
			for request in requests {
				print(request.identifier.description)
			}
		}
	}
	
	func hasNotification() -> Bool {
		NotificationHelper.hasNotification(with: self.uuid.uuidString)
	}
	
	func cancelNotification() {
		UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [self.uuid.uuidString])
	}
}
