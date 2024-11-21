//
//  ActivityChatViewModel.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-19.
//

import Foundation
import SwiftUI
import FirebaseFirestore

class ActivityChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    func startListening(activityId: String) {
        listener?.remove()
        
        listener = db.collection("activities")
            .document(activityId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                self.messages = querySnapshot?.documents.compactMap { document in
                    let data = document.data()
                    return ChatMessage(
                        id: document.documentID,
                        text: data["text"] as? String ?? "",
                        senderId: data["senderId"] as? String ?? "",
                        senderName: data["senderName"] as? String ?? "",
                        timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    )
                } ?? []
            }
    }
    
    func sendMessage(activityId: String, text: String, senderId: String, senderName: String) {
        let message = [
            "text": text,
            "senderId": senderId,
            "senderName": senderName,
            "timestamp": Timestamp(date: Date())
        ] as [String: Any]
        
        db.collection("activities")
            .document(activityId)
            .collection("messages")
            .addDocument(data: message) { [weak self] error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                }
            }
    }
    
    func stopListening() {
        listener?.remove()
    }
}
