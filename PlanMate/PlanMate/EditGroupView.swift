//
//  EditGroupView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-04.
//

import SwiftUI

struct EditGroupView: View {
    @State private var groupName: String = ""
    @State private var description: String = ""
    @State private var isImagePickerPresented = false
    @State private var groupImage: Image? = Image("defaultimg") 

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Group Image with Edit Icon
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

                // Group Name TextField
                TextField("Group Name", text: $groupName)
                    .padding()
                    .cornerRadius(10)
                    .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray3), lineWidth: 2)
                        )
                    .padding(.horizontal, 20)

                // Description TextField
                TextField("Description (optional)", text: $description)
                    .padding()
                    .cornerRadius(10)
                    .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray3), lineWidth: 2)
                        )
                    .padding(.horizontal, 20)

                // Create Button
                Button(action: {
                    // Add create action here
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
}

struct EditGroupView_Previews: PreviewProvider {
    static var previews: some View {
        EditGroupView()
    }
}

