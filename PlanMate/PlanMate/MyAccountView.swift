//
//  MyAccountView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct MyAccountView: View {
    @State private var showingDeleteAlert = false
    @State private var showingLogOutAlert = false
    @State private var isLoggedOut = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showingEditProfile = false
    
    @AppStorage("user_name") private var userName: String = ""
    @AppStorage("userid") private var userid: String = ""
    @AppStorage("log_status") private var logStatus: Bool = false
    @AppStorage("use_face_id") private var useFaceID = false
    
    let profileInitial: String = "N"
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Section
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color("CustomBlue"))
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.white)
                            }
                            
                            Text("\(userName)")
                                .font(.system(size: 20, weight: .semibold))
                            
                            Button(action: {
                                showingEditProfile = true
                            }) {
                                Text("Edit Account")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color("DarkAsh"))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(25)
                            }
                            .padding(.top, 4)
                        }
                        .padding(.top, 20)
                        
                        // Settings Section
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Settings")
                                .font(.system(size: 17))
                                .foregroundColor(.black)
                                .padding(.leading, 16)
                                .padding(.bottom, 8)
                                .fontWeight(.bold)
                            
                            VStack(spacing: 0) {
                                LinkButton(title: "Help Center or FAQ")
                                Divider().padding(.leading, 16)
                                LinkButton(title: "Terms & Conditions")
                                Divider().padding(.leading, 16)
                                LinkButton(title: "Privacy Policy")
                                Divider().padding(.leading, 16)
                                LinkButton(title: "App info")
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                        }
                        
                        // Security Section
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Security")
                                .font(.system(size: 17))
                                .foregroundColor(.black)
                                .padding(.leading, 16)
                                .padding(.bottom, 8)
                                .fontWeight(.bold)
                            
                            Toggle(isOn: $useFaceID) {
                                HStack {
                                    Image(systemName: "faceid")
                                        .foregroundColor(.primary)
                                    Text("Enable Face ID Login")
                                        .foregroundColor(.primary)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                        }
                        
                        // Log Out Button
                        Button(action: {
                            showingLogOutAlert = true
                        }) {
                            Text("Log Out")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color("CustomBlue"))
                                .cornerRadius(50)
                        }
                        .padding(.horizontal, 40)
                        
                        // Delete Account Section
                        VStack(spacing: 16) {
                            Text("Deleting your account will permanently remove all your data, including groups and activity history.")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                            
                            Button(action: {
                                showingDeleteAlert = true
                            }) {
                                Text("Delete Account")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.red)
                                    .cornerRadius(50)
                            }
                            .padding(.horizontal, 40)
                        }
                    }
                    .padding(.vertical, 16)
                }
                .sheet(isPresented: $showingEditProfile) {
                    MyAccountEditView(
                        userName: userName,
                        email: Auth.auth().currentUser?.email ?? "",
                        uid: userid
                    )
                }
                .alert("Delete Account", isPresented: $showingDeleteAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        deleteUserAccount()
                    }
                } message: {
                    Text("Are you sure you want to delete your account? This action cannot be undone.")
                }
                .alert("Logout", isPresented: $showingLogOutAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Logout", role: .destructive) {
                        logOut()
                    }
                } message: {
                    Text("Are you sure you want to logout from your account?")
                }
                .alert("Error", isPresented: $showError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(errorMessage)
                }
            }
            .navigationBarTitle("My Account", displayMode: .inline)
            .navigationDestination(isPresented: $isLoggedOut) {
                SignInView()
                    .navigationBarBackButtonHidden(true)
            }
            
            // Loading Overlay
            if isLoading {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                ProgressView("Deleting Account...")
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 10)
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }
    // delete from firebase authetication
    func deleteUserAccountAuth() {
        Auth.auth().currentUser?.delete { error in
            if let error = error {
                // Check if re-authentication is required
                if let authError = error as NSError?,
                   authError.code == AuthErrorCode.requiresRecentLogin.rawValue {
                    self.showErrorWith(message: "Please re-authenticate to delete your account.")
                    // Prompt the user to re-authenticate here if needed
                } else {
                    showErrorWith(message: "Error deleting user account: \(error.localizedDescription)")
                }
            }
        }
        logOutAfterDeletion()
    }
    
    // Delete Account Function
    func deleteUserAccount() {
        isLoading = true
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        // 1. Delete user document
        let userRef = db.collection("users").document(uid)
        userRef.delete { error in
            if let error = error {
                showErrorWith(message: "Error deleting user data: \(error.localizedDescription)")
                return
            }
            deleteUserFromActivities(uid: uid)
        }
    }
    
    func deleteUserFromActivities(uid: String) {
        let db = Firestore.firestore()
        let activitiesRef = db.collection("activities")
        activitiesRef.whereField("participants", arrayContains: uid).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                showErrorWith(message: "Error fetching activities: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let batch = db.batch()
            for doc in snapshot.documents {
                let docRef = activitiesRef.document(doc.documentID)
                batch.updateData(["participants": FieldValue.arrayRemove([uid])], forDocument: docRef)
            }
            batch.commit { error in
                if let error = error {
                    showErrorWith(message: "Error updating activities: \(error.localizedDescription)")
                    return
                }
                deleteUserFromGroups(uid: uid)
            }
        }
    }
    
    func deleteUserFromGroups(uid: String) {
        let db = Firestore.firestore()
        let groupsRef = db.collection("groups")
        groupsRef.whereField("members", arrayContains: uid).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                showErrorWith(message: "Error fetching groups: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let batch = db.batch()
            for doc in snapshot.documents {
                let docRef = groupsRef.document(doc.documentID)
                batch.updateData(["members": FieldValue.arrayRemove([uid])], forDocument: docRef)
            }
            batch.commit { error in
                if let error = error {
                    showErrorWith(message: "Error updating groups: \(error.localizedDescription)")
                    return
                }
                deleteUserFromProposedActivities(uid: uid)
            }
        }
    }
    
    func deleteUserFromProposedActivities(uid: String) {
        let db = Firestore.firestore()
        let proposeActivitiesRef = db.collection("proposeActivities")
        proposeActivitiesRef.whereField("participants", arrayContains: uid).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                showErrorWith(message: "Error fetching proposed activities: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let batch = db.batch()
            for doc in snapshot.documents {
                let docRef = proposeActivitiesRef.document(doc.documentID)
                batch.updateData([
                    "participants": FieldValue.arrayRemove([uid]),
                    "participantNames": FieldValue.arrayRemove([userName])
                ], forDocument: docRef)
            }
            batch.commit { error in
                if let error = error {
                    showErrorWith(message: "Error updating proposed activities: \(error.localizedDescription)")
                    return
                }
                deleteUserVoteSubmissions(uid: uid)
            }
        }
    }
    
    func deleteUserVoteSubmissions(uid: String) {
        let db = Firestore.firestore()
        let voteSubmissionsRef = db.collection("voteSubmissions")
        voteSubmissionsRef.whereField("userId", isEqualTo: uid).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                showErrorWith(message: "Error fetching vote submissions: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let batch = db.batch()
            for doc in snapshot.documents {
                let docRef = voteSubmissionsRef.document(doc.documentID)
                batch.deleteDocument(docRef)
            }
            batch.commit { error in
                if let error = error {
                    showErrorWith(message: "Error deleting vote submissions: \(error.localizedDescription)")
                    return
                }
                deleteUserAccountAuth()
            }
        }
    }
    
    func showErrorWith(message: String) {
        errorMessage = message
        showError = true
        isLoading = false
    }
    
    func logOutAfterDeletion() {
        userName = ""
        userid = ""
        logStatus = false
        isLoading = false
        isLoggedOut = true
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
            userName = ""
            userid = ""
            logStatus = false
            self.isLoggedOut = true
        } catch {
            errorMessage = "Error signing out: \(error.localizedDescription)"
            showError = true
        }
    }
}

struct LinkButton: View {
    let title: String
    var icon: String?
    
    var body: some View {
        NavigationLink(destination: EmptyView()) {
            HStack {
                if let icon = icon {
                    Image(icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                }
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}

struct MyAccountView_Previews: PreviewProvider {
    static var previews: some View {
        MyAccountView()
    }
}
