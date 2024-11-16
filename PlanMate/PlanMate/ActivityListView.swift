//
//  ActivityListView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// Activity model remains the same
struct Activity: Identifiable {
    var id: String
    let title: String
    let location: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    let reminder: String
    let groupName: String
    
    init?(id: String, data: [String: Any]) {
        guard
            let title = data["title"] as? String,
            let locationData = data["locations"] as? [[String: Any]],
            let startDate = (data["startDate"] as? Timestamp)?.dateValue(),
            let endDate = (data["endDate"] as? Timestamp)?.dateValue(),
            let isAllDay = data["isAllDay"] as? Bool,
            let reminder = data["reminder"] as? String,
            let groupName = data["groupName"] as? String
        else {
            return nil
        }
        
        self.id = id
        self.title = title
        self.location = locationData.first?["name"] as? String ?? "Unknown Location"
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.reminder = reminder
        self.groupName = groupName
    }
}

struct ActivityListView: View {
    @State private var activities: [Activity] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    private let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground).edgesIgnoringSafeArea(.all)
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.2)
                } else if activities.isEmpty {
                    EmptyStateView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(activities) { activity in
                                NavigationLink(destination: ActivityDetailView(activityId: activity.id)) {
                                    ActivityCard(activity: activity)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical)
                    }
                }
                
                if let errorMessage = errorMessage {
                    VStack {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.red.opacity(0.1))
                            )
                    }
                }
            }
            .navigationTitle("Activities")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                fetchUserActivities()
            }
        }
        
    }
    
    private func fetchUserActivities() {
        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = "No user logged in"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let userRef = db.collection("users").document(currentUser.uid)
        
        userRef.getDocument { (document, error) in
            if let error = error {
                isLoading = false
                errorMessage = "Error fetching user data: \(error.localizedDescription)"
                return
            }
            
            guard let document = document, document.exists,
                  let userData = document.data() else {
                isLoading = false
                errorMessage = "User data not found"
                return
            }
            
            let userActivities = (userData["activities"] as? [String] ?? []).map { activityId in
                activityId.trimmingCharacters(in: .whitespaces)
            }
            
            if userActivities.isEmpty {
                isLoading = false
                activities = []
                return
            }
            
            print("User Activities IDs:", userActivities)
            
            let batch = userActivities.map { activityId in
                db.collection("activities").document(activityId)
            }
            
            let group = DispatchGroup()
            var fetchedActivities: [Activity] = []
            
            for activityRef in batch {
                group.enter()
                
                activityRef.getDocument { (activityDoc, error) in
                    defer { group.leave() }
                    
                    if let error = error {
                        print("Error fetching activity \(activityRef.documentID): \(error)")
                        return
                    }
                    
                    if let activityDoc = activityDoc,
                       let data = activityDoc.data(),
                       let activity = Activity(id: activityDoc.documentID, data: data) {
                        fetchedActivities.append(activity)
                    }
                }
            }
            
            group.notify(queue: .main) {
                isLoading = false
                activities = fetchedActivities.sorted { $0.startDate < $1.startDate }
                
                if activities.isEmpty {
                    print("No activities found after fetching")
                }
            }
        }
    }
}

struct ActivityCard: View {
    let activity: Activity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                Rectangle()
                    .fill(Color("CustomBlue"))
                    .frame(width: 6, height: 60)
                    .frame(maxHeight: .infinity)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.title)
                        .font(.system(size: 20, weight: .semibold))
                    
                    Text(activity.location)
                        .font(.system(size: 17))
                        .foregroundColor(.black)
                    
                    Text(activity.startDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 17))
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 12)
                
                Spacer()
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal, 1)
        .padding(.vertical, 1)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 70))
                .foregroundColor(.gray)
            
            Text("No Activities")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Your activities will appear here")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

struct ActivityListView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityListView()
    }
}
