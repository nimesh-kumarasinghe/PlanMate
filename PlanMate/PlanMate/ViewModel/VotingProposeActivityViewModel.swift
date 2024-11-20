//
//  VotingProposeActivityViewModel.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-19.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Foundation

class VotingProposeActivityViewModel: ObservableObject {
    @Published var proposeActivity: ProposeActivity?
    @Published var voteSubmissions: [VoteSubmission] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var userHasSubmitted = false
    @Published var userSubmission: VoteSubmission?
    @Published var showVoteReminders: Bool = false
    @AppStorage("user_name") private var userName: String = ""
    
    private var db = Firestore.firestore()
    
    // fetch user notification preferences
    private func fetchUserNotificationPreferences() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(currentUserId).getDocument { [weak self] document, error in
            if let error = error {
                print("Error fetching user preferences: \(error)")
                return
            }
            
            if let data = document?.data(),
               let showReminders = data["showVoteReminders"] as? Bool {
                DispatchQueue.main.async {
                    self?.showVoteReminders = showReminders
                }
            }
        }
    }
    
    func fetchProposeActivity(id: String) {
        isLoading = true
        
        fetchUserNotificationPreferences()
        
        db.collection("proposeActivities").document(id).getDocument { [weak self] document, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.showError = true
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let document = document,
                      let data = document.data() else {
                    self?.showError = true
                    self?.errorMessage = "Activity not found"
                    return
                }
                
                // Parse locations array
                let locations = (data["locations"] as? [[String: Any]])?.map { locationData in
                    ProposeLocation(
                        name: locationData["name"] as? String ?? "",
                        address: locationData["address"] as? String ?? "",
                        latitude: locationData["latitude"] as? Double ?? 0.0,
                        longitude: locationData["longitude"] as? Double ?? 0.0
                    )
                } ?? []
                
                let proposeActivity = ProposeActivity(
                    id: document.documentID,
                    title: data["title"] as? String ?? "",
                    groupId: data["groupId"] as? String ?? "",
                    groupName: data["groupName"] as? String ?? "",
                    locations: locations,
                    participants: data["participants"] as? [String] ?? [],
                    participantNames: data["participantNames"] as? [String] ?? [],
                    status: data["status"] as? String ?? "",
                    createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                )
                
                self?.proposeActivity = proposeActivity
                
                // Only schedule notification if showVoteReminders is true
                if let strongSelf = self,
                                   !strongSelf.userHasSubmitted,
                   strongSelf.showVoteReminders {
                    NotificationManager.shared.scheduleVoteReminder(for: proposeActivity)
                }
                
                self?.fetchVoteSubmissions(proposeActivityId: document.documentID)
            }
        }
    }
    
    func fetchVoteSubmissions(proposeActivityId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("voteSubmissions")
            .whereField("proposeActivityId", isEqualTo: proposeActivityId)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching vote submissions: \(error)")
                    return
                }
                
                let submissions = snapshot?.documents.map { document -> VoteSubmission in
                    let data = document.data()
                    let submission = VoteSubmission(
                        id: document.documentID,
                        userId: data["userId"] as? String ?? "",
                        userName: data["userName"] as? String ?? "",
                        proposeActivityId: data["proposeActivityId"] as? String ?? "",
                        fromDate: (data["fromDate"] as? Timestamp)?.dateValue() ?? Date(),
                        toDate: (data["toDate"] as? Timestamp)?.dateValue() ?? Date(),
                        comment: data["comment"] as? String ?? "",
                        selectedLocation: data["selectedLocation"] as? String ?? "",
                        submittedAt: (data["submittedAt"] as? Timestamp)?.dateValue() ?? Date()
                    )
                    
                    // Check if this submission belongs to the current user
                    if submission.userId == currentUserId {
                        DispatchQueue.main.async {
                            self?.userHasSubmitted = true
                            self?.userSubmission = submission
                        }
                    }
                    
                    return submission
                } ?? []
                
                DispatchQueue.main.async {
                    self?.voteSubmissions = submissions.filter { $0.userId != currentUserId }
                }
            }
    }
    
    func submitVote(fromDate: Date, toDate: Date, comment: String, selectedLocation: String) {
        guard let currentUser = Auth.auth().currentUser,
              let proposeActivity = proposeActivity else {
            showError = true
            errorMessage = "Unable to submit vote"
            return
        }
        
        let submission = [
            "userId": currentUser.uid,
            "userName": userName,
            "proposeActivityId": proposeActivity.id,
            "fromDate": Timestamp(date: fromDate),
            "toDate": Timestamp(date: toDate),
            "comment": comment,
            "selectedLocation": selectedLocation,
            "submittedAt": Timestamp(date: Date())
        ] as [String : Any]
        
        db.collection("voteSubmissions").addDocument(data: submission) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError = true
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                self?.userHasSubmitted = true
                self?.userSubmission = VoteSubmission(
                    id: UUID().uuidString,
                    userId: currentUser.uid,
                    userName: self?.userName ?? "",
                    proposeActivityId: proposeActivity.id,
                    fromDate: fromDate,
                    toDate: toDate,
                    comment: comment,
                    selectedLocation: selectedLocation,
                    submittedAt: Date()
                )
                
                NotificationManager.shared.cancelVoteReminder(for: proposeActivity.id)
                
                // Refresh vote submissions after successful submission
                self?.fetchVoteSubmissions(proposeActivityId: proposeActivity.id)
            }
        }
    }
    
    func deleteSubmission() {
        guard let submissionId = userSubmission?.id else {
            showError = true
            errorMessage = "Cannot find submission to delete"
            return
        }
        
        isLoading = true
        db.collection("voteSubmissions").document(submissionId).delete { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.showError = true
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                // Reset user submission state
                self?.userHasSubmitted = false
                
                // Only schedule notification if showVoteReminders is true
                if let proposeActivity = self?.proposeActivity,
                   self?.showVoteReminders == true {
                    NotificationManager.shared.scheduleVoteReminder(for: proposeActivity)
                }
                
                self?.userSubmission = nil
                
                // Refresh submissions list
                if let proposeActivity = self?.proposeActivity {
                    self?.fetchVoteSubmissions(proposeActivityId: proposeActivity.id)
                }
            }
        }
    }
}
