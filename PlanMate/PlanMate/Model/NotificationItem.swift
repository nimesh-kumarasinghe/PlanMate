//
//  NotificationItem.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-20.
//

import Foundation

struct NotificationItem: Identifiable {
    let id: String
    let title: String
    let message: String
    let timestamp: String
    let group: String
    let type: String
    var isRead: Bool = false
    let rawTimestamp: Date
}

// Notification Model
struct UserNotification {
    let id: String
    let activityId: String
    let title: String
    let message: String
    let type: String
    let timestamp: Date
}
