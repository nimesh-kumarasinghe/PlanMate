//
//  ActivityDetailView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI
import FirebaseFirestore

struct ChatContentView: View {
    let messages: [ChatMessage]
    let currentUserId: String
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ChatMessagesView(
                        messages: messages,
                        currentUserId: currentUserId
                    )
                    .padding(.vertical)
                    
                    // Bottom marker
                    Color.clear
                        .frame(height: 1)
                        .id("bottomMessage")
                }
            }
            .onAppear {
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: messages) { _ in
                scrollToBottom(proxy: proxy)
            }
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                proxy.scrollTo("bottomMessage", anchor: .bottom)
            }
        }
    }
}

struct ActivityDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var chatViewModel = ActivityChatViewModel()
    @State private var messageText = ""
    @State private var activity: Activity?
    @AppStorage("user_name") private var userName: String = ""
    @AppStorage("userid") private var userId: String = ""
    
    let activityId: String
    private let db = Firestore.firestore()
    
    var body: some View {
        mainContent
            .navigationTitle(activity?.title ?? "Activity Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    editButton
                }
            }
            .background(Color.white)
            .onAppear {
                fetchActivityDetails()
                chatViewModel.startListening(activityId: activityId)
            }
            .onDisappear {
                chatViewModel.stopListening()
            }
            .alert(item: Binding(
                get: { chatViewModel.errorMessage.map { ErrorWrapper(error: $0) } },
                set: { chatViewModel.errorMessage = $0?.error }
            )) { errorWrapper in
                Alert(
                    title: Text("Error"),
                    message: Text(errorWrapper.error),
                    dismissButton: .default(Text("OK"))
                )
            }
    }
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            if let activity = activity {
                EventDetailsView(event: activity)
                    .padding(.horizontal)
                    .padding(.vertical, 16)
                
                ChatContentView(
                    messages: chatViewModel.messages,
                    currentUserId: userId
                )
                
                MessageInputView(messageText: $messageText) {
                    sendMessage()
                }
            } else {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
    }
    
    private var editButton: some View {
        NavigationLink(destination: CreateActivityView(isEditMode: true, editActivityId: activityId)) {
            Text("Edit")
        }
    }
    
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
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        chatViewModel.sendMessage(
            activityId: activityId,
            text: messageText,
            senderId: userId,
            senderName: userName
        )
        
        messageText = ""
    }
}

// EventDetailsView
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

// Row with icon and text for event details
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
struct ChatMessagesView: View {
    let messages: [ChatMessage]
    let currentUserId: String
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack(alignment: .leading, spacing: 12) {
                ForEach(messages) { message in
                    ChatBubble(
                        message: message,
                        isCurrentUser: message.senderId == currentUserId
                    )
                    .id(message.id)
                }
            }
            .padding(.horizontal)
            .onChange(of: messages.count) { _ in
                if let lastMessage = messages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
}


struct ChatBubble: View {
    let message: ChatMessage
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
            }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                if !isCurrentUser {
                    Text(message.senderName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.semibold)
                }
                
                Text(message.text)
                    .padding(12)
                    .background(isCurrentUser ? Color("CustomBlue") : Color(UIColor.systemGray5))
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .cornerRadius(16)
                
                Text(message.timeString)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !isCurrentUser {
                Spacer()
            }
        }
    }
}

struct MessageInputView: View {
    @Binding var messageText: String
    let onSend: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("Write a message", text: $messageText)
                .padding(8)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(20)
            
            Button(action: {
                onSend()
            }) {
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(!messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color("CustomBlue") : .gray)
                    .font(.title2)
            }
            .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .shadow(radius: 1)
    }
}


struct ActivityDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ActivityDetailView(activityId: "ActivityId")
        }
    }
}
