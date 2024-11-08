//
//  GroupDetailView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI

struct GroupDetailView: View {
    @State private var selectedDate = Date()
    @State private var showingJoinCodeSheet = false
    @State private var showingDeleteAlert = false
    @State private var itemToDelete: String?
    @State private var deleteType: DeleteType?
    @State private var proposedActivities = [
        GroupActivity(title: "October day out", from: "Ofiice"),
        GroupActivity(title: "Next hiking trip", from: "Office"),
        GroupActivity(title: "November party", from: "Office")
    ]
    @State private var groupMembers = [
        Members(name: "Dilanjana"),
        Members(name: "Lakshan"),
        Members(name: "Haritha"),
        Members(name: "Nisal"),
        Members(name: "Lakshika")
    ]
    
    
    
    @State private var proposeActvityId = ""
    @State private var groupCodeId: String = ""
    
    enum DeleteType {
        case activity
        case member
    }
    let groupCode: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Calendar Section
                GroupCalendarView(selectedDate: $selectedDate)
                    .padding(.horizontal)
                
                NavigationLink(destination: ProposeActivityView(activityId: proposeActvityId)) {
                    HStack {
                        Text("Propose an Activity")
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color("CustomBlue"))
                    .cornerRadius(50)
                }
                .padding(.horizontal)
                
                // Join Code Button
                Button(action: {
                    showingJoinCodeSheet = true
                }) {
                    HStack {
                        Text("Get Join Code or QR")
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color("DarkAsh"))
                    .cornerRadius(50)
                }
                .padding(.horizontal)
                
                // Proposed Activities Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Proposed Activities")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    List {
                        ForEach(proposedActivities) { activity in
                            NavigationLink(destination: VotingProposeActivityView()) {
                                ActivityRow(activity: activity)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    itemToDelete = activity.title
                                    deleteType = .activity
                                    showingDeleteAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .listRowInsets(EdgeInsets())
                            .background(Color(.systemBackground))
                        }
                    }
                    .listStyle(PlainListStyle())
                    .frame(height: CGFloat(proposedActivities.count * 70))
                }
                
                // Group Members Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Group Members (\(groupMembers.count))")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    List {
                        ForEach(groupMembers) { member in
                            MemberRow(member: member)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        itemToDelete = member.name
                                        deleteType = .member
                                        showingDeleteAlert = true
                                    } label: {
                                        Label("Remove", systemImage: "trash")
                                    }
                                }
                                .listRowInsets(EdgeInsets())
                                .background(Color(.systemBackground))
                        }
                    }
                    .listStyle(PlainListStyle())
                    .frame(height: CGFloat(groupMembers.count * 60))
                }
            }
        }
        .navigationTitle("Office")
        .navigationBarItems(trailing: NavigationLink("Edit", destination: EditGroupView()))
        .sheet(isPresented: $showingJoinCodeSheet) {
            JoinCodeSheet()
        }
        .alert(isPresented: $showingDeleteAlert) {
            switch deleteType {
            case .activity:
                return Alert(
                    title: Text("Delete Activity"),
                    message: Text("Are you sure you want to delete '\(itemToDelete ?? "")'?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let title = itemToDelete {
                            proposedActivities.removeAll { $0.title == title }
                        }
                    },
                    secondaryButton: .cancel()
                )
            case .member:
                return Alert(
                    title: Text("Remove Member"),
                    message: Text("Are you sure you want to remove '\(itemToDelete ?? "")'?"),
                    primaryButton: .destructive(Text("Remove")) {
                        if let name = itemToDelete {
                            groupMembers.removeAll { $0.name == name }
                        }
                    },
                    secondaryButton: .cancel()
                )
            case .none:
                return Alert(title: Text("Error"), message: Text("Unknown delete type"))
            }
        }
    }
}

struct GroupCalendarView: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        DatePicker(
            "Select Date",
            selection: $selectedDate,
            displayedComponents: [.date]
        )
        .datePickerStyle(GraphicalDatePickerStyle())
    }
}

struct ActivityRow: View {
    let activity: GroupActivity
    
    var body: some View {
        HStack(spacing: 16) {
            // Activity Info
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.system(size: 17))
                    .lineLimit(1)
                Text("from \(activity.from)")
                    .font(.system(size: 15))
                    .foregroundColor(Color(.systemGray))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
}

struct MemberRow: View {
    let member: Members
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color("CustomBlue"))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(member.name.prefix(1)))
                        .foregroundColor(.white)
                )
            
            Text(member.name)
                .padding(.leading, 8)
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct ProposeActivityDetailView: View {
    let activity: GroupActivity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Activity Details")
                .font(.title)
                .padding()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Title: \(activity.title)")
                    .font(.headline)
                Text("Proposed by: \(activity.from)")
                    .font(.subheadline)
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle(activity.title)
    }
}

struct JoinCodeSheet: View {
    let joinCode = "QB7825NG"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Copy join code or download\nQR code")
                    .multilineTextAlignment(.center)
                    .font(.title2)
                
                Spacer().frame(height: 20)
                
                ZStack {
                    // Main join code display
                    Text(joinCode)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray3), lineWidth: 2)
                        )
                        .padding(.horizontal, 10)
                    
                    // Copy button overlay
                    HStack {
                        Spacer()
                        Button(action: {
                            UIPasteboard.general.string = joinCode
                        }) {
                            Image(systemName: "doc.on.doc")
                                .padding()
                                .foregroundColor(Color("CustomBlue"))
                        }
                        .clipShape(Circle())
                        .padding(.trailing, 10)
                    }
                }
                
                Text("or")
                    .foregroundColor(.gray)
                
                Button(action: {
                    // Handle QR code download
                }) {
                    HStack {
                        Image(systemName: "qrcode")
                        Text("Download QR Code")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("CustomBlue"))
                    .foregroundColor(.white)
                    .cornerRadius(50)
                    .padding(.horizontal, 10)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitle("", displayMode: .inline)
        }
    }
}


// Models
struct GroupActivity: Identifiable {
    let id = UUID()
    let title: String
    let from: String
}

struct Members: Identifiable {
    let id = UUID()
    let name: String
}

// Preview Provider
struct GroupDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GroupDetailView(groupCode: "")
        }
    }
}
