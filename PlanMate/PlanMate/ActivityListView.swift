//
//  ActivityListView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//
import SwiftUI

struct Activity {
    let title: String
    let location: String
    let date: Date
}

struct ActivityCard: View {
    let activity: Activity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
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
                    
                    Text(activity.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 17))
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
                
                Spacer()
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

struct ActivityListView: View {
    @State private var activities: [Activity] = [
        Activity(title: "Movie Time", location: "One Galle face PVR", date: Date(timeIntervalSince1970: 1697691000)), // Oct 19 2024 10:00 AM
        Activity(title: "Movie Time", location: "One Galle face PVR", date: Date(timeIntervalSince1970: 1697691000)),
        Activity(title: "Movie Time", location: "One Galle face PVR", date: Date(timeIntervalSince1970: 1697691000)),
        Activity(title: "Movie Time", location: "One Galle face PVR", date: Date(timeIntervalSince1970: 1697691000)),
        Activity(title: "Movie Time", location: "One Galle face PVR", date: Date(timeIntervalSince1970: 1697777400))  // Oct 20 2024 10:00 AM
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground).edgesIgnoringSafeArea(.all)
                
                VStack {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(activities.indices, id: \.self) { index in
                                ActivityCard(activity: activities[index])
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Activities")
            .navigationBarTitleDisplayMode(.inline)
        }
        .overlay(
            VStack {
                Spacer()
            }
        )
    }
}


struct ActivitiesView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityListView()
    }
}
