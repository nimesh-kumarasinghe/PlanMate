//
//  KeychainManager.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-16.
//

import Security
import Foundation

class KeychainManager {
    enum KeychainError: Error {
        case duplicateEntry
        case unknown(OSStatus)
        case itemNotFound
    }
    
    static let shared = KeychainManager()
    private init() {}
    
    // Save credentials
    func saveCredentials(email: String, password: String) throws {
        // First remove any existing credentials
        try deleteCredentials()
        
        let credentials = "\(email):\(password)".data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "PlanMateCredentials",
            kSecValueData as String: credentials,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }
    
    // Retrieve credentials
    func retrieveCredentials() throws -> (email: String, password: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "PlanMateCredentials",
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let credentials = String(data: data, encoding: .utf8) else {
            throw KeychainError.itemNotFound
        }
        
        let components = credentials.split(separator: ":")
        guard components.count == 2 else {
            throw KeychainError.unknown(errSecInvalidData)
        }
        
        return (String(components[0]), String(components[1]))
    }
    
    // Delete credentials
    func deleteCredentials() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "PlanMateCredentials"
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unknown(status)
        }
    }
}
