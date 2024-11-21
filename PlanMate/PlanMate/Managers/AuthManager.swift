//
//  AuthManager.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-21.
//

import FirebaseAuth
import SwiftUI
import Firebase

class AuthManager {
    static let shared = AuthManager()
    
    private init() {
        // auth state listener
        Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            self?.handleAuthStateChange(user: firebaseUser)
        }
    }
    
    private func handleAuthStateChange(user: FirebaseAuth.User?) {
        if let userId = user?.uid {
            // start notification listener when logged
            NotificationManager.shared.startNotificationListener(for: userId)
        } else {
            // stop notification listener when logged out
            NotificationManager.shared.stopNotificationListener()
        }
    }
}
