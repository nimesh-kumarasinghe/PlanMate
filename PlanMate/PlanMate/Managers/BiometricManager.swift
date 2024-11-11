//
//  BiometricManager.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-10.
//

import LocalAuthentication
import SwiftUI
import Firebase
import FirebaseAuth

// BiometricManager class to handle Face ID operations
class BiometricManager: ObservableObject {
    @Published var isEnabled = false
    private let context = LAContext()
    
    func checkBiometricAvailability() -> Bool {
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    func authenticateWithBiometrics(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                 localizedReason: "Log in with Face ID") { success, error in
                DispatchQueue.main.async {
                    completion(success)
                }
            }
        } else {
            completion(false)
        }
    }
}
