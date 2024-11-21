//
//  NotificationsView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-02.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct NotificationsView: View {
    
    @State private var notifications: [NotificationItem] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    @State private var showEventNotifications = false
    @State private var showProposeNotifications = false
    
    var filteredNotifications: [NotificationItem] {
        notifications.filter { notification in
            switch notification.type {
            case "Event":
                return showEventNotifications
            case "PA":
                return showProposeNotifications
            default:
                return false
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Loading indicator or error message
                if isLoading {
                    ProgressView("Loading Notifications...")
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else if !showEventNotifications && !showProposeNotifications {
                    // Show message when both notification types are disabled
                    VStack {
                        Spacer()
                        Image(systemName: "bell.badge")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("Turn on your notification settings in your account")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding()
                        Spacer()
                    }
                    
                }  else {
                    if !filteredNotifications.isEmpty {
                        // Clear all notification
                        HStack {
                            Spacer()
                            MarkAllButton {
                                markAllAsRead()
                            }
                            .padding(.horizontal)
                        }
                        
                        // Notifications list
                        List {
                            ForEach(filteredNotifications) { notification in
                                NotificationCell(notification: notification)
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                            }
                        }
                        .listStyle(PlainListStyle())
                    } else {
                        VStack {
                            Spacer()
                            Image(systemName: "bell.slash")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("No notifications")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                            Spacer()
                        }
                        
                    }
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            fetchNotifications()
        }
    }
    
    private func fetchNotifications() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not logged in."
            self.isLoading = false
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUserId)
        
        userRef.getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch notifications: \(error.localizedDescription)"
                self.isLoading = false
                return
            }
            
            guard let data = snapshot?.data() else {
                self.errorMessage = "No user data found."
                self.isLoading = false
                return
            }
            
            // Get notification preferences
            self.showEventNotifications = data["showEventNotifications"] as? Bool ?? false
            self.showProposeNotifications = data["showProposeNotifications"] as? Bool ?? false
            
            guard let notificationsData = data["notifications"] as? [[String: Any]] else {
                self.errorMessage = "No notifications found."
                self.isLoading = false
                return
            }
            
            // Parse notifications data
            self.notifications = notificationsData.compactMap { dict in
                guard let id = dict["id"] as? String,
                      let title = dict["title"] as? String,
                      let message = dict["message"] as? String,
                      let type = dict["type"] as? String,
                      let timestamp = dict["timestamp"] as? Timestamp else {
                    return nil
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .short
                let timestampString = dateFormatter.string(from: timestamp.dateValue())
                
                return NotificationItem(
                    id: id,
                    title: title,
                    message: message,
                    timestamp: timestampString,
                    group: "",
                    type: type,
                    rawTimestamp: timestamp.dateValue()
                )
            }.sorted { notification1, notification2 in
                // Sort in descending order (newest first)
                notification1.rawTimestamp > notification2.rawTimestamp
            }
            
            self.isLoading = false
        }
    }
    
    
    private func markAllAsRead() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not logged in."
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUserId)
        
        // Clear notifications in Firestore
        userRef.updateData(["notifications": []]) { error in
            if let error = error {
                self.errorMessage = "Failed to mark notifications as read: \(error.localizedDescription)"
                return
            }
            
            // Clear locally
            self.notifications.removeAll()
        }
    }
}

struct NotificationCell: View {
    let notification: NotificationItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            VStack(alignment: .leading, spacing: 2) {
                Text(notification.title)
                    .font(.system(size: 17))
                    .fontWeight(.bold)
                    .foregroundColor(Color("CustomBlue"))
                
                Text(notification.timestamp)
                    .font(.system(size: 13))
                    .foregroundColor(Color.gray)
            }
            
            // Message
            Text(notification.message)
                .font(.system(size: 17))
                .foregroundColor(Color(.black))
                .multilineTextAlignment(.leading)
                .padding(.top, 2)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
        )
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}



struct MarkAllButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Clear All")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color("CustomBlue"))
        }
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
