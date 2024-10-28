//
//  CreateGroupView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI

struct CreateGroupView: View {
    @State private var groupName: String = ""
    @State private var description: String = ""
    @State private var isImagePickerPresented = false
    @State private var groupImage: Image? = Image(systemName: "person.3.fill") // Default icon

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Group Image with Edit Icon
                ZStack(alignment: .bottomTrailing) {
                    groupImage?
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .background(Circle().fill(Color.blue.opacity(0.1)))
                    
                    // Edit Icon
                    Button(action: {
                        isImagePickerPresented = true
                    }) {
                        Image(systemName: "pencil.circle.fill")
                            .foregroundColor(.blue)
                            .background(Circle().fill(Color.white))
                            .frame(width: 24, height: 24)
                            .offset(x: 8, y: 8)
                    }
                }
                .padding(.top, 50)

                // Group Name TextField
                TextField("Group Name", text: $groupName)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)

                // Description TextField
                TextField("Description (optional)", text: $description)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)

                // Create Button
                Button(action: {
                    // Add create action here
                }) {
                    Text("Create")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .navigationTitle("Create a Group")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $isImagePickerPresented) {
            // Implement image picker here
        }
    }
}

struct CreateGroupView_Previews: PreviewProvider {
    static var previews: some View {
        CreateGroupView()
    }
}
