//
//  EditGroupView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-04.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import PhotosUI

struct EditGroupView: View {
    @State private var groupName: String
    @State private var description: String
    @State private var isLoading = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var profileImageURL: String?
    @State private var showError = false
    @State private var errorMessage = ""
    
    @Environment(\.presentationMode) var presentationMode
    
    let groupCode: String
    
    init(groupName: String, description: String, groupCode: String, profileImageURL: String) {
        _groupName = State(initialValue: groupName)
        _description = State(initialValue: description)
        _profileImageURL = State(initialValue: profileImageURL)
        self.groupCode = groupCode
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 150, height: 150)
                    
                    // Selected Image or Default Placeholder
                    if let imageData = selectedImageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                    } else if let profileURL = profileImageURL,
                              !profileURL.isEmpty {
                        AsyncImage(url: URL(string: profileURL)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .clipShape(Circle())
                            case .failure(_):
                                Image("defaultimg")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .clipShape(Circle())
                            default:
                                ProgressView()
                                    .frame(width: 150, height: 150)
                            }
                        }
                    } else {
                        Image("defaultimg")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                    }
                    
                    // Photos Picker for Image Selection
                    PhotosPicker(selection: $selectedItem,
                                 matching: .images) {
                        Image(systemName: "camera.fill")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }.onChange(of: selectedItem) { newItem in
                        if let newItem = newItem {
                            newItem.loadTransferable(type: Data.self) { result in
                                switch result {
                                case .success(let data):
                                    if let data = data {
                                        DispatchQueue.main.async {
                                            selectedImageData = data
                                        }
                                    }
                                case .failure(let error):
                                    print("Error loading image: \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                    .frame(width: 40, height: 40)
                    .offset(x: -10, y: -10)
                }
                .frame(width: 150, height: 150)
                
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
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func updateGroupDetails() {
        isLoading = true
        
        if let imageData = selectedImageData {
            uploadImage { imageURL in
                var updateData: [String: Any] = [
                    "groupName": groupName,
                    "description": description,
                    "updatedAt": FieldValue.serverTimestamp()
                ]
                
                if let imageURL = imageURL {
                    updateData["profileImageURL"] = imageURL
                }
                
                updateFirestoreGroupData(updateData)
            }
        } else {
            let updateData: [String: Any] = [
                "groupName": groupName,
                "description": description,
                "updatedAt": FieldValue.serverTimestamp()
            ]
            updateFirestoreGroupData(updateData)
        }
    }
    
    private func updateFirestoreGroupData(_ data: [String: Any]) {
        let db = Firestore.firestore()
        db.collection("groups").whereField("groupCode", isEqualTo: groupCode).getDocuments { snapshot, error in
            if let error = error {
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = "Error finding group: \(error.localizedDescription)"
                    showError = true
                }
                return
            }
            
            guard let document = snapshot?.documents.first else {
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = "Group not found"
                    showError = true
                }
                return
            }
            
            // Update the document with the new data
            document.reference.updateData(data) { error in
                DispatchQueue.main.async {
                    isLoading = false
                    
                    if let error = error {
                        errorMessage = "Error updating group: \(error.localizedDescription)"
                        showError = true
                    } else {
                        // Successfully updated
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func uploadImage(completion: @escaping (String?) -> Void) {
        guard let imageData = selectedImageData else {
            completion(nil)
            return
        }
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("group_images/\(groupCode)_\(UUID().uuidString).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Compress image
        guard let compressedImageData = UIImage(data: imageData)?.jpegData(compressionQuality: 0.5) else {
            completion(nil)
            return
        }
        
        imageRef.putData(compressedImageData, metadata: metadata) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                completion(url?.absoluteString)
            }
        }
    }
}

struct EditGroupView_Previews: PreviewProvider {
    static var previews: some View {
        EditGroupView(groupName: "Sample Group", description: "This is a sample group", groupCode: "2F9ED5F4", profileImageURL: "Sample Image")
    }
}




