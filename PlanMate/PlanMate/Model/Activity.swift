//
//  Activity.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-19.
//

import Foundation
import Firebase

struct Activity: Identifiable {
    var id: String
    let title: String
    let location: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    let reminder: String
    let groupName: String
    
    init?(id: String, data: [String: Any]) {
        guard
            let title = data["title"] as? String,
            let locationData = data["locations"] as? [[String: Any]],
            let startDate = (data["startDate"] as? Timestamp)?.dateValue(),
            let endDate = (data["endDate"] as? Timestamp)?.dateValue(),
            let isAllDay = data["isAllDay"] as? Bool,
            let reminder = data["reminder"] as? String,
            let groupName = data["groupName"] as? String
        else {
            return nil
        }
        
        self.id = id
        self.title = title
        self.location = locationData.first?["name"] as? String ?? "Unknown Location"
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.reminder = reminder
        self.groupName = groupName
    }
}
