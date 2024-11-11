//
//  ProposeActivityList.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-07.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

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

class ProposeActivitiesViewModel: ObservableObject {
    @Published var activities: [ActivityData] = []
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    
    private var db = Firestore.firestore()
    private var activityListeners: [ListenerRegistration] = []
    
    func fetchUserActivities() {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "No user logged in"
            return
        }
        
        isLoading = true
        print("Fetching activities for user with ID: \(userId)")
        
        let userListener = db.collection("users").document(userId)
            .addSnapshotListener { [weak self] documentSnapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = "Error fetching user data: \(error.localizedDescription)"
                    self.isLoading = false
                    return
                }
                
                guard let document = documentSnapshot,
                      let proposeActivities = document.data()?["proposeActivities"] as? [String] else {
                    DispatchQueue.main.async {
                        self.activities.removeAll()
                        self.isLoading = false
                    }
                    return
                }
                
                let cleanActivityIds = proposeActivities.map { $0.trimmingCharacters(in: .whitespaces) }
                
                self.removeListeners()
                self.fetchProposeActivities(activityIds: cleanActivityIds)
            }
        
        activityListeners.append(userListener)
    }
    
    private func fetchProposeActivities(activityIds: [String]) {
        DispatchQueue.main.async {
            self.activities.removeAll()
        }
        
        if activityIds.isEmpty {
            self.isLoading = false
            return
        }
        
        for activityId in activityIds {
            let listener = db.collection("proposeActivities")
                .document(activityId)
                .addSnapshotListener { [weak self] documentSnapshot, error in
                    guard let self = self else { return }
                    
                    if let error = error {
                        print("Error fetching activity \(activityId): \(error.localizedDescription)")
                        return
                    }
                    
                    guard let document = documentSnapshot,
                          document.exists,
                          let data = document.data() else {
                        print("No document found for activity ID: \(activityId)")
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
        
        DispatchQueue.main.async {
            self.isLoading = false
        }
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
        activityListeners.forEach { $0.remove() }
        activityListeners.removeAll()
    }
    
    func deleteActivity(activityId: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "No user logged in"
            return
        }
        
        let userRef = db.collection("users").document(userId)
        
        // Set loading state
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        userRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                self.errorMessage = "Error fetching user document: \(error.localizedDescription)"
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            guard let document = document,
                  var proposeActivities = document.data()?["proposeActivities"] as? [String] else {
                print("No proposeActivities found or document doesn't exist")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            // Remove the activity ID from the array
            proposeActivities.removeAll { $0.trimmingCharacters(in: .whitespaces) == activityId }
            
            // Update collection with the new array
            userRef.updateData([
                "proposeActivities": proposeActivities
            ]) { error in
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                
                if let error = error {
                    print("Error updating proposeActivities: \(error.localizedDescription)")
                    self.errorMessage = "Error updating proposeActivities: \(error.localizedDescription)"
                } else {
                    print("Successfully deleted activity with ID: \(activityId)")
                    // Remove the activity from local array immediately
                    DispatchQueue.main.async {
                        self.activities.removeAll { $0.id == activityId }
                    }
                }
            }
        }
    }
    
    deinit {
        removeListeners()
    }
}

struct ProposeActivityList: View {
    @StateObject private var viewModel = ProposeActivitiesViewModel()
    @State private var showDeleteAlert = false
    @State private var selectedActivityId: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(viewModel.activities) { activity in
                        NavigationLink(destination: VotingProposeActivityView()) {
                            ActivitiesRow(activity: activity)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                selectedActivityId = activity.id
                                showDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .background(Color(UIColor.systemGroupedBackground))
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
                }
                
                if viewModel.activities.isEmpty && !viewModel.isLoading {
                    Text("No proposed activities")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Delete Activity"),
                    message: Text("Are you sure you want to delete this activity?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let activityId = selectedActivityId {
                            viewModel.deleteActivity(activityId: activityId)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .onAppear {
            viewModel.fetchUserActivities()
        }
    }
}

struct ActivitiesRow: View {
    let activity: ActivityData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(activity.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("from \(activity.groupName)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct ActivityDetailsView: View {
    let activity: ActivityData
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(activity.title)
                    .font(.title)
                    .padding(.bottom, 8)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Group Details")
                        .font(.headline)
                    
                    Text(activity.groupName)
                        .font(.body)
                    
                    Text("ID: \(activity.groupId)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
                
                Spacer()
            }
            .padding()
        }
        .navigationBarBackButtonHidden(false)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProposeActivityList_Previews: PreviewProvider {
    static var previews: some View {
        ProposeActivityList()
    }
}
