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
import Foundation

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
