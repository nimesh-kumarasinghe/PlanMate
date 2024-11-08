//
//  ActivityDetailView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI
import FirebaseFirestore

struct ActivityDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var messageText = ""
    @State private var activity: Activity?
    
    // The selected activity ID passed from ActivityListView
    let activityId: String
    
    private let db = Firestore.firestore()

    var body: some View {
        VStack(spacing: 0) {
            if let activity = activity {
                // Event details card - Fixed at top
                EventDetailsView(event: activity)
                    .padding(.horizontal)
                    .padding(.vertical, 16)
                
                // Chat messages - Scrollable
                ScrollView {
                    ChatMessagesView(messages: sampleMessages) // Replace with real data if needed
                        .padding(.vertical)
                }
                
                // Message input - Fixed at bottom
                MessageInputView(messageText: $messageText)
            } else {
                // Show a loading spinner while fetching data
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .navigationTitle(activity?.title ?? "Activity Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {

            
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: CreateActivityView()) {
                            Text("Edit")
                        }
            }
        }
        .background(Color.white)
        .onAppear {
            fetchActivityDetails()
        }
    }
    
    // Function to fetch activity details from Firestore
    private func fetchActivityDetails() {
        db.collection("activities")
            .document(activityId)
            .getDocument { document, error in
                if let error = error {
                    print("Error fetching activity: \(error)")
                } else if let document = document, document.exists {
                    let data = document.data()
                    if let activity = Activity(id: document.documentID, data: data ?? [:]) {
                        self.activity = activity
                    }
                }
            }
    }
}

// EventDetailsView updated to work with an Activity model
struct EventDetailsView: View {
    let event: Activity
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack {
                    Text(event.startDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.title3)
                        .fontWeight(.medium)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 35))
                    .foregroundColor(Color("CustomBlue"))
                
                VStack {
                    Text(event.endDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.title3)
                        .fontWeight(.medium)
                }
            }
            
            Divider()
            
            VStack(spacing: 12) {
                DetailRow(icon: "alarm", text: "Event reminder: \(event.reminder)")
                
                Divider()
                
                DetailRow(icon: "person.2", text: "Group: \(event.groupName)")
                
                Divider()
                
                DetailRow(icon: "mappin.and.ellipse", text: event.location)
            }
        }
        .padding()
    }
}

// Row with icon and text (used in event details view)
struct DetailRow: View {
    let icon: String
    let text: String
    var detail: String = ""
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color("CustomBlue"))
                .frame(width: 24)
            
            Text(text)
            if !detail.isEmpty {
                Text(detail)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }
}

// Sample chat messages for demonstration purposes
let sampleMessages: [ChatMessage] = [
    ChatMessage(text: "Hello", isUser: true, time: ""),
    ChatMessage(text: "I'm at Galle Face! Just reached.", isUser: true, time: ""),
    ChatMessage(text: "Where are you all?", isUser: true, time: "09:25"),
    ChatMessage(text: "Oh, you're there already?", sender: "Kasun", isUser: false, time: ""),
    ChatMessage(text: "I'm on my way, should be there in 10 minutes.", sender: "Kasun", isUser: false, time: "09:30")
]

struct ChatMessage {
    let text: String
    let sender: String?
    let isUser: Bool
    let time: String
    
    init(text: String, sender: String? = nil, isUser: Bool, time: String) {
        self.text = text
        self.sender = sender
        self.isUser = isUser
        self.time = time
    }
}

struct ChatMessagesView: View {
    let messages: [ChatMessage]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(messages.indices, id: \.self) { index in
                ChatBubble(message: messages[index])
            }
        }
        .padding(.horizontal)
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                if let sender = message.sender {
                    Text(sender)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(message.text)
                    .padding(12)
                    .background(message.isUser ? Color("CustomBlue") : Color(UIColor.systemGray5))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(16)
                
                if !message.time.isEmpty {
                    Text(message.time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}

struct MessageInputView: View {
    @Binding var messageText: String
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("Write a message", text: $messageText)
                .padding(8)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(20)
            
            Button(action: {}) {
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(Color("CustomBlue"))
                    .font(.title2)
            }
            
            Button(action: {}) {
                Image(systemName: "face.smiling")
                    .foregroundColor(.gray)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
}

struct ActivityDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ActivityDetailView(activityId: "ActivityId")
        }
    }
}
