//
//  GroupListView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// Model for User
struct User: Codable {
    let email: String
    let name: String
    let groups: [String]
    let uid: String
}

// Model for Group
struct UserGroup: Identifiable {
    let id: String
    let groupName: String
    let groupCode: String
    let description: String
    let members: [String]
    let createdBy: String
    
    var memberCount: Int {
        members.count
    }
}

// ViewModel to handle Firebase operations
class FirebaseGroupViewModel: ObservableObject {
    @Published var groups: [UserGroup] = []
    private var db = Firestore.firestore()
    
    func fetchUserGroups() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        // First fetch user document to get group codes
        db.collection("users").document(currentUser.uid).getDocument { [weak self] document, error in
            if let error = error {
                print("Error fetching user: \(error)")
                return
            }
            
            guard let userData = document?.data(),
                  let groupCodes = userData["groups"] as? [String] else {
                return
            }
            
            // Then fetch all groups that match these codes
            self?.fetchGroups(withCodes: groupCodes)
        }
    }
    
    private func fetchGroups(withCodes groupCodes: [String]) {
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
                            createdBy: data["createdBy"] as? String ?? ""
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
        userRef.updateData([
            "groups": FieldValue.arrayRemove([group.groupCode])
        ])
        let groupRef = db.collection("groups").document(group.id)
        groupRef.updateData([
            "members": FieldValue.arrayRemove([currentUser.uid])
        ])
        
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            DispatchQueue.main.async {
                self.groups.remove(at: index)
            }
        }
    }
}

// Group list view
struct GroupListView: View {
    @StateObject private var viewModel = FirebaseGroupViewModel()
    @State private var showAlert = false
    @State private var groupToLeave: UserGroup?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.groups) { group in
                    HStack {
                        Image("defaultimg")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(group.memberCount > 6 ? .blue : .green)
                        VStack(alignment: .leading) {
                            Text(group.groupName)
                                .font(.headline)
                            Text("\(group.memberCount) members")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            groupToLeave = group
                            showAlert = true
                        } label: {
                            Text("Leave")
                        }
                    }
                }
            }
            .alert("Leave Group", isPresented: $showAlert, presenting: groupToLeave) { group in
                Button("Leave", role: .destructive) {
                    viewModel.leaveGroup(group: group)
                }
                Button("Cancel", role: .cancel) {}
            } message: { group in
                Text("Are you sure you want to leave \(group.groupName)?")
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.white)
        }
        .onAppear {
            viewModel.fetchUserGroups()
        }
    }
}

struct GroupsView_Previews: PreviewProvider {
    static var previews: some View {
        GroupListView()
    }
}
