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
    @State private var isImagePickerPresented = false
    @State private var groupImage: Image? = Image("defaultimg")
    let groupCode: String

    // Explicit initializer for EditGroupView
    init(groupName: String, description: String, groupCode: String) {
        _groupName = State(initialValue: groupName)
        _description = State(initialValue: description)
        self.groupCode = groupCode
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ZStack(alignment: .bottomTrailing) {
                    groupImage?
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .background(Circle().fill(Color("CustomBlue")))
                        .foregroundColor(.white)
                }
                .padding(.top, 50)

                TextField("Group Name", text: $groupName)
                    .padding()
                    .cornerRadius(10)
                    .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray3), lineWidth: 2)
                        )
                    .padding(.horizontal, 20)

                TextField("Description (optional)", text: $description)
                    .padding()
                    .cornerRadius(10)
                    .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray3), lineWidth: 2)
                        )
                    .padding(.horizontal, 20)

                Button(action: {
                    saveGroupDetails()
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

                Spacer()
            }
            .navigationTitle("Edit Group")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $isImagePickerPresented) {
            // Implement image picker here
        }
    }

    private func saveGroupDetails() {
        let db = Firestore.firestore()

        // Update the Firestore group document
        db.collection("groups").document(groupCode).updateData([
            "groupName": groupName,
            "description": description // Assuming 'description' is a field in Firestore
        ]) { error in
            if let error = error {
                print("Error updating group: \(error.localizedDescription)")
            } else {
                print("Group updated successfully!")
            }
        }
    }
}

struct EditGroupView_Previews: PreviewProvider {
    static var previews: some View {
        EditGroupView(groupName: "Sample Group", description: "This is a sample group", groupCode: "sample123")
    }
}


