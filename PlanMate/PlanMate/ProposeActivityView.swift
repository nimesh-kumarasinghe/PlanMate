//
//  ProposeActivityView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI
import FirebaseFirestore

struct GroupMember: Identifiable, Hashable {
    let id = UUID()
    let name: String
}

struct ProposeActivityView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var activityName: String = ""
    @State private var selectedMembers: Set<GroupMember> = []
    @State private var showLocationSearch = false
    @State private var selectedLocation: LocationData?
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
                    .padding(.horizontal,20)
                
                Button(action: {
                    showLocationSearch = true
                }) {
                    HStack {
                        Text("Select Locations")
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(50)
                }
                .padding(.horizontal)
                .sheet(isPresented: $showLocationSearch) {
                    LocationSearchView(onLocationSelected: { location in
                        selectedLocation = location
                        showLocationSearch = false
                    })
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
                    
                    // Member List
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
                .disabled(isLoading || activityName.isEmpty || selectedLocation == nil || selectedMembers.isEmpty)
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
        }
    }
    
    private func saveActivity() {
        guard let location = selectedLocation else { return }
        
        isLoading = true
        
        let activityData: [String: Any] = [
            "groupId": groupId,
            "groupName": groupName,
            "title": activityName,
            "location": [
                "name": location.name,
                "address": location.address,
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude
            ],
            "participants": Array(selectedMembers).map { $0.name },
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
            
            // Update the group's proposeActivities array
            let groupRef = db.collection("groups").document(groupId)
            groupRef.updateData([
                "proposeActivities": FieldValue.arrayUnion([activityRef.documentID])
            ]) { error in
                DispatchQueue.main.async {
                    isLoading = false
                    if let error = error {
                        errorMessage = error.localizedDescription
                    } else {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Preview Provider
struct ProposeActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ProposeActivityView(
            groupId: "roXJFgmYmKwZF9lshpA5",
            groupName: "Bio Friends",
            groupMembers: [
                GroupMember(name: "John"),
                GroupMember(name: "Jane")
            ]
        )
    }
}
