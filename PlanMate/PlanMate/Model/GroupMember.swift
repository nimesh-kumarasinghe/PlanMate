//
//  GroupMember.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-19.
//

import Foundation

struct GroupMember: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let uid: String
}
