//
//  NotificationsView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-02.
//

import SwiftUI

struct NotificationItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let timestamp: String
    let group: String
    var isRead: Bool = false
}

struct NotificationsView: View {
    
    @State private var notifications: [NotificationItem] = [
        NotificationItem(title: "Proposed an activity",
                        message: "Nimesh proposed and activity in campus friends group. Check and mark your availability.",
                        timestamp: "now",
                        group: "Campus Friends"),
        NotificationItem(title: "Proposed an activity",
                        message: "Dilanjana proposed and activity in Office group. Check and mark your availability.",
                        timestamp: "30 min",
                        group: "Office"),
        NotificationItem(title: "Proposed an activity",
                        message: "Dilanjana proposed and activity in Office group. Check and mark your availability.",
                        timestamp: "Yesterday",
                        group: "Office"),
        NotificationItem(title: "Proposed an activity",
                        message: "Dilanjana proposed and activity in Office group. Check and mark your availability.",
                        timestamp: "10/12",
                        group: "Office"),
        NotificationItem(title: "Proposed an activity",
                        message: "Dilanjana proposed and activity in Office group. Check and mark your availability.",
                        timestamp: "10/03",
                        group: "Office")
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                // Mark all button moved to top
                HStack {
                    Spacer()
                    MarkAllButton()
                        .padding(.horizontal)
                }
                
                List {
                    ForEach(notifications) { notification in
                        NotificationCell(notification: notification)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationBarTitle("Notifications", displayMode: .inline)
        }
        .toolbar(.hidden, for: .tabBar)
    }
}

struct NotificationCell: View {
    let notification: NotificationItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                Text(notification.title)
                    .font(.system(size: 17))
                    .fontWeight(.bold)
                    .foregroundColor(Color("CustomBlue"))
                Spacer()
                Text(notification.timestamp)
                    .font(.system(size: 13))
                    .foregroundColor(Color("CustomBlue"))
            }
            
            Text(notification.message)
                .font(.system(size: 17))
                .foregroundColor(Color(.black))
                // Removed lineLimit and added multilineTextAlignment
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
    var body: some View {
        Button(action: {}) {
            Text("Mark all as read")
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
