//
//  ActivityListView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//
import SwiftUI

struct ActivityListView: View {
    var activities = [
        Activity(date: "20 Oct 2024", time: "10:00 am", title: "Movie Time", location: "One Galle face PVR"),
        Activity(date: "19 Oct 2024", time: "10:00 am", title: "Movie Time", location: "One Galle face PVR"),
        Activity(date: "19 Oct 2024", time: "10:00 am", title: "Movie Time", location: "One Galle face PVR"),
        Activity(date: "19 Oct 2024", time: "10:00 am", title: "Movie Time", location: "One Galle face PVR")
    ]
    
    var body: some View {
        VStack {
            // Header title
            Text("Activities")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top)
            
            // List of Activity Cards
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(activities) { activity in
                        ActivityCard(activity: activity)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationBarHidden(true)
    }
}

struct Activity: Identifiable {
    let id = UUID()
    let date: String
    let time: String
    let title: String
    let location: String
}

struct ActivityCard: View {
    var activity: Activity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(activity.title)
                .font(.headline)
                .foregroundColor(.primary)
            Text(activity.location)
                .font(.subheadline)
                .foregroundColor(.secondary)
            HStack {
                Text(activity.date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(" | at \(activity.time)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
        )
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityListView()
    }
}
