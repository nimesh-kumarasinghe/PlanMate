//
//  ActivityViewModel.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-19.
//

import Foundation

class ActivityViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var locations: [LocationData] = []
    @Published var notes: [Note] = []
    @Published var urls: [String] = []
}
