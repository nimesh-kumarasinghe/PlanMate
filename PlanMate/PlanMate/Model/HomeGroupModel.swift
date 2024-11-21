//
//  HomeGroupModel.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-19.
//

import Foundation

struct HomeGroupModel: Identifiable {
    let id: String
    let groupName: String
    let description: String
    let groupCode: String
    let createdBy: String
    let members: [String]
    let profileImageURL: String?
}
