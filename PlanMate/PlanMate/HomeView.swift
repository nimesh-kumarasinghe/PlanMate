//
//  HomeView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI

struct HomeView: View {
    @AppStorage("user_name") private var userName: String = ""
    @AppStorage("userid") private var userid: String = ""
    
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
                            Text("\(userName)")
                                .font(.title2)
                        }
                        Spacer()
                        HStack(spacing: 15) {
                            // Bell icon navigation link
                            NavigationLink(destination: NotificationsView()) {
                                Image(systemName: "bell")
                                    .foregroundColor(.black)
                            }
                            
                            // Profile icon navigation link
                            NavigationLink(destination: MyAccountView()) {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
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
                            }
                        }
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 15) {
                            GroupCard(name: "Office", imageName: "defaultimg")
                            GroupCard(name: "Friends", imageName: "defaultimg")
                            GroupCard(name: "Cousins", imageName: "defaultimg")
                            GroupCard(name: "Trip Friends", imageName: "defaultimg")
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
                                ProposeActivityList()
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
            //.navigationBarHidden(true)
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
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 90)
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
