//
//  ProposeActivityList.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-07.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Foundation

struct ProposeActivityList: View {
    @StateObject private var viewModel = ProposeActivitiesViewModel()
    @State private var showDeleteAlert = false
    @State private var selectedActivityId: String?
    @Environment(\.presentationMode) var presentationMode 
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(viewModel.activities) { activity in
                        NavigationLink(destination: VotingProposeActivityView(proposeActivityId: activity.id)) {
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
                .navigationBarTitle("Propose Activities", displayMode: .inline)
                .background(Color(UIColor.systemGroupedBackground))
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
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
                }
                
                if viewModel.activities.isEmpty && !viewModel.isLoading {
                    VStack(spacing: 20) {
                        Image(systemName: "calendar.badge.plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                        
                        Text("No Proposed Activities")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Activities proposed by your groups will appear here")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
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
        .navigationBarHidden(true)
        .onAppear {
            viewModel.fetchUserActivities()
        }
        .toolbar(.hidden, for: .tabBar)
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
