//
//  ProposeActivityList.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-07.
//

import SwiftUI

struct ProposeActivityList: View {
    @State private var activities: [ActivityData] = [
        ActivityData(title: "October day out", from: "Cousins"),
        ActivityData(title: "Next hiking trip", from: "Trip Friends"),
        ActivityData(title: "November party", from: "Office"),
        ActivityData(title: "Next day out", from: "Friends"),
        ActivityData(title: "December movie time", from: "Campus Friends"),
        ActivityData(title: "Picnic", from: "Class Friends"),
        ActivityData(title: "Committee meeting", from: "IT Committee")
    ]

    var body: some View {
        NavigationView {
            List {
                ForEach(activities) { activity in
                    NavigationLink(destination: ActivityDetailsView(activity: activity)) {
                        ActivitiesRow(activity: activity)
                    }
                }
                .onDelete(perform: deleteActivity)
            }
            .navigationBarTitle("Proposed Activities")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(white: 0.95))
        }
        .background(Color.white)
    }

    private func deleteActivity(at offsets: IndexSet) {
        activities.remove(atOffsets: offsets)
    }
}

struct ActivitiesRow: View {
    let activity: ActivityData

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(activity.title)
                    .font(.headline)
                Text("from \(activity.from)")
                    .font(.subheadline)
            }
            Spacer()
        }
        .padding()
    }
}

struct ActivityDetailsView: View {
    let activity: ActivityData

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(activity.title)
                .font(.title)
            Text("from \(activity.from)")
                .font(.subheadline)
            Spacer()
        }
        .padding()
        .background(Color.white)
    }
}

struct ActivityData: Identifiable {
    let id = UUID()
    let title: String
    let from: String
}

struct ProposeActivityList_Previews: PreviewProvider {
    static var previews: some View {
        ProposeActivityList()
    }
}
