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
            List {
                ForEach(notifications) { notification in
                    NotificationCell(notification: notification)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("Notifications", displayMode: .inline)
            .navigationBarItems(
                leading: BackButton(),
                trailing: MarkAllButton()
            )
        }
    }
}

struct NotificationCell: View {
    let notification: NotificationItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                Text(notification.title)
                    .font(.system(size: 15))
                Spacer()
                Text(notification.timestamp)
                    .font(.system(size: 13))
                    .foregroundColor(.blue)
            }
            
            Text(notification.message)
                .font(.system(size: 15))
                .foregroundColor(Color(.systemGray))
                .lineLimit(2)
                .padding(.top, 2)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}

//struct BackButton: View {
//    @Environment(\.presentationMode) var presentationMode
//    
//    var body: some View {
//        Button(action: {
//            presentationMode.wrappedValue.dismiss()
//        }) {
//            HStack(spacing: 5) {
//                Image(systemName: "chevron.left")
//                    .font(.system(size: 16, weight: .medium))
//                Text("Back")
//                    .font(.system(size: 17, weight: .regular))
//            }
//            .foregroundColor(.blue)
//        }
//    }
//}

struct MarkAllButton: View {
    var body: some View {
        Button(action: {}) {
            Text("Mark all as read")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.blue)
        }
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
