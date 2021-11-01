//
//  NotificationManager.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/23.
//

import Foundation
import UserNotifications

class LocalNotificationManager {

    var notifications = [Notification]()

    // check and debug scheduled local notifications
    func listScheduledNotifications() {

        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in

            for notification in notifications {
                print(notification)
            }
        }
    }

    // ask permission to send local notifications
    private func requestAuthorization() {

        UNUserNotificationCenter.current().requestAuthorization(options: [ .alert, .badge, .sound]) { granted, error in

            if granted == true && error == nil {
                self.scheduleNotifications()
            }
        }
    }

    // check local notifications permission status
    func schedule() {

        UNUserNotificationCenter.current().getNotificationSettings { settings in

            switch settings.authorizationStatus {

            case .notDetermined:
                self.requestAuthorization()

            case .authorized, .provisional:
                self.scheduleNotifications()

            default:
                break
            }
        }
    }

    // schedule local notifications
    private func scheduleNotifications() {

        for notification in notifications {

            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: notification.dateTime, repeats: false)

            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in

                guard error == nil else { return }

                print("Notification scheduled! --- ID = \(notification.id)")
            }
        }
    }
}

struct Notification {

    var id: String
    var title: String
    var dateTime: DateComponents
}
