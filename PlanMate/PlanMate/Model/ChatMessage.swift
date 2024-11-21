//
//  ChatMessage.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-19.
//

import Foundation

struct ChatMessage: Identifiable, Equatable {
    let id: String
    let text: String
    let senderId: String
    let senderName: String
    let timestamp: Date
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    // Implement Equatable
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id &&
               lhs.text == rhs.text &&
               lhs.senderId == rhs.senderId &&
               lhs.senderName == rhs.senderName &&
               lhs.timestamp == rhs.timestamp
    }
}
