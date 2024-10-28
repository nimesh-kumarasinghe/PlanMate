//
//  MyAccountView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI

struct MyAccountView: View {
    @State private var showingDeleteAlert = false
    @State private var showingLogOutAlert = false
    let profileInitial: String = "N"
    let userName: String = "Nimesh Kumarasinghe"
    let userBirthDate: String = "03 June 1999"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Section
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 80, height: 80)
                            
                            Text(profileInitial)
                                .foregroundColor(.white)
                                .font(.system(size: 32, weight: .medium))
                        }
                        
                        Text(userName)
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text(userBirthDate)
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    // Linked Accounts Section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Linked Accounts")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .padding(.leading, 16)
                            .padding(.bottom, 8)
                        
                        VStack(spacing: 0) {
                            LinkButton(title: "Connect with Apple", icon: "apple.logo")
                            Divider().padding(.leading, 16)
                            LinkButton(title: "Connect with Google", icon: "g.circle.fill")
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                    }
                    
                    // Settings Section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Linked Accounts")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .padding(.leading, 16)
                            .padding(.bottom, 8)
                        
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
                    
                    // Log Out Button
                    Button(action: {
                        showingLogOutAlert = true
                    }) {
                        Text("Log Out")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 16)
                    
                    // Delete Account Section
                    VStack(spacing: 16) {
                        Text("Deleting your account will permanently remove all your data, including groups and activity history.")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
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
                                .cornerRadius(8)
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 16)
            }
            .navigationBarItems(leading: BackButton())
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
                    // Handle delete account
                },
                secondaryButton: .cancel()
            )
        }
    }
}

struct BackButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
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
                    Image(systemName: icon)
                        .foregroundColor(.blue)
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
