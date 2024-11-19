//
//  FirebaseGroupViewModel.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-19.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class FirebaseGroupViewModel: ObservableObject {
    @Published var groups: [UserGroup] = []
    private var db = Firestore.firestore()
    
    func fetchUserGroups() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        db.collection("users").document(currentUser.uid).getDocument { [weak self] document, error in
            if let error = error {
                print("Error fetching user: \(error)")
                return
            }
            
            guard let userData = document?.data(),
                  let groupCodes = userData["groups"] as? [String] else {
                self?.groups = [] // Ensure groups is empty if no data
                return
            }
            
            self?.fetchGroups(withCodes: groupCodes)
        }
    }
    
    private func fetchGroups(withCodes groupCodes: [String]) {
        DispatchQueue.main.async { self.groups = [] } // Reset groups before fetching
        
        if groupCodes.isEmpty { return }
        
        for groupCode in groupCodes {
            db.collection("groups")
                .whereField("groupCode", isEqualTo: groupCode)
                .getDocuments { [weak self] snapshot, error in
                    if let error = error {
                        print("Error fetching groups: \(error)")
                        return
                    }
                    
                    guard let documents = snapshot?.documents else { return }
                    
                    for document in documents {
                        let data = document.data()
                        
                        let group = UserGroup(
                            id: document.documentID,
                            groupName: data["groupName"] as? String ?? "",
                            groupCode: data["groupCode"] as? String ?? "",
                            description: data["description"] as? String ?? "",
                            members: data["members"] as? [String] ?? [],
                            createdBy: data["createdBy"] as? String ?? "",
                            profileImageURL: data["profileImageURL"] as? String
                        )
                        
                        DispatchQueue.main.async {
                            self?.groups.append(group)
                        }
                    }
                }
        }
    }
    
    func leaveGroup(group: UserGroup) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let userRef = db.collection("users").document(currentUser.uid)
        userRef.updateData(["groups": FieldValue.arrayRemove([group.groupCode])])
        
        let groupRef = db.collection("groups").document(group.id)
        groupRef.updateData(["members": FieldValue.arrayRemove([currentUser.uid])])
        
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            DispatchQueue.main.async {
                self.groups.remove(at: index)
            }
        }
    }
}

