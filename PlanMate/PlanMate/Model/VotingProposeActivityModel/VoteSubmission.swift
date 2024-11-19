//
//  VoteSubmission.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-19.
//

import Foundation

struct VoteSubmission: Identifiable {
    let id: String
    let userId: String
    let userName: String
    let proposeActivityId: String
    let fromDate: Date
    let toDate: Date
    let comment: String
    let selectedLocation: String
    let submittedAt: Date
}
