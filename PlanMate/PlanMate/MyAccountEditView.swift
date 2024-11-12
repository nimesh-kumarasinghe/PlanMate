//
//  MyAccountEditView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-12.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct MyAccountEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var userName: String
    @State private var email: String
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    let uid: String
    
    init(userName: String, email: String, uid: String) {
        _userName = State(initialValue: userName)
        _email = State(initialValue: email)
        self.uid = uid
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color("CustomBlue"))
                        .frame(width: 130, height: 130)
                    
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                        .foregroundColor(.white)
                }
                .padding(.top, 30)
                .padding(.bottom, 30)
                
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
                    .disabled(true) // Email field is locked
                    .opacity(0.7)
                
                if isLoading {
                    ProgressView()
                        .padding(.top, 20)
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
        let db = Firestore.firestore()
        
        db.collection("users").document(uid).updateData([
            "name": userName
        ]) { error in
            if let error = error {
                errorMessage = "Error updating profile: \(error.localizedDescription)"
                showError = true
                isLoading = false
                return
            }
            
            UserDefaults.standard.set(userName, forKey: "user_name")
            
            isLoading = false
            dismiss()
        }
    }
}

struct MyAccountEditView_Previews: PreviewProvider {
    static var previews: some View {
        MyAccountEditView(userName: "John Doe", email: "john@example.com", uid: "sampleUID")
    }
}
