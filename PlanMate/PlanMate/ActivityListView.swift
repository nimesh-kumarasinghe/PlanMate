//
//  ActivityListView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//
import SwiftUI
import FirebaseFirestore

// Define the Activity model directly in ActivityListView
struct Activity: Identifiable {
    var id: String
    let title: String
    let location: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    let reminder: String
    let groupName: String
    
    // Initialize from Firestore data
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
    private let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground).edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(activities) { activity in
                            // Wrap ActivityCard in NavigationLink
                            NavigationLink(destination: ActivityDetailView(activityId: activity.id)) {
                                ActivityCard(activity: activity)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                            }
                            .buttonStyle(PlainButtonStyle()) // Remove default NavigationLink button style
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Activities")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                fetchActivities()
            }
        }
    }

    // Fetch activities from Firestore, ordered by startDate
    private func fetchActivities() {
        db.collection("activities")
            .order(by: "startDate", descending: false) // Set descending to false for ascending order
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching activities: \(error)")
                    return
                }
                
                self.activities = snapshot?.documents.compactMap { document -> Activity? in
                    let data = document.data()
                    return Activity(id: document.documentID, data: data)
                } ?? []
            }
    }
}

// ActivityCard to show each activity
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

struct ActivityListView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityListView()
    }
}
