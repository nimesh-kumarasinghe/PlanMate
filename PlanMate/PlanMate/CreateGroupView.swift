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
    @State private var groupImage: Image? = Image(systemName: "person.fill")
    // Default icon

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Group Image with Edit Icon
                ZStack(alignment: .bottomTrailing) {
                    groupImage?
                        .resizable() // Make the image resizable
                        .aspectRatio(contentMode: .fill) // Maintain aspect ratio
                        .frame(width: 150, height: 150) // Increased size of the image
                        .clipShape(Circle())
                        .background(Circle().fill(Color("CustomBlue")))
                        .foregroundColor(.white)

                    // Edit Icon
                    Button(action: {
                        isImagePickerPresented = true
                    }) {
                        Image(systemName: "pencil.circle.fill")
                            .foregroundColor(.blue)
                            .background(Circle().fill(Color.white))
                            .frame(width: 60, height: 30) // Decreased width of the button
                            .offset(x: 1, y: 1)
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
                        .background(Color("CustomBlue"))
                        .cornerRadius(50)
                        .padding(.horizontal, 40)
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
