//
//  GroupDetailView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI
import Firebase
import FirebaseFirestore

class GroupDetailViewModel: ObservableObject {
    @Published var groupName: String = ""
    @Published var groupMembers: [String] = []
    @Published var memberNames: [String: String] = [:]
    @Published var proposeActivities: [HomeProposeActivityModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []
    
    func fetchGroupDetails(groupCode: String) {
        isLoading = true
        
        let listener = db.collection("groups")
            .whereField("groupCode", isEqualTo: groupCode)
            .limit(to: 1)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    return
                }
                
                guard let document = querySnapshot?.documents.first,
                      let data = document.data() as? [String: Any] else {
                    self.errorMessage = "Group not found"
                    self.isLoading = false
                    return
                }
                
                self.groupName = data["groupName"] as? String ?? ""
                self.groupMembers = data["members"] as? [String] ?? []
                
                // Fetch member names
                self.fetchMemberNames(memberIds: self.groupMembers)
                
                // Fetch propose activities
                if let activityIds = data["proposeActivities"] as? [String] {
                    self.fetchProposeActivities(activityIds: activityIds)
                }
                
                self.isLoading = false
            }
        
        listeners.append(listener)
    }
    
    private func fetchMemberNames(memberIds: [String]) {
        for memberId in memberIds {
            let listener = db.collection("users").document(memberId)
                .addSnapshotListener { [weak self] documentSnapshot, error in
                    guard let self = self else { return }
                    
                    if let error = error {
                        print("Error fetching member name: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let document = documentSnapshot, document.exists,
                          let data = document.data(),
                          let name = data["name"] as? String else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.memberNames[memberId] = name
                    }
                }
            
            listeners.append(listener)
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
                        return
                    }
                    
                    guard let document = documentSnapshot,
                          document.exists,
                          let data = document.data() else {
                        return
                    }
                    
                    let activity = HomeProposeActivityModel(
                        id: document.documentID,
                        groupId: data["groupId"] as? String ?? "",
                        groupName: data["groupName"] as? String ?? "",
                        title: data["title"] as? String ?? ""
                    )
                    
                    DispatchQueue.main.async {
                        if !self.proposeActivities.contains(where: { $0.id == activity.id }) {
                            self.proposeActivities.append(activity)
                        }
                    }
                }
            
            listeners.append(listener)
        }
    }
    
    deinit {
        listeners.forEach { $0.remove() }
    }
}

// Action Buttons Component
struct GroupActionButtons: View {
    let proposeActivityAction: () -> Void
    let showJoinCodeAction: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            // Propose Activity Button
            Button(action: proposeActivityAction) {
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
            
            // Join Code Button
            Button(action: showJoinCodeAction) {
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
        }
        .padding(.horizontal)
    }
}

// Proposed Activities Section
struct ProposedActivitiesSection: View {
    let activities: [HomeProposeActivityModel]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Proposed Activities")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(activities) { activity in
                NavigationLink(destination: VotingProposeActivityView()) {
                    ActivityListCard(title: activity.title, group: activity.groupName)
                }
            }
        }
        .padding(.horizontal)
    }
}

// Group Members Section
struct GroupMembersSection: View {
    let members: [String]
    let memberNames: [String: String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Group Members (\(members.count))")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(members, id: \.self) { memberId in
                MemberRow(
                    member: Members(name: memberNames[memberId] ?? "Unknown")
                )
            }
        }
        .padding(.horizontal)
    }
}

struct GroupDetailView: View {
    @StateObject private var viewModel = GroupDetailViewModel()
    @State private var selectedDate = Date()
    @State private var showingJoinCodeSheet = false
    
    let groupCode: String
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 20) {
                    // Calendar Section
                    GroupCalendarView(selectedDate: $selectedDate)
                        .padding(.horizontal)
                    
                    // Action Buttons
                    GroupActionButtons(
                        proposeActivityAction: {
                            // Handle propose activity navigation
                        },
                        showJoinCodeAction: {
                            showingJoinCodeSheet = true
                        }
                    )
                    
                    // Proposed Activities
                    ProposedActivitiesSection(activities: viewModel.proposeActivities)
                    
                    // Group Members
                    GroupMembersSection(members: viewModel.groupMembers, memberNames: viewModel.memberNames)
                }
            }
        }
        .navigationTitle(viewModel.groupName)
        .navigationBarItems(trailing: NavigationLink("Edit", destination: EditGroupView()))
        .sheet(isPresented: $showingJoinCodeSheet) {
            JoinCodeSheet()
        }
        .alert(item: Binding(
            get: { viewModel.errorMessage.map { ErrorWrapper(error: $0) } },
            set: { viewModel.errorMessage = $0?.error }
        )) { errorWrapper in
            Alert(
                title: Text("Error"),
                message: Text(errorWrapper.error),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            viewModel.fetchGroupDetails(groupCode: groupCode)
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

struct MemberRow: View {
    let member: Members
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .foregroundColor(Color("CustomBlue"))
                .frame(width: 35, height: 35)
            
            Text(member.name)
                .padding(.leading, 8)
            
            Spacer()
        }
        .padding(.horizontal)
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
                    Text(joinCode)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray3), lineWidth: 2)
                        )
                        .padding(.horizontal, 10)
                    
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
            .navigationTitle("Join Code")
            .navigationBarTitleDisplayMode(.inline)
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
