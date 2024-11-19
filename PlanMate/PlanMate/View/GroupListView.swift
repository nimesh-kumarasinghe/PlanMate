//
//  GroupListView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// Empty state view
struct EmptyListStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3.sequence")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
            
            Text("No Groups Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Join or create a group to get started")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

// Updated GroupListView
struct GroupListView: View {
    @StateObject private var viewModel = FirebaseGroupViewModel()
    @State private var showAlert = false
    @State private var groupToLeave: UserGroup?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.groups.isEmpty {
                    EmptyListStateView()
                } else {
                    List {
                        ForEach(viewModel.groups) { group in
                            NavigationLink(destination: GroupDetailView(groupCode: group.groupCode)) {
                                HStack(spacing: 15) {
                                    // Group Profile Image
                                    if let imageURL = group.profileImageURL, !imageURL.isEmpty {
                                        AsyncImage(url: URL(string: imageURL)) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 50, height: 50)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                        } placeholder: {
                                            ProgressView()
                                                .frame(width: 50, height: 50)
                                        }
                                    } else {
                                        Image("defaultimg")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 50, height: 50)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(group.groupName)
                                            .font(.headline)
                                        Text("\(group.memberCount) members")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    groupToLeave = group
                                    showAlert = true
                                } label: {
                                    Text("Leave")
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .alert("Leave Group", isPresented: $showAlert, presenting: groupToLeave) { group in
                Button("Leave", role: .destructive) {
                    viewModel.leaveGroup(group: group)
                }
                Button("Cancel", role: .cancel) {}
            } message: { group in
                Text("Are you sure you want to leave \(group.groupName)?")
            }
            .navigationBarTitle("My Groups", displayMode: .inline)
            .background(Color.white)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.blue)
                            Text("Back")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.fetchUserGroups()
        }
        .toolbar(.hidden, for: .tabBar)
    }
}

struct GroupsView_Previews: PreviewProvider {
    static var previews: some View {
        GroupListView()
    }
}
