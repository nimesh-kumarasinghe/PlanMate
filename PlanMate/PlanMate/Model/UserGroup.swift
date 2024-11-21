//
//  UserGroup.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-19.
//
import Foundation

struct User: Codable {
    let email: String
    let name: String
    let groups: [String]
    let uid: String
}

struct UserGroup: Identifiable {
    let id: String
    let groupName: String
    let groupCode: String
    let description: String
    let members: [String]
    let createdBy: String
    let profileImageURL: String?
    
    var memberCount: Int {
        members.count
    }
}

