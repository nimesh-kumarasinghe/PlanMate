//
//  HomeView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI

//struct MainHomeView: View {
//    var body: some View {
//        TabView {
//            HomeView()
//                .tabItem {
//                    Image(systemName: "house.fill")
//                    Text("Home")
//                }
//            
//            Text("Calendar")
//                .tabItem {
//                    Image(systemName: "calendar")
//                    Text("Calendar")
//                }
//            
//            CreateActivityView()
//                .tabItem {
//                    Image(systemName: "plus.circle.fill")
//                    Text("Create")
//                }
//            
//            ActivityListView()
//                .tabItem {
//                    Image(systemName: "list.bullet")
//                    Text("Activities")
//                }
//        }
//    }
//}

struct HomeView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Hello!")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Nimesh Kumarasinghe")
                                .font(.title2)
                        }
                        Spacer()
                        HStack(spacing: 15) {
                            Image(systemName: "bell")
                            Image(systemName: "person.circle.fill")
                        }
                        .font(.title2)
                    }
                    .padding(.horizontal)
                    
                    // Action Buttons
                    VStack(spacing: 10) {
                        NavigationLink(destination: Text("Create Group")) {
                            HStack {
                                Text("Create a group")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        NavigationLink(destination: Text("Join Group")) {
                            HStack {
                                Text("Join a group")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
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
                                Text("All Groups")
                            }
                        }
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 15) {
                            GroupCard(name: "Office", imageName: "office")
                            GroupCard(name: "Friends", imageName: "friends")
                            GroupCard(name: "Cousins", imageName: "cousins")
                            GroupCard(name: "Trip Friends", imageName: "tripfriends")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Proposed Activities Section
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Proposed Activities")
                                .font(.title3)
                                .fontWeight(.bold)
                            Spacer()
                            NavigationLink("view all") {
                                Text("All Activities")
                            }
                        }
                        
                        VStack(spacing: 10) {
                            ActivityListCard(title: "October day out", group: "Cousins")
                            ActivityListCard(title: "Next hiking trip", group: "Trip Friends")
                            ActivityListCard(title: "November party", group: "Office")
                            ActivityListCard(title: "Next day out", group: "Friends")
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
        }
    }
}

struct GroupCard: View {
    let name: String
    let imageName: String
    
    var body: some View {
        NavigationLink(destination: Text(name)) {
            VStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue.opacity(0.1))
                    .frame(height: 100)
                    .overlay(
                        Text("👥")
                            .font(.system(size: 40))
                    )
                Text(name)
                    .fontWeight(.medium)
            }
        }
        .foregroundColor(.primary)
    }
}

struct ActivityListCard: View {
    let title: String
    let group: String
    
    var body: some View {
        NavigationLink(destination: Text(title)) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .fontWeight(.medium)
                    Text("from \(group)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
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
