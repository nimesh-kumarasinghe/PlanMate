//
//  ActivityData.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-19.
//

import Foundation

struct ActivityData: Identifiable {
    let id: String
    let title: String
    let from: String
    let groupId: String
    let groupName: String
    
    init(id: String = UUID().uuidString, title: String, from: String, groupId: String = "", groupName: String = "") {
        self.id = id
        self.title = title
        self.from = from
        self.groupId = groupId
        self.groupName = groupName
    }
}
