//
//  ActivityDetailView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI

struct ActivityDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var messageText = ""
    
    let event = EventDetails(
        startTime: "10:00",
        endTime: "14:00",
        date: "Sun, 20 Oct 2024",
        reminder: "10 min before",
        attendees: "Cousins",
        location: "One Galle Face PVR"
    )
    
    let messages: [ChatMessage] = [
        ChatMessage(text: "Hello", isUser: true, time: ""),
        ChatMessage(text: "I'm at Galle Face! Just reached.", isUser: true, time: ""),
        ChatMessage(text: "Where are you all?", isUser: true, time: "09:25"),
        ChatMessage(text: "Oh, you're there already?", sender: "Kasun", isUser: false, time: ""),
        ChatMessage(text: "I'm on my way, should be there in 10 minutes.", sender: "Kasun", isUser: false, time: "09:30")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Event details card - Fixed at top
            EventDetailsView(event: event)
                .padding(.horizontal)
                .padding(.vertical, 16)
            
            // Chat messages - Scrollable
            ScrollView {
                ChatMessagesView(messages: messages)
                    .padding(.vertical)
            }
            
            // Message input - Fixed at bottom
            MessageInputView(messageText: $messageText)
        }
        .navigationTitle("Movie Time")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveActivity()
                    dismiss()
                }
            }
        }
        .background(Color.white)
    }
    
    func saveActivity() {
        // Implement save functionality
    }
}

// Rest of the structs remain the same
struct EventDetails {
    let startTime: String
    let endTime: String
    let date: String
    let reminder: String
    let attendees: String
    let location: String
}

struct EventDetailsView: View {
    let event: EventDetails
    
    var body: some View {
        VStack(spacing: 16) {
            // Time selection with separate dates and larger chevron
            HStack {
                VStack {
                    Text(event.startTime)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                    
                    Text(event.date) // New date under start time
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 40)) // Increase chevron size
                    .foregroundColor(Color("CustomBlue"))
                
                VStack {
                    Text(event.endTime)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                    
                    Text(event.date) // New date under end time
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider() // Line to separate sections
            
            // Event details list with separators
            VStack(spacing: 12) {
                DetailRow(icon: "alarm", text: "Set event reminders", detail: "(\(event.reminder))")
                
                Divider() // Line after each detail
                
                DetailRow(icon: "person.2", text: "Cousins") // Updated text example
                
                Divider() // Line after each detail
                
                DetailRow(icon: "mappin.and.ellipse", text: "One gallery face parts") // Updated text example
            }
        }
        .padding()
        .background(Color(.white))
    }
}

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

#Preview {
    NavigationView {
        ActivityDetailView()
    }
}
