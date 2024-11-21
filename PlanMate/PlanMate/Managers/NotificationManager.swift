//
//  NotificationManager.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-20.
//

import UserNotifications
import Foundation
import FirebaseFirestore

class NotificationManager {
    static let shared = NotificationManager()
    private let notificationCenter = UNUserNotificationCenter.current()
    private let db = Firestore.firestore()
    
    // Store listener to remove when needed
    private var notificationListener: ListenerRegistration?
    
    private init() {}
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
                completion(false)
            } else {
                completion(granted)
            }
        }
    }
    
    // start background Listener
    func startNotificationListener(for userId: String) {
        // Remove any existing listener
        stopNotificationListener()
        
        // Create a reference to the user document
        let userRef = db.collection("users").document(userId)
        
        // Start listener
        notificationListener = userRef.addSnapshotListener { [weak self] documentSnapshot, error in
            guard let self = self,
                  let document = documentSnapshot,
                  let data = document.data(),
                  document.exists else {
                print("Error listening to notifications: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            
            // Get user preferences
            let showEventNotifications = data["showEventNotifications"] as? Bool ?? false
            let showProposeNotifications = data["showProposeNotifications"] as? Bool ?? false
            
            // Get current notifications array from users document
            guard let notifications = data["notifications"] as? [[String: Any]] else { return }
            
            // Process only the most recent notification
            if let latestNotification = notifications.last {
                self.processNewNotification(
                    notificationData: latestNotification,
                    showEventNotifications: showEventNotifications,
                    showProposeNotifications: showProposeNotifications
                )
            }
        }
    }
    
    // stop background listener
    func stopNotificationListener() {
        notificationListener?.remove()
        notificationListener = nil
    }
    
    // process new notification
    private func processNewNotification(
        notificationData: [String: Any],
        showEventNotifications: Bool,
        showProposeNotifications: Bool
    ) {
        let type = notificationData["type"] as? String ?? ""
        
        // Check if we should process this notification based on user preferences
        if (type == "Event" && !showEventNotifications) ||
            (type == "PA" && !showProposeNotifications) {
            return
        }
        
        // Create notification object
        let notification = UserNotification(
            id: notificationData["id"] as? String ?? UUID().uuidString,
            activityId: notificationData["activityId"] as? String ?? "",
            title: notificationData["title"] as? String ?? "",
            message: notificationData["message"] as? String ?? "",
            type: type,
            timestamp: (notificationData["timestamp"] as? Timestamp)?.dateValue() ?? Date()
        )
        
        // Schedule the notification immediately
        scheduleImmediateNotification(notification)
    }
    
    // schedule immediate notification
    private func scheduleImmediateNotification(_ notification: UserNotification) {
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.message
        content.sound = .default
        
        // Add activity ID to userInfo
        content.userInfo = [
            "activityId": notification.activityId,
            "notificationId": notification.id
        ]
        
        // Create trigger for immediate delivery
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // Create request with unique identifier
        let request = UNNotificationRequest(
            identifier: notification.id,
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
    
    // Vote Reminder
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
        
        // Schedule notification
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
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
