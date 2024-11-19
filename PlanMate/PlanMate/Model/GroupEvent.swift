//
//  GroupEvent.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-19.
//

import Foundation
import FirebaseFirestore

struct GroupEvent: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var groupId: String
    var groupName: String
    var isAllDay: Bool
    var locations: [EventLocation]
    var notes: [String]
    var participants: [String]
    var reminder: String
    var startDate: Timestamp
    var endDate: Timestamp
    var tasks: [EventTask]
    var urls: [String]
    var updatedAt: Timestamp?
}

struct EventLocation: Codable {
    var address: String
    var category: String
    var latitude: Double
    var longitude: Double
    var name: String
}

struct EventTask: Codable, Identifiable {
    var id: String = UUID().uuidString
    var title: String
}
