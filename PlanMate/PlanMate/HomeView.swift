//
//  HomeView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI
import Firebase
import FirebaseFirestore

// Models
struct HomeGroupModel: Identifiable {
    let id: String
    let groupName: String
    let description: String
    let groupCode: String
    let createdBy: String
    let members: [String]
}

struct HomeProposeActivityModel: Identifiable {
    let id: String
    let groupId: String
    let groupName: String
    let title: String
}

struct HomeUserModel {
    let uid: String
    let name: String
    let email: String
    let groups: [String]
    let proposeActivities: [String]
}

// ViewModel
class HomeViewModel: ObservableObject {
    @Published var homeGroups: [HomeGroupModel] = []
    @Published var homeProposeActivities: [HomeProposeActivityModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var profileImageURL: String?
    
    private var db = Firestore.firestore()
    private var groupListeners: [ListenerRegistration] = []
    private var activityListeners: [ListenerRegistration] = []
    
    func fetchUserData(userId: String) {
            guard !userId.isEmpty else {
                self.errorMessage = "Invalid user ID"
                return
            }
            
            isLoading = true
            clearExistingData()
            
            // Listen to real-time updates on the user document
            db.collection("users").document(userId).addSnapshotListener { [weak self] documentSnapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    return
                }
                
                guard let document = documentSnapshot, document.exists,
                      let userData = document.data() else {
                    self.errorMessage = "User data not found"
                    self.isLoading = false
                    return
                }
                
                self.profileImageURL = userData["profileImageURL"] as? String
                
                // Get user's groups and activities
                let groupIds = userData["groups"] as? [String] ?? []
                let activityIds = userData["proposeActivities"] as? [String] ?? []
                
                // Fetch limited data for better performance
                self.fetchLimitedGroups(groupIds: groupIds)
                self.fetchProposeActivities(activityIds: activityIds)
            }
        }
    
    private func fetchLimitedGroups(groupIds: [String]) {
        // Take only the first 4 groups
        let limitedGroupIds = Array(groupIds.prefix(4))
        
        for groupId in limitedGroupIds {
            let listener = db.collection("groups")
                .whereField("groupCode", isEqualTo: groupId)
                .limit(to: 1)
                .addSnapshotListener { [weak self] querySnapshot, error in
                    guard let self = self else { return }
                    
                    if let error = error {
                        self.errorMessage = "Error fetching group: \(error.localizedDescription)"
                        return
                    }
                    
                    guard let document = querySnapshot?.documents.first else {
                        return
                    }
                    
                    let data = document.data()
                    
                    if let group = self.parseGroupData(document: document, data: data) {
                        DispatchQueue.main.async {
                            // Update or append group
                            if let index = self.homeGroups.firstIndex(where: { $0.id == group.id }) {
                                self.homeGroups[index] = group
                            } else {
                                self.homeGroups.append(group)
                            }
                        }
                    }
                }
            
            groupListeners.append(listener)
        }
    }
    
    // Updated method to fetch propose activities
        private func fetchProposeActivities(activityIds: [String]) {
            // Take only the first 4 activities
            let limitedActivityIds = Array(activityIds.prefix(6))
            
            for activityId in limitedActivityIds {
                // Remove any leading/trailing whitespace from activity ID
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
                        
                        // Create activity model using the updated parser
                        if let activity = self.parseActivityData(document: document, data: data) {
                            DispatchQueue.main.async {
                                if let index = self.homeProposeActivities.firstIndex(where: { $0.id == activity.id }) {
                                    self.homeProposeActivities[index] = activity
                                } else {
                                    self.homeProposeActivities.append(activity)
                                }
                            }
                        }
                    }
                
                activityListeners.append(listener)
            }
            
            isLoading = false
        }
    
    private func parseGroupData(document: QueryDocumentSnapshot, data: [String: Any]) -> HomeGroupModel? {
           guard let groupName = data["groupName"] as? String,
                 let description = data["description"] as? String,
                 let groupCode = data["groupCode"] as? String,
                 let createdBy = data["createdBy"] as? String,
                 let members = data["members"] as? [String] else {
               return nil
           }
           
           return HomeGroupModel(
               id: document.documentID,
               groupName: groupName,
               description: description,
               groupCode: groupCode,
               createdBy: createdBy,
               members: members
           )
       }
       
    // Updated activity parser to match your Firestore structure
        private func parseActivityData(document: DocumentSnapshot, data: [String: Any]) -> HomeProposeActivityModel? {
            guard let groupId = data["groupId"] as? String,
                  let groupName = data["groupName"] as? String,
                  let title = data["title"] as? String else {
                print("Failed to parse activity data: \(data)")
                return nil
            }
            return HomeProposeActivityModel(
                id: document.documentID,
                groupId: groupId,
                groupName: groupName,
                title: title
            )
        }
       
       private func clearExistingData() {
           // Remove existing listeners
           groupListeners.forEach { $0.remove() }
           activityListeners.forEach { $0.remove() }
           groupListeners.removeAll()
           activityListeners.removeAll()
           
           // Clear existing data
           homeGroups.removeAll()
           homeProposeActivities.removeAll()
           errorMessage = nil
       }
       
       // Clean up when the view model is deallocated
       deinit {
           clearExistingData()
       }
}

struct HomeView: View {
    @AppStorage("user_name") private var userName: String = ""
    @AppStorage("userid") private var userid: String = ""
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ZStack{
                if viewModel.isLoading {
                    ProgressView("Loading...")
                }
                else{
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Header
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Hello!")
                                        .font(.title)
                                        .fontWeight(.bold)
                                    Text("\(userName)")
                                        .font(.title2)
                                }
                                Spacer()
                                HStack(spacing: 15) {
                                    NavigationLink(destination: NotificationsView()) {
                                        Image(systemName: "bell")
                                            .foregroundColor(.black)
                                    }
                                    NavigationLink(destination: MyAccountView() .navigationBarHidden(false)) {
                                        if let profileURL = viewModel.profileImageURL, !profileURL.isEmpty {
                                            AsyncImage(url: URL(string: profileURL)) { image in
                                                image
                                                    .resizable()
                                                    .clipShape(Circle())
                                                    .frame(width: 30, height: 30)
                                                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                            } placeholder: {
                                                ProgressView()
                                            }
                                        } else {
                                            Circle()
                                                .fill(Color.blue.opacity(0.1))
                                                .frame(width: 30, height: 30)
                                                .overlay(
                                                    Image(systemName: "person.fill")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .foregroundColor(.blue)
                                                        .frame(width: 20, height: 20)
                                                )
                                        }
                                    }
                                }
                                .font(.title2)
                            }
                            .padding(.horizontal)
                            
                            // Action Buttons
                            VStack(spacing: 10) {
                                NavigationLink(destination: CreateGroupView()) {
                                    HStack {
                                        Text("Create a group")
                                            .fontWeight(.medium)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }
                                    .padding()
                                    .background(Color("CustomBlue"))
                                    .foregroundColor(.white)
                                    .cornerRadius(50)
                                }
                                
                                NavigationLink(destination: JoinGroupView()) {
                                    HStack {
                                        Text("Join a group")
                                            .fontWeight(.medium)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }
                                    .padding()
                                    .background(Color("DarkAsh"))
                                    .foregroundColor(.white)
                                    .cornerRadius(50)
                                }
                            }
                            .padding(.horizontal)
                            
                            // My Groups Section
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("My groups")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                    Spacer()
                                    NavigationLink("view all") {
                                        GroupListView()
                                            .navigationTitle("My Groups")
                                    }
                                }
                                
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 15) {
                                    ForEach(viewModel.homeGroups) { group in
                                        GroupCard(group: group)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            // Proposed Activities Section (updated)
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Proposed Activities")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                    Spacer()
                                    NavigationLink("view all") {
                                        ProposeActivityList()
                                            .navigationTitle("Proposed Activities")
                                    }
                                }
                                
                                VStack(spacing: 10) {
                                    ForEach(viewModel.homeProposeActivities) { activity in
                                        ActivityListCard(
                                            title: activity.title,
                                            group: activity.groupName,
                                            activityId: activity.id
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                }
            }
            .alert(viewModel.errorMessage ?? "Error", isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {
                    viewModel.errorMessage = nil
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear{
            viewModel.fetchUserData(userId: userid)
        }
    }
}

// Helper for error alerts
struct ErrorWrapper: Identifiable {
    let id = UUID()
    let error: String
}

struct GroupCard: View {
    let group: HomeGroupModel
    
    var body: some View {
        NavigationLink(destination: GroupDetailView(groupCode: group.groupCode)) {
            VStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue.opacity(0.1))
                    .frame(height: 100)
                    .overlay(
                        Image("defaultimg")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 90)
                    )
                Text(group.groupName)
                    .fontWeight(.medium)
            }
        }
        .foregroundColor(.primary)
    }
}

struct ActivityListCard: View {
    let title: String
    let group: String
    let activityId: String
    
    var body: some View {
        NavigationLink(destination: VotingProposeActivityView(proposeActivityId: activityId)) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .fontWeight(.medium)
                    Text("from \(group)")
                        .font(.subheadline)
                        .foregroundColor(Color("DarkAsh"))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color("DarkAsh"))
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
        }
        .foregroundColor(.primary)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
