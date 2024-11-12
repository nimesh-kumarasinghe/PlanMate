//
//  AppStateManager.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-12.
//
import SwiftUI

class AppStateManager: ObservableObject {
    @Published var hasCompletedOnboarding: Bool
    
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}
