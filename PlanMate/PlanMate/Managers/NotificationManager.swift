//
//  NotificationManager.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-20.
//

import UserNotifications
import Foundation

class NotificationManager {
    static let shared = NotificationManager()
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {}
    
    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
            }
        }
    }
    
    func scheduleVoteReminder(for activity: ProposeActivity) {
        // Create a unique identifier for this activity's notification
        let notificationId = "vote-reminder-\(activity.id)"
        
        // Remove any existing notification for this activity
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [notificationId])
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Vote Reminder"
        content.body = "Don't forget to submit your vote for '\(activity.title)' proposed activity"
        content.sound = .default
        
        // Schedule notification for 24 hours from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: notificationId,
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func cancelVoteReminder(for activityId: String) {
        let notificationId = "vote-reminder-\(activityId)"
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [notificationId])
    }
}
