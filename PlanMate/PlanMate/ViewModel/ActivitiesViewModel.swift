//
//  ActivitiesViewModel.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-19.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth


class ActivitiesViewModel: ObservableObject {
    @Published var activities: [GroupEvent] = []
    @Published var userActivities: [String] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    
    init() {
        fetchUserActivities()
    }
    
    func fetchUserActivities() {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "No user logged in"
            return
        }
        
        isLoading = true
        
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            if let data = snapshot?.data(),
               let activities = data["activities"] as? [String] {
                self.userActivities = activities
                print("Found \(activities.count) activity IDs for user")
            } else {
                self.errorMessage = "No activities found"
            }
        }
    }
    
    func fetchActivities(for date: Date) {
        guard !userActivities.isEmpty else {
            self.errorMessage = "No activities available"
            return
        }
        
        isLoading = true
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        db.collection("activities")
            .whereField(FieldPath.documentID(), in: userActivities)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                let filteredActivities = snapshot?.documents.compactMap { document -> GroupEvent? in
                    do {
                        var activity = try document.data(as: GroupEvent.self)
                        activity.id = document.documentID
                        
                        let activityDate = activity.startDate.dateValue()
                        if calendar.isDate(activityDate, inSameDayAs: date) {
                            return activity
                        }
                        return nil
                    } catch {
                        print("Error decoding activity: \(error)")
                        return nil
                    }
                } ?? []
                
                DispatchQueue.main.async {
                    self.activities = filteredActivities
                }
            }
    }
    
    func hasActivities(for date: Date) -> Bool {
        let calendar = Calendar.current
        return activities.contains { activity in
            calendar.isDate(activity.startDate.dateValue(), inSameDayAs: date)
        }
    }
}
