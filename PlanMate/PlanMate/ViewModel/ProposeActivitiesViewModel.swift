//
//  ProposeActivitiesViewModel.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-19.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Foundation


class ProposeActivitiesViewModel: ObservableObject {
    @Published var activities: [ActivityData] = []
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    
    private var db = Firestore.firestore()
    private var activityListeners: [ListenerRegistration] = []
    
    func fetchUserActivities() {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "No user logged in"
            return
        }
        
        isLoading = true
        print("Fetching activities for user with ID: \(userId)")
        
        let userListener = db.collection("users").document(userId)
            .addSnapshotListener { [weak self] documentSnapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = "Error fetching user data: \(error.localizedDescription)"
                    self.isLoading = false
                    return
                }
                
                guard let document = documentSnapshot,
                      let proposeActivities = document.data()?["proposeActivities"] as? [String] else {
                    DispatchQueue.main.async {
                        self.activities.removeAll()
                        self.isLoading = false
                    }
                    return
                }
                
                let cleanActivityIds = proposeActivities.map { $0.trimmingCharacters(in: .whitespaces) }
                
                self.removeListeners()
                self.fetchProposeActivities(activityIds: cleanActivityIds)
            }
        
        activityListeners.append(userListener)
    }
    
    private func fetchProposeActivities(activityIds: [String]) {
        DispatchQueue.main.async {
            self.activities.removeAll()
        }
        
        if activityIds.isEmpty {
            self.isLoading = false
            return
        }
        
        for activityId in activityIds {
            let listener = db.collection("proposeActivities")
                .document(activityId)
                .addSnapshotListener { [weak self] documentSnapshot, error in
                    guard let self = self else { return }
                    
                    if let error = error {
                        print("Error fetching activity \(activityId): \(error.localizedDescription)")
                        return
                    }
                    
                    guard let document = documentSnapshot,
                          document.exists,
                          let data = document.data() else {
                        print("No document found for activity ID: \(activityId)")
                        return
                    }
                    
                    if let activity = self.parseActivityData(document: document, data: data) {
                        DispatchQueue.main.async {
                            if let index = self.activities.firstIndex(where: { $0.id == activity.id }) {
                                self.activities[index] = activity
                            } else {
                                self.activities.append(activity)
                            }
                        }
                    }
                }
            
            activityListeners.append(listener)
        }
        
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    private func parseActivityData(document: DocumentSnapshot, data: [String: Any]) -> ActivityData? {
        guard let title = data["title"] as? String,
              let groupId = data["groupId"] as? String,
              let groupName = data["groupName"] as? String else {
            return nil
        }
        
        return ActivityData(
            id: document.documentID,
            title: title,
            from: groupName,
            groupId: groupId,
            groupName: groupName
        )
    }
    
    private func removeListeners() {
        activityListeners.forEach { $0.remove() }
        activityListeners.removeAll()
    }
    
    func deleteActivity(activityId: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "No user logged in"
            return
        }
        
        let userRef = db.collection("users").document(userId)
        
        // Set loading state
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        userRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                self.errorMessage = "Error fetching user document: \(error.localizedDescription)"
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            guard let document = document,
                  var proposeActivities = document.data()?["proposeActivities"] as? [String] else {
                print("No proposeActivities found or document doesn't exist")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            // Remove the activity ID from the array
            proposeActivities.removeAll { $0.trimmingCharacters(in: .whitespaces) == activityId }
            
            // Update collection with the new array
            userRef.updateData([
                "proposeActivities": proposeActivities
            ]) { error in
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                
                if let error = error {
                    print("Error updating proposeActivities: \(error.localizedDescription)")
                    self.errorMessage = "Error updating proposeActivities: \(error.localizedDescription)"
                } else {
                    print("Successfully deleted activity with ID: \(activityId)")
                    // Remove the activity from local array immediately
                    DispatchQueue.main.async {
                        self.activities.removeAll { $0.id == activityId }
                    }
                }
            }
        }
    }
    
    deinit {
        removeListeners()
    }
}
