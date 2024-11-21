//
//  Task.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-19.
//

import Foundation

struct Task: Identifiable {
    let id = UUID()
    var person: TeamMember
    var assignment: String
}
