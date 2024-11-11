//
//  EditGroupView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-04.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct EditGroupView: View {
    @State private var groupName: String
    @State private var description: String
    @State private var isLoading = false
    let groupCode: String
    
    init(groupName: String, description: String, groupCode: String) {
        _groupName = State(initialValue: groupName)
        _description = State(initialValue: description)
        self.groupCode = groupCode
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                Image("defaultimg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .background(Circle().fill(Color("CustomBlue")))
                    .padding(.top, 50)
                
                TextField("Group Name", text: $groupName)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray3), lineWidth: 2)
                    )
                    .padding(.horizontal, 20)
                
                TextField("Description (optional)", text: $description)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray3), lineWidth: 2)
                    )
                    .padding(.horizontal, 20)
                
                if isLoading {
                    ProgressView()
                        .padding(.top, 20)
                } else {
                    Button(action: {
                        updateGroupDetails()
                    }) {
                        Text("Save")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("CustomBlue"))
                            .cornerRadius(50)
                            .padding(.horizontal, 40)
                    }
                    .padding(.top, 20)
                }
                
                Spacer()
            }
            .navigationTitle("Edit Group")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func updateGroupDetails() {
        isLoading = true
        let db = Firestore.firestore()
        
        // Query to find the document based on `groupCode`
        db.collection("groups").whereField("groupCode", isEqualTo: groupCode).getDocuments { snapshot, error in
            if let error = error {
                isLoading = false
                print("Error finding group: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents, let document = documents.first else {
                isLoading = false
                print("No group found with groupCode: \(groupCode)")
                return
            }
            
            // Update the document found with the queried groupCode
            document.reference.updateData([
                "groupName": groupName,
                "description": description
            ]) { error in
                isLoading = false
                if let error = error {
                    print("Error updating group: \(error.localizedDescription)")
                } else {
                    print("Group updated successfully!")
                }
            }
        }
    }
}

struct EditGroupView_Previews: PreviewProvider {
    static var previews: some View {
        EditGroupView(groupName: "Sample Group", description: "This is a sample group", groupCode: "2F9ED5F4")
    }
}



