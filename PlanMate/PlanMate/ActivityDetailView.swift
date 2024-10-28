//
//  ActivityDetailView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI

struct ActivityDetailView: View {
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
            // Navigation header
            HStack {
                Button(action: {}) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text("Movie Time")
                    .font(.headline)
                
                Spacer()
                
                Button("Edit") {
                    // Edit action
                }
                .foregroundColor(.blue)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            
            ScrollView {
                VStack(spacing: 16) {
                    // Event details card
                    EventDetailsView(event: event)
                        .padding(.horizontal)
                    
                    // Chat messages
                    ChatMessagesView(messages: messages)
                }
                .padding(.vertical)
            }
            
            // Message input
            MessageInputView(messageText: $messageText)
        }
    }
}

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
            // Time selection
            HStack {
                Text(event.startTime)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.blue)
                
                Text(event.endTime)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            Text(event.date)
                .foregroundColor(.secondary)
            
            // Event details list
            VStack(spacing: 12) {
                DetailRow(icon: "alarm", text: "Set event reminders", detail: "(\(event.reminder))")
                DetailRow(icon: "person.2", text: event.attendees)
                DetailRow(icon: "mappin.and.ellipse", text: event.location)
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
    }
}

struct DetailRow: View {
    let icon: String
    let text: String
    var detail: String = ""
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
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
                    .background(message.isUser ? Color.blue : Color(UIColor.systemGray5))
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
                Image(systemName: "arrow.up.circle.fill")
                    .foregroundColor(.blue)
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
    ActivityDetailView()
}
