//
//  ProposeActivity.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-19.
//

import Foundation

struct ProposeActivity: Identifiable {
    let id: String
    let title: String
    let groupId: String
    let groupName: String
    let locations: [ProposeLocation]
    let participants: [String]
    let participantNames: [String]
    let status: String
    let createdAt: Date
}
