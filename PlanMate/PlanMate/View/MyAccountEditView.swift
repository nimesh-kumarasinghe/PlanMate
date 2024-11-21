//
//  MyAccountEditView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-12.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import PhotosUI

struct MyAccountEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var userName: String
    @State private var email: String
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var profileImageURL: String?
    
    let uid: String
    
    init(userName: String, email: String, uid: String, profileImageURL: String? = nil) {
        _userName = State(initialValue: userName)
        _email = State(initialValue: email)
        _profileImageURL = State(initialValue: profileImageURL)
        self.uid = uid
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Profile Picture Section
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 130, height: 130)
                    
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color.gray)
                        .frame(width: 60, height: 60)
                    
                    if let imageData = selectedImageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 130, height: 130)
                            .clipShape(Circle())
                    } else if let profileURL = profileImageURL,
                              !profileURL.isEmpty {
                        AsyncImage(url: URL(string: profileURL)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 130, height: 130)
                                    .clipShape(Circle())
                            case .failure(_):
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 90, height: 90)
                                    .foregroundColor(.white)
                            default:
                                ProgressView()
                                    .frame(width: 150, height: 150)
                            }
                        }
                    } else {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                            .foregroundColor(.white)
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
                    .offset(x: 40, y: 50)
                }
                .frame(width: 150, height: 150)
                
                TextField("Name", text: $userName)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray3), lineWidth: 2)
                    )
                    .padding(.horizontal, 20)
                
                TextField("Email", text: $email)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray3), lineWidth: 2)
                    )
                    .padding(.horizontal, 20)
                    .disabled(true)
                    .opacity(0.7)
                
                // Save Button Section
                if isLoading {
                    ProgressView()
                        .padding(.bottom, 40)
                } else {
                    Button(action: {
                        updateUserProfile()
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
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func updateUserProfile() {
        isLoading = true
        
        if let imageData = selectedImageData {
            uploadImage { imageURL in
                var updateData: [String: Any] = ["name": userName]
                
                if let imageURL = imageURL {
                    updateData["profileImageURL"] = imageURL
                }
                
                updateFirestoreData(updateData)
            }
        } else {
            updateFirestoreData(["name": userName])
        }
    }
    
    private func updateFirestoreData(_ data: [String: Any]) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).updateData(data) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Error updating profile: \(error.localizedDescription)"
                    self.showError = true
                    self.isLoading = false
                    return
                }
                
                UserDefaults.standard.set(self.userName, forKey: "user_name")
                self.isLoading = false
                self.dismiss()
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
        let imageRef = storageRef.child("profile_images/\(uid)_\(UUID().uuidString).jpg")
        
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
                
                if let downloadURL = url?.absoluteString {
                    completion(downloadURL)
                } else {
                    completion(nil)
                }
            }
        }
    }
}

struct MyAccountEditView_Previews: PreviewProvider {
    static var previews: some View {
        MyAccountEditView(
            userName: "Nimesh",
            email: "n@example.com",
            uid: "sampleUID",
            profileImageURL: nil
        )
    }
}
