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
import SDWebImageSwiftUI

struct MyAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false
    @State private var showingLogOutAlert = false
    @State private var isLoggedOut = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showingEditProfile = false
    @State private var profileImageURL: String?
    @State private var isImageLoading = false
    @State private var shouldRefreshProfile = false
    
    @StateObject private var biometricManager = BiometricManager()
    
    @AppStorage("user_name") private var userName: String = ""
    @AppStorage("userid") private var userid: String = ""
    @AppStorage("log_status") private var logStatus: Bool = false
    @AppStorage("use_face_id") private var useFaceID = false
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Section
                        VStack(spacing: 8) {
                            ZStack {
                                if let imageURL = profileImageURL, !imageURL.isEmpty {
                                    WebImage(url: URL(string: imageURL))
                                        .resizable()
                                        .indicator { _, _ in
                                            Circle()
                                                .fill(Color.gray.opacity(0.2))
                                                .frame(width: 100, height: 100)
                                            
                                            Image(systemName: "person.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundColor(Color.gray)
                                                .frame(width: 60, height: 60)
                                        }
                                        .transition(.fade(duration: 0.5))
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(Color("CustomBlue"))
                                        .frame(width: 100, height: 100)
                                    
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(.white)
                                }
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
                                NavigationLink(destination: NotificationSetting()) {
                                    LinkRowView(title: "Notifications",
                                                icon: "bell")
                                }
                                Divider().padding(.leading, 16)
                                
                                NavigationLink(destination:
                                                ContentDetailView(title: "Help Center or FAQ",
                                                                  description: "Find answers to common questions and support.")) {
                                    LinkRowView(title: "Help Center or FAQ",
                                                icon: "questionmark.circle")
                                }
                                Divider().padding(.leading, 16)
                                
                                NavigationLink(destination:
                                                ContentDetailView(title: "Terms & Conditions",
                                                                  description: "Learn about our terms and conditions.")) {
                                    LinkRowView(title: "Terms & Conditions",
                                                icon: "doc.text")
                                }
                                Divider().padding(.leading, 16)
                                
                                NavigationLink(destination:
                                                ContentDetailView(title: "Privacy Policy",
                                                                  description: "Read about how we protect your data.")) {
                                    LinkRowView(title: "Privacy Policy",
                                                icon: "lock.shield")
                                }
                                Divider().padding(.leading, 16)
                                
                                NavigationLink(destination:
                                                ContentDetailView(title: "App info",
                                                                  description: "View the app version and release notes.")) {
                                    LinkRowView(title: "App info",
                                                icon: "info.circle")
                                }
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
                                        .foregroundColor(Color("CustomBlue"))
                                    Text("Enable Face ID Login")
                                        .foregroundColor(.primary)
                                }
                            }
                            .disabled(!biometricManager.isFaceIDAvailable)
                            .onChange(of: useFaceID) { newValue in
                                if newValue {
                                    biometricManager.authenticateWithFaceID { success in
                                        if !success {
                                            useFaceID = false
                                        }
                                    }
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
                    .onAppear {
                        loadProfileImage()
                    }
                }
                .padding(.top, -70)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .foregroundColor(Color("CustomBlue"))
                        }
                    }
                    
                    ToolbarItem(placement: .principal) {
                        Text("My Account")
                            .font(.headline)
                    }
                }
                .sheet(isPresented: $showingEditProfile) {
                    loadProfileImage()
                }content:{
                    MyAccountEditView(
                        userName: userName,
                        email: Auth.auth().currentUser?.email ?? "",
                        uid: userid,
                        profileImageURL: profileImageURL
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
    
    private func loadProfileImage() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        isImageLoading = true
        db.collection("users").document(uid).getDocument { document, error in
            isImageLoading = false
            
            if let error = error {
                print("Error fetching profile image: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                let newProfileImageURL = document.data()?["profileImageURL"] as? String
                if newProfileImageURL != profileImageURL {
                    profileImageURL = newProfileImageURL
                }
            }
        }
    }
    
    // delete from firebase authetication
    func deleteUserAccountAuth() {
        Auth.auth().currentUser?.delete { error in
            if let error = error {
                // Check if reauthentication is required
                if let authError = error as NSError?,
                   authError.code == AuthErrorCode.requiresRecentLogin.rawValue {
                    self.showErrorWith(message: "Please re-authenticate to delete your account.")
                } else {
                    showErrorWith(message: "Error deleting user account: \(error.localizedDescription)")
                }
            }
        }
        logOut()
    }
    
    // Delete Account Function
    func deleteUserAccount() {
        isLoading = true
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
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
    
    func logOut() {
        do {
            try Auth.auth().signOut()
            userName = ""
            userid = ""
            logStatus = false
            self.isLoggedOut = true
            
            //try KeychainManager.shared.deleteCredentials()
        } catch {
            errorMessage = "Error signing out: \(error.localizedDescription)"
            showError = true
        }
    }
}

// notification setting page
struct NotificationSetting: View{
    @State private var showProposeNotifications = false
    @State private var showEventNotifications = false
    @State private var showVoteReminders = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    var body: some View{
        ScrollView{
            VStack(spacing: 0){
                
                Toggle(isOn: $showProposeNotifications) {
                    HStack {
                        Image(systemName: "bell.badge")
                            .foregroundColor(Color("CustomBlue"))
                        Text("Show Propose Activity Notifications")
                            .foregroundColor(.primary)
                    }
                }
                .onChange(of: showProposeNotifications) { newValue in
                    updateNotificationSettings(proposeNotifications: newValue)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                Divider().padding(.leading, 16)
                
                Toggle(isOn: $showEventNotifications) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(Color("CustomBlue"))
                        Text("Show Event Notifications")
                            .foregroundColor(.primary)
                    }
                }
                .onChange(of: showEventNotifications) { newValue in
                    updateNotificationSettings(eventNotifications: newValue)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                Divider().padding(.leading, 16)
                
                Toggle(isOn: $showVoteReminders) {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(Color("CustomBlue"))
                        Text("Get Activity Voting Reminders")
                            .foregroundColor(.primary)
                    }
                }
                .onChange(of: showVoteReminders) { newValue in
                    updateNotificationSettings(voteReminders: newValue)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Notification Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadNotificationSettings()
        }
    }
    
    private func updateNotificationSettings(proposeNotifications: Bool? = nil, eventNotifications: Bool? = nil, voteReminders: Bool? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        var updateData: [String: Any] = [:]
        if let proposeNotifications = proposeNotifications {
            updateData["showProposeNotifications"] = proposeNotifications
        }
        if let eventNotifications = eventNotifications {
            updateData["showEventNotifications"] = eventNotifications
        }
        if let voteReminders = voteReminders {
            updateData["showVoteReminders"] = voteReminders
        }
        
        db.collection("users").document(uid).updateData(updateData) { error in
            if let error = error {
                errorMessage = "Error updating notification settings: \(error.localizedDescription)"
                showError = true
            }
        }
    }
    
    // load initial settings
    private func loadNotificationSettings() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        db.collection("users").document(uid).getDocument { document, error in
            if let document = document, document.exists {
                showProposeNotifications = document.data()?["showProposeNotifications"] as? Bool ?? false
                showEventNotifications = document.data()?["showEventNotifications"] as? Bool ?? false
                showVoteReminders = document.data()?["showVoteReminders"] as? Bool ?? false
            }
        }
    }
}

struct ContentDetailView: View {
    let title: String
    let description: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text(description)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(Color("CustomBlue"))
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text(title)
                    .font(.headline)
            }
        }
    }
}

// Link Row View
struct LinkRowView: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .foregroundColor(Color("CustomBlue"))
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

struct MyAccountView_Previews: PreviewProvider {
    static var previews: some View {
        MyAccountView()
    }
}
