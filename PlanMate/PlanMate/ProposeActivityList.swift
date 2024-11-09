//
//  ProposeActivityList.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-07.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// Model to represent proposed activity data
struct ActivityData: Identifiable {
    let id: String
    let title: String
    let from: String
    let groupId: String
    let groupName: String
    
    init(id: String = UUID().uuidString, title: String, from: String, groupId: String = "", groupName: String = "") {
        self.id = id
        self.title = title
        self.from = from
        self.groupId = groupId
        self.groupName = groupName
    }
}

// ViewModel to handle Firebase operations
class ProposeActivitiesViewModel: ObservableObject {
    @Published var activities: [ActivityData] = []
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    
    private var db = Firestore.firestore()
    private var activityListeners: [ListenerRegistration] = []
    
    func fetchUserActivities() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        print("Fetching activities for user with ID: \(userId)")

        db.collection("users").document(userId).getDocument { [weak self] document, error in
            guard let self = self else { return }

            if let error = error {
                self.errorMessage = "Error fetching user document: \(error.localizedDescription)"
                self.isLoading = false
                return
            }

            guard let document = document,
                  let proposeActivities = document.data()?["proposeActivities"] as? [String] else {
                print("No proposeActivities field or invalid format")
                self.isLoading = false
                return
            }

            print("Fetched proposeActivities for user: \(proposeActivities)")

            self.activities.removeAll()
            self.removeListeners()
            self.fetchProposeActivities(activityIds: proposeActivities)
        }
    }

    private func fetchProposeActivities(activityIds: [String]) {
        for activityId in activityIds {
            let cleanActivityId = activityId.trimmingCharacters(in: .whitespaces)

            let listener = db.collection("proposeActivities")
                .document(cleanActivityId)
                .addSnapshotListener { [weak self] documentSnapshot, error in
                    guard let self = self else { return }

                    if let error = error {
                        print("Error fetching activity: \(error.localizedDescription)")
                        self.errorMessage = "Error fetching activity: \(error.localizedDescription)"
                        return
                    }

                    guard let document = documentSnapshot, document.exists,
                          let data = document.data() else {
                        print("No document found for activity ID: \(cleanActivityId)")
                        return
                    }

                    if let activity = self.parseActivityData(document: document, data: data) {
                        DispatchQueue.main.async {
                            if let index = self.activities.firstIndex(where: { $0.id == activity.id }) {
                                self.activities[index] = activity
                            } else {
                                self.activities.append(activity)
                            }
                        }
                    }
                }

            activityListeners.append(listener)
        }

        isLoading = false
    }

    private func parseActivityData(document: DocumentSnapshot, data: [String: Any]) -> ActivityData? {
        guard let title = data["title"] as? String,
              let groupId = data["groupId"] as? String,
              let groupName = data["groupName"] as? String else {
            return nil
        }

        return ActivityData(
            id: document.documentID,
            title: title,
            from: groupName,
            groupId: groupId,
            groupName: groupName
        )
    }

    private func removeListeners() {
        activityListeners.forEach { listener in
            listener.remove()
        }
        activityListeners.removeAll()
    }

    func deleteActivity(activityId: String) {
        guard let currentUser = Auth.auth().currentUser else {
            print("No current user authenticated.")
            return
        }

        let userRef = db.collection("users").document(currentUser.uid)

        print("Attempting to delete activity with ID: \(activityId) from user's proposeActivities array.")

        // Use FieldValue.arrayRemove to directly remove the activityId from proposeActivities array
        userRef.updateData([
            "proposeActivities": FieldValue.arrayRemove([activityId])
        ]) { [weak self] error in
            guard let self = self else { return }

            if let error = error {
                print("Error removing activity from user's proposeActivities array: \(error.localizedDescription)")
                self.errorMessage = "Error removing activity: \(error.localizedDescription)"
            } else {
                print("Successfully removed activity with ID: \(activityId) from user's proposeActivities array.")
                
                // Remove activity from local array as well
                if let index = self.activities.firstIndex(where: { $0.id == activityId }) {
                    DispatchQueue.main.async {
                        self.activities.remove(at: index)
                    }
                }
            }
        }
    }
}

// ProposeActivityList View
struct ProposeActivityList: View {
    @StateObject private var viewModel = ProposeActivitiesViewModel()
    @State private var showDeleteAlert = false
    @State private var indexSetToDelete: IndexSet?

    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(viewModel.activities) { activity in
                        NavigationLink(destination: ActivityDetailsView(activity: activity)) {
                            ActivitiesRow(activity: activity)
                        }
                    }
                    .onDelete { indexSet in
                        self.indexSetToDelete = indexSet
                        self.showDeleteAlert = true
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .background(Color(white: 0.95))
                
                if viewModel.isLoading {
                    ProgressView()
                }
                
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Delete Activity"),
                    message: Text("Are you sure you want to delete this activity?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let indexSet = indexSetToDelete, let index = indexSet.first {
                            let activityId = viewModel.activities[index].id
                            viewModel.deleteActivity(activityId: activityId)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .background(Color.white)
        .onAppear {
            viewModel.fetchUserActivities()
        }
    }
}

// ActivitiesRow View
struct ActivitiesRow: View {
    let activity: ActivityData
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(activity.title)
                    .font(.headline)
                Text("from \(activity.groupName)")
                    .font(.subheadline)
            }
            Spacer()
        }
        .padding()
    }
}

// ActivityDetailsView
struct ActivityDetailsView: View {
    let activity: ActivityData
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text(activity.title)
                    .font(.title)
                Text("Group: \(activity.groupName)")
                    .font(.subheadline)
                Text("Group ID: \(activity.groupId)")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding()
            .background(Color.white)
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct ProposeActivityList_Previews: PreviewProvider {
    static var previews: some View {
        ProposeActivityList()
    }
}
