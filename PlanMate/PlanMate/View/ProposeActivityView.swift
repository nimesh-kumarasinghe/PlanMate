//
//  ProposeActivityView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Foundation

struct ProposeActivityView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var activityName: String = ""
    @State private var selectedMembers: Set<GroupMember> = []
    @State private var showLocationSearch = false
    @State private var selectedLocations: [LocationData] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    let groupId: String
    let groupName: String
    let groupMembers: [GroupMember]
    
    private let db = Firestore.firestore()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer().frame(height: 1)
                
                TextField("Activity name", text: $activityName)
                    .padding()
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray3), lineWidth: 2)
                    )
                    .padding(.horizontal, 20)
                
                // Locations Section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Locations (\(selectedLocations.count))")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            showLocationSearch = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Color("CustomBlue"))
                        }
                    }
                    .padding(.horizontal)
                    
                    if !selectedLocations.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(selectedLocations) { location in
                                    LocationChip(
                                        location: location,
                                        onRemove: { removeLocation(location) }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        Text("Add locations for the activity")
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }
                }
                
                // Group Members Section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Group Members (\(groupMembers.count))")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            if selectedMembers.count == groupMembers.count {
                                selectedMembers.removeAll()
                            } else {
                                selectedMembers = Set(groupMembers)
                            }
                        }) {
                            HStack {
                                Text("Select all")
                                Image(systemName: selectedMembers.count == groupMembers.count ? "checkmark.square" : "square")
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    ForEach(groupMembers) { member in
                        Button(action: {
                            if selectedMembers.contains(member) {
                                selectedMembers.remove(member)
                            } else {
                                selectedMembers.insert(member)
                            }
                        }) {
                            HStack {
                                Image(systemName: selectedMembers.contains(member) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedMembers.contains(member) ? Color("CustomBlue") : .gray)
                                
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.gray)
                                
                                Text(member.name)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                        }
                        Divider()
                            .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                Button(action: saveActivity) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Save")
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("CustomBlue"))
                .cornerRadius(50)
                .padding(.horizontal, 40)
                .disabled(isLoading || activityName.isEmpty || selectedLocations.isEmpty || selectedMembers.isEmpty)
            }
            .navigationBarTitle("Propose an Activity", displayMode: .inline)
            .alert("Error", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Text(errorMessage ?? "")
                Button("OK") {
                    errorMessage = nil
                }
            }
            .sheet(isPresented: $showLocationSearch) {
                LocationSearchView(onLocationSelected: { location in
                    addLocation(location)
                    showLocationSearch = false
                })
            }
        }
    }
    
    private func addLocation(_ location: LocationData) {
        selectedLocations.append(location)
    }
    
    private func removeLocation(_ location: LocationData) {
        selectedLocations.removeAll { $0.id == location.id }
    }
    
    private func saveActivity() {
        guard !selectedLocations.isEmpty else { return }
        
        isLoading = true
        
        // Create locations array
        let locations = selectedLocations.map { location -> [String: Any] in
            return [
                "name": location.name,
                "address": location.address,
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude
            ]
        }
        
        // Get participant UIDs (including the creator)
        let participantUIDs = Array(selectedMembers).map { $0.uid }
        
        // Create activity data
        let activityData: [String: Any] = [
            "groupId": groupId,  // Assuming groupId is the groupCode now
            "groupName": groupName,
            "title": activityName,
            "locations": locations,
            "participants": participantUIDs,
            "participantNames": Array(selectedMembers).map { $0.name },
            "createdAt": Timestamp(),
            "status": "pending"
        ]
        
        // Add to proposeActivities collection
        let activityRef = db.collection("proposeActivities").document()
        
        activityRef.setData(activityData) { error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
                return
            }
            
            // Notification message for this activity
            let notificationMessage = "\(self.activityName) has been created and you are a participant. Check it out and submit your vote."
            let notificationTitle = "New Activity Proposed!"
            
            // Create a batch for multiple operations
            let batch = db.batch()
            
            // Find the group using the groupCode (groupId in this case)
            let groupQuery = db.collection("groups").whereField("groupCode", isEqualTo: self.groupId)
            groupQuery.getDocuments { querySnapshot, error in
                if let error = error {
                    DispatchQueue.main.async {
                        errorMessage = error.localizedDescription
                        isLoading = false
                    }
                    return
                }
                
                guard let groupDocument = querySnapshot?.documents.first else {
                    DispatchQueue.main.async {
                        errorMessage = "Group not found"
                        isLoading = false
                    }
                    return
                }
                
                // Update the group's proposeActivities array
                let groupRef = groupDocument.reference
                batch.updateData([
                    "proposeActivities": FieldValue.arrayUnion([activityRef.documentID])
                ], forDocument: groupRef)
                
                // Update each user proposeActivities array in users collection and add notifications
                for participantUID in participantUIDs {
                    let userRef = db.collection("users").document(participantUID)
                    
                    // Add proposeActivity to user document
                    batch.updateData([
                        "proposeActivities": FieldValue.arrayUnion([activityRef.documentID])
                    ], forDocument: userRef)
                    
                    
                    // exculding the creator and saving for others
                    if participantUID != Auth.auth().currentUser?.uid {
                        // Add the notification only if the user is not the creator
                        batch.updateData([
                            "notifications": FieldValue.arrayUnion([
                                [
                                    "id": UUID().uuidString,
                                    "message": notificationMessage,
                                    "activityId": activityRef.documentID,
                                    "title": notificationTitle,
                                    "timestamp": Timestamp(date: Date()),
                                    "type": "PA" // Type indicates "Proposed Activity"
                                ]
                            ])
                        ], forDocument: userRef)
                    }
                }
                
                // Commit the batch
                batch.commit { batchError in
                    DispatchQueue.main.async {
                        isLoading = false
                        if let batchError = batchError {
                            errorMessage = batchError.localizedDescription
                        } else {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    
    
}

// Location Chip View
struct LocationChip: View {
    let location: LocationData
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(location.name)
                .lineLimit(1)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(16)
    }
}

// Preview Provider
struct ProposeActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ProposeActivityView(
            groupId: "roXJFgmYmKwZF9lshpA5",
            groupName: "Friends",
            groupMembers: [
                GroupMember(name: "nim", uid: "uid1"),
                GroupMember(name: "dil", uid: "uid2")
            ]
        )
    }
}
