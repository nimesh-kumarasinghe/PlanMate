//
//  HomeView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import Network
import CoreData

// Models
struct HomeGroupModel: Identifiable {
    let id: String
    let groupName: String
    let description: String
    let groupCode: String
    let createdBy: String
    let members: [String]
    let profileImageURL: String?
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

class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    @Published var isConnected = true
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}

extension HomeViewModel {
    // Download and save image data
    private func downloadAndSaveImage(from urlString: String, for groupId: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let imageData = data,
                  error == nil else {
                print("Error downloading image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self.saveImageToStorage(imageData, for: groupId)
            }
        }.resume()
    }
    
    // Save image data to Core Data
    private func saveImageToStorage(_ imageData: Data, for groupId: String) {
        let context = CoreDataHelper.shared.context
        
        let fetchRequest: NSFetchRequest<Group> = Group.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", groupId)
        
        do {
            let existingGroups = try context.fetch(fetchRequest)
            if let group = existingGroups.first {
                group.profileImage = imageData
                try context.save()
            }
        } catch {
            print("Error saving image to Core Data: \(error)")
        }
    }
    
    // saveGroupToStorage method
    private func saveGroupToStorage(_ group: HomeGroupModel) {
        let context = CoreDataHelper.shared.context
        
        let fetchRequest: NSFetchRequest<Group> = Group.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", group.id)
        
        do {
            let existingGroups = try context.fetch(fetchRequest)
            let cdGroup: Group
            
            if let existingGroup = existingGroups.first {
                cdGroup = existingGroup
            } else {
                cdGroup = Group(context: context)
                cdGroup.id = group.id
            }
            
            // Update properties
            cdGroup.groupName = group.groupName
            cdGroup.groupDescription = group.description
            cdGroup.groupCode = group.groupCode
            cdGroup.createdBy = group.createdBy
            cdGroup.members = group.members as NSObject
            cdGroup.profileImageURL = group.profileImageURL
            
            // Download and save image if URL exists and image isn't already cached
            if let imageURL = group.profileImageURL,
               !imageURL.isEmpty,
               cdGroup.profileImage == nil {
                downloadAndSaveImage(from: imageURL, for: group.id)
            }
            
            try context.save()
        } catch {
            print("Error saving group to Core Data: \(error)")
        }
    }
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
    
    @StateObject private var networkMonitor = NetworkMonitor()
    
    func fetchUserData(userId: String) {
        guard !userId.isEmpty else {
            self.errorMessage = "Invalid user ID"
            return
        }
        
        isLoading = true
        clearExistingData()
        
        if networkMonitor.isConnected {
            fetchOnlineData(userId: userId)
        } else {
            fetchOfflineData()
        }
    }
    
    private func fetchOnlineData(userId: String) {
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
            
            let groupIds = userData["groups"] as? [String] ?? []
            let activityIds = userData["proposeActivities"] as? [String] ?? []
            
            self.fetchLimitedGroups(groupIds: groupIds)
            self.fetchProposeActivities(activityIds: activityIds)
        }
    }
    
    private func fetchOfflineData() {
        let context = CoreDataHelper.shared.context
        
        // Fetch groups from Core Data
        let groupFetchRequest: NSFetchRequest<Group> = Group.fetchRequest()
        groupFetchRequest.fetchLimit = 4
        
        do {
            let cdGroups = try context.fetch(groupFetchRequest)
            self.homeGroups = cdGroups.map { cdGroup in
                HomeGroupModel(
                    id: cdGroup.id ?? "",
                    groupName: cdGroup.groupName ?? "",
                    description: cdGroup.groupDescription ?? "",
                    groupCode: cdGroup.groupCode ?? "",
                    createdBy: cdGroup.createdBy ?? "",
                    members: cdGroup.members as? [String] ?? [],
                    profileImageURL: cdGroup.profileImageURL
                )
            }
        } catch {
            print("Error fetching groups from Core Data: \(error)")
        }
        
        // Fetch activities from Core Data
        let activityFetchRequest: NSFetchRequest<CachedActivity> = CachedActivity.fetchRequest()
        activityFetchRequest.fetchLimit = 6
        
        do {
            let cdActivities = try context.fetch(activityFetchRequest)
            self.homeProposeActivities = cdActivities.map { cdActivity in
                HomeProposeActivityModel(
                    id: cdActivity.id ?? "",
                    groupId: cdActivity.groupId ?? "",
                    groupName: cdActivity.groupName ?? "",
                    title: cdActivity.title ?? ""
                )
            }
        } catch {
            print("Error fetching activities from Core Data: \(error)")
        }
        
        self.isLoading = false
    }
    
    
    
    private func saveActivityToStorage(_ activity: HomeProposeActivityModel) {
        let context = CoreDataHelper.shared.context
        
        // Check if activity already exists
        let fetchRequest: NSFetchRequest<CachedActivity> = CachedActivity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", activity.id)
        
        do {
            let existingActivities = try context.fetch(fetchRequest)
            let cdActivity: CachedActivity
            
            if let existingActivity = existingActivities.first {
                cdActivity = existingActivity
            } else {
                cdActivity = CachedActivity(context: context)
                cdActivity.id = activity.id
            }
            
            // Update properties
            cdActivity.groupId = activity.groupId
            cdActivity.groupName = activity.groupName
            cdActivity.title = activity.title
            
            try context.save()
        } catch {
            print("Error saving activity to Core Data: \(error)")
        }
        if let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            print("Core Data SQLite file path: \(url.path)")
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
                            // Save to Core Data
                            self.saveGroupToStorage(group)
                        }
                    }
                }
            
            groupListeners.append(listener)
        }
    }
    
    // fetch propose activities
    private func fetchProposeActivities(activityIds: [String]) {
        let limitedActivityIds = Array(activityIds.prefix(6))
        
        for activityId in limitedActivityIds {
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
                            // Save to Core Data
                            self.saveActivityToStorage(activity)
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
        
        let profileImageURL = data["profileImageURL"] as? String
        
        return HomeGroupModel(
            id: document.documentID,
            groupName: groupName,
            description: description,
            groupCode: groupCode,
            createdBy: createdBy,
            members: members,
            profileImageURL: profileImageURL
        )
    }
    
    // activity parser
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
    @StateObject private var networkMonitor = NetworkMonitor()
    
    var body: some View {
        NavigationView {
            ZStack{
                if viewModel.isLoading {
                    ProgressView("Loading...")
                }
                else{
                    ScrollView {
                        if !networkMonitor.isConnected {
                            HStack {
                                Image(systemName: "wifi.slash")
                                Text("Offline Mode")
                            }
                            .padding()
                            .background(Color.yellow.opacity(0.3))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
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
                                    NavigationLink(destination: NotificationsView() .navigationBarTitle("Notifications")) {
                                        Image(systemName: "bell")
                                            .foregroundColor(.black)
                                    }
                                    NavigationLink(destination: MyAccountView() .navigationBarHidden(true)) {
                                        if let profileURL = viewModel.profileImageURL, !profileURL.isEmpty {
                                            AsyncImage(url: URL(string: profileURL)) { image in
                                                image
                                                    .resizable()
                                                    .clipShape(Circle())
                                                    .frame(width: 30, height: 30)
                                            } placeholder: {
                                                ProgressView()
                                            }
                                        } else {
                                            Circle()
                                                .fill(Color("CustomBlue"))
                                                .frame(width: 30, height: 30)
                                                .overlay(
                                                    Image(systemName: "person.fill")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .foregroundColor(.white)
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
    @Environment(\.managedObjectContext) private var viewContext
    @State private var offlineImage: UIImage?
    
    private func loadOfflineImage() {
        let fetchRequest: NSFetchRequest<Group> = Group.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", group.id)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            if let group = results.first,
               let imageData = group.profileImage,
               let image = UIImage(data: imageData) {
                offlineImage = image
            }
        } catch {
            print("Error fetching offline image: \(error)")
        }
    }

    var body: some View {
        NavigationLink(destination: GroupDetailView(groupCode: group.groupCode)) {
            VStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue.opacity(0.1))
                    .frame(height: 100)
                    .overlay(
                        ZStack {
                            if let imageURL = group.profileImageURL, !imageURL.isEmpty {
                                if let offlineImage = offlineImage {
                                    Image(uiImage: offlineImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                } else {
                                    AsyncImage(url: URL(string: imageURL)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    } placeholder: {
                                        ProgressView()
                                    }
                                }
                            } else {
                                Image("defaultimg")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    )
                Text(group.groupName)
                    .fontWeight(.medium)
            }
        }
        .foregroundColor(.primary)
        .onAppear {
            loadOfflineImage()
        }
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
