//
//  JoinGroupView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct JoinGroupView: View {
    @State private var groupCode: String = ""
    @State private var isLoading: Bool = false
    @State private var showSuccessAlert: Bool = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            // Navigation header
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                        Text("Back")
                            .foregroundColor(.blue)
                    }
                }
                Spacer()
            }
            .padding(.leading)
            
            // Main content
            VStack(spacing: 25) {
                Text("Enter group code or scan a\nQR code to join")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 20, weight: .medium))
                
                if !isLoading {
                    TextField("Enter group code", text: $groupCode)
                        .padding()
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray3), lineWidth: 2)
                        )
                        .padding(.horizontal, 20)
                    
                    Button(action: {
                        joinGroup()
                    }) {
                        Text("Join")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color("CustomBlue"))
                            .cornerRadius(50)
                    }
                    .padding(.horizontal, 60)
                    
                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.3))
                        
                        Text("or")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.3))
                    }
                    .padding(.horizontal, 20)
                    
                    Button(action: {
                        // Scan QR code action
                    }) {
                        HStack {
                            Image(systemName: "qrcode.viewfinder")
                            Text("Scan QR Code")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color("CustomBlue"))
                        .cornerRadius(50)
                    }
                    .padding(.horizontal, 20)
                }
                
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .navigationBarHidden(true)
        .overlay(
            isLoading ? AnyView(LoadingScreen()) : AnyView(EmptyView())
        )
        .alert(isPresented: $showSuccessAlert) {
            Alert(
                title: Text("Success"),
                message: Text("You have successfully joined the group."),
                dismissButton: .default(Text("OK")) {
                    // Navigate to MainHomeView after success
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .toolbar(.hidden, for: .tabBar)
    }
    
    // Function to handle the group joining process
    func joinGroup() {
        guard !groupCode.isEmpty else {
            return
        }
        
        isLoading = true
        
        // Get reference to Firebase Firestore
        let db = Firestore.firestore()
        let groupsRef = db.collection("groups")
        let usersRef = db.collection("users")
        let currentUserUID = Auth.auth().currentUser?.uid
        
        // Find group by group code
        groupsRef.whereField("groupCode", isEqualTo: groupCode)
            .getDocuments { snapshot, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    isLoading = false
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    self.errorMessage = "Group not found"
                    isLoading = false
                    return
                }
                
                // Get group document ID and add current user's UID to members array
                let groupID = document.documentID
                groupsRef.document(groupID).updateData([
                    "members": FieldValue.arrayUnion([currentUserUID!])
                ]) { error in
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        isLoading = false
                        return
                    }
                    
                    // Add the group code to the current user's groups array
                    usersRef.document(currentUserUID!).updateData([
                        "groups": FieldValue.arrayUnion([groupCode])
                    ]) { error in
                        if let error = error {
                            self.errorMessage = error.localizedDescription
                            isLoading = false
                            return
                        }
                        
                        // Show success alert and stop loading
                        isLoading = false
                        showSuccessAlert = true
                    }
                }
            }
    }
    
    // Loading Screen
    @ViewBuilder
    func LoadingScreen() -> some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
            
            ProgressView()
                .frame(width: 45, height: 45)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color(.systemBackground))
                )
        }
    }
}

#Preview {
    JoinGroupView()
}

