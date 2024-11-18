//
//  NotificationsView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-02.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct NotificationItem: Identifiable {
    let id: String
    let title: String
    let message: String
    let timestamp: String
    let group: String
    var isRead: Bool = false
}

struct NotificationsView: View {
    
    @State private var notifications: [NotificationItem] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    
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
                } else {
                    // Mark all button moved to top
                    HStack {
                        Spacer()
                        MarkAllButton {
                            markAllAsRead()
                        }
                        .padding(.horizontal)
                    }
                    
                    // Notifications list
                    List {
                        ForEach(notifications) { notification in
                            NotificationCell(notification: notification)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            //.navigationBarTitle("Notifications", displayMode: .inline)
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
            
            guard let data = snapshot?.data(),
                  let notificationsData = data["notifications"] as? [[String: Any]] else {
                self.errorMessage = "No notifications found."
                self.isLoading = false
                return
            }
            
            // Parse notifications data
            self.notifications = notificationsData.compactMap { dict in
                guard let id = dict["id"] as? String,
                      let title = dict["title"] as? String,
                      let message = dict["message"] as? String,
                      let timestamp = dict["timestamp"] as? Timestamp else {
                    return nil
                }
                
                // Convert timestamp to a human-readable string
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .short
                let timestampString = dateFormatter.string(from: timestamp.dateValue())
                
                return NotificationItem(
                    id: id,
                    title: title, // Using Firestore's title field
                    message: message, // Using Firestore's message field
                    timestamp: timestampString,
                    group: "" // Adjust or fetch group info if needed
                )
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
        
        // Clear notifications or mark them as read in Firestore
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
            // Title and timestamp
            VStack(alignment: .leading, spacing: 2) {
                Text(notification.title) // Display title
                    .font(.system(size: 17))
                    .fontWeight(.bold)
                    .foregroundColor(Color("CustomBlue"))
                
                Text(notification.timestamp) // Display timestamp under title
                    .font(.system(size: 13))
                    .foregroundColor(Color.gray)
            }
            
            // Message
            Text(notification.message) // Display message
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
