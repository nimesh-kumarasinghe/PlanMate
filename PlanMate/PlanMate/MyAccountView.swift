//
//  MyAccountView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct MyAccountView: View {
    @State private var showingDeleteAlert = false
    @State private var showingLogOutAlert = false
    @State private var isLoggedOut = false
    
    @AppStorage("user_name") private var userName: String = ""
    @AppStorage("userid") private var userid: String = ""
    @AppStorage("log_status") private var logStatus: Bool = false
    @AppStorage("use_face_id") private var useFaceID = false
    
    let profileInitial: String = "N"
    
    var body: some View {
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
                    }
                    .padding(.top, 20)
                    
                    // Linked Accounts Section
//                    VStack(alignment: .leading, spacing: 0) {
//                        Text("Linked Accounts")
//                            .font(.system(size: 17))
//                            .foregroundColor(.black)
//                            .padding(.leading, 16)
//                            .padding(.bottom, 8)
//                            .fontWeight(.bold)
//                        
//                        VStack(spacing: 0) {
//                            LinkButton(title: "Connect with Apple", icon: "apple")
//                            Divider().padding(.leading, 16)
//                            LinkButton(title: "Connect with Google", icon: "google")
//                        }
//                        .background(Color(.systemBackground))
//                        .cornerRadius(10)
//                    }
                    
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
            .navigationBarTitle("My Account", displayMode: .inline)
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Account"),
                message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    // Handle delete account
                },
                secondaryButton: .cancel()
            )
        }
        .alert(isPresented: $showingLogOutAlert) {
            Alert(
                title: Text("LogOut"),
                message: Text("Are you sure you want to logout from your account?"),
                primaryButton: .destructive(Text("Logout")) {
                    logOut()
                },
                secondaryButton: .cancel()
            )
        }
        .navigationDestination(isPresented: $isLoggedOut) {
            SignInView()
                .navigationBarBackButtonHidden(true) // Navigate to SignInView when logging out
        }
    }
    
    // LogOut Function
    func logOut() {
        do {
            // Sign out from Firebase
            try Auth.auth().signOut()
            
            // Clear user session data
            KeychainHelper.shared.delete(forKey: "uid")
            userName = ""
            userid = ""
            
            // Mark user as logged out and trigger navigation
            logStatus = false // Set log_status to false
            self.isLoggedOut = true // Trigger navigation to SignInView
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
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

struct AccountSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        MyAccountView()
    }
}
