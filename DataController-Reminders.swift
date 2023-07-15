//
//  DataController-Reminders.swift
//  ItemsManagement
//
//  Created by Sam Hui on 2023/06/11.
//

import Foundation
import UserNotifications

extension DataController {
    func addReminders(for item: Item, completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()

        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestNotification { success in
                    if success {
                        self.placeReminders(for: item, completion: completion)
                    } else {
                        DispatchQueue.main.async {
                            completion(false)
                        }
                    }
                }

            case .authorized:
                self.placeReminders(for: item, completion: completion)
            default:
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }

    func removeReminders(for filter: Filter) {
        let center = UNUserNotificationCenter.current()
        guard let id = filter.item?.objectID.uriRepresentation().absoluteString else { return }

        center.removePendingNotificationRequests(withIdentifiers: [id])
    }

    private func requestNotification(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            completion(granted)
        }
    }

    private func placeReminders(for item: Item, completion: @escaping (Bool) -> Void) {
        let content = UNMutableNotificationContent()
        content.title = item.itemName
        content.sound = .default
        content.subtitle = "\(item.itemName) is almost out of stock. Please refill the stock."

        let components = Calendar.current.dateComponents(
            [
                .year,
                .month,
                .day,
                .hour,
                .minute
            ], from: item.itemReminderDate)

//        components = Calendar.current.dateComponents([.hour, .minute], from: filter.reminderDate)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let id = item.objectID.uriRepresentation().absoluteString
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if error == nil {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
}
