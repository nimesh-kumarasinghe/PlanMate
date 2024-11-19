//
//  TeamMember.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-19.
//

import Foundation

struct TeamMember: Identifiable, Hashable {
    let id: String
    let name: String
    var isSelected: Bool = false
}
