//
//  GroupDetailView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import CoreImage.CIFilterBuiltins
import CoreData

class GroupDetailViewModel: ObservableObject {
    @Published var groupName: String = ""
    @Published var groupDescription: String = ""
    @Published var groupMembers: [String] = []
    @Published var memberNames: [String: String] = [:]
    @Published var proposeActivities: [HomeProposeActivityModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    @AppStorage("userid") private var userid: String = ""
    
    private var db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []
    private let context = CoreDataHelper.shared.context
    
    func fetchGroupDetails(groupCode: String) {
        isLoading = true
        proposeActivities.removeAll()
        memberNames.removeAll()
        
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
                
                guard let document = querySnapshot?.documents.first else {
                    self.errorMessage = "Group not found"
                    self.isLoading = false
                    return
                }
                
                let data = document.data()
                
                DispatchQueue.main.async {
                    self.groupName = data["groupName"] as? String ?? ""
                    self.groupDescription = data["description"] as? String ?? ""
                    self.groupMembers = data["members"] as? [String] ?? []
                }
                
                // Save group data to Core Data
                self.saveGroupToCoreData(data: data, groupCode: groupCode)
                
                // Fetch related data
                self.fetchMemberNames(memberIds: data["members"] as? [String] ?? [])
                if let activityIds = data["proposeActivities"] as? [String] {
                    self.fetchProposeActivities(forUserId: self.userid, groupCode: groupCode)
                }
                
                self.isLoading = false
            }
        
        listeners.append(listener)
        
        if let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            print("Core Data SQLite file path: \(url.path)")
        }

    }
    
    private func fetchMemberNames(memberIds: [String]) {
        DispatchQueue.main.async {
            self.memberNames.removeAll()
        }
        
        for memberId in memberIds {
            let listener = db.collection("users")
                .document(memberId.trimmingCharacters(in: .whitespaces))
                .addSnapshotListener { [weak self] documentSnapshot, error in
                    guard let self = self else { return }
                    
                    if let error = error {
                        print("Error fetching member name: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let document = documentSnapshot, document.exists,
                          let data = document.data(), let name = data["name"] as? String else { return }
                    
                    DispatchQueue.main.async {
                        self.memberNames[memberId] = name
                        self.saveMemberToCoreData(userId: memberId, name: name)
                    }
                }
            
            listeners.append(listener)
        }
    }
    
    private func fetchProposeActivities(forUserId userId: String, groupCode: String) {
        let userRef = db.collection("users").document(userId)
        userRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data(),
                  let activityIds = data["proposeActivities"] as? [String] else {
                return
            }
            
            DispatchQueue.main.async {
                self.proposeActivities.removeAll()
            }
            
            for activityId in activityIds {
                self.db.collection("proposeActivities").document(activityId).getDocument { [weak self] documentSnapshot, error in
                    guard let self = self else { return }
                    
                    if let error = error {
                        print("Error fetching activity: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let document = documentSnapshot, document.exists,
                          let data = document.data() else { return }
                    
                    if let activityGroupId = data["groupId"] as? String, activityGroupId == groupCode {
                        let activity = HomeProposeActivityModel(
                            id: document.documentID,
                            groupId: data["groupId"] as? String ?? "",
                            groupName: data["groupName"] as? String ?? "",
                            title: data["title"] as? String ?? ""
                        )
                        
                        DispatchQueue.main.async {
                            if !self.proposeActivities.contains(where: { $0.id == activity.id }) {
                                self.proposeActivities.append(activity)
                                self.saveActivityToCoreData(activity: activity)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func saveGroupToCoreData(data: [String: Any], groupCode: String) {
        let fetchRequest: NSFetchRequest<Group> = Group.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "groupCode == %@", groupCode)
        
        if let existingGroup = try? context.fetch(fetchRequest).first {
            existingGroup.groupName = data["groupName"] as? String ?? ""
            existingGroup.groupDescription = data["description"] as? String ?? ""
            existingGroup.members = NSArray(array: data["members"] as? [String] ?? [])
            existingGroup.lastUpdated = Date()
        } else {
            let newGroup = Group(context: context)
            newGroup.groupCode = groupCode
            newGroup.groupName = data["groupName"] as? String ?? ""
            newGroup.groupDescription = data["description"] as? String ?? ""
            newGroup.members = NSArray(array: data["members"] as? [String] ?? [])
            newGroup.lastUpdated = Date()
        }
        
        CoreDataHelper.shared.saveContext()
    }
    
    private func saveMemberToCoreData(userId: String, name: String) {
        let fetchRequest: NSFetchRequest<CachedMember> = CachedMember.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %@", userId)
        
        if let existingMember = try? context.fetch(fetchRequest).first {
            existingMember.name = name
        } else {
            let newMember = CachedMember(context: context)
            newMember.userId = userId
            newMember.name = name
        }
        
        CoreDataHelper.shared.saveContext()
    }
    
    private func saveActivityToCoreData(activity: HomeProposeActivityModel) {
        let fetchRequest: NSFetchRequest<CachedActivity> = CachedActivity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", activity.id)
        
        if let existingActivity = try? context.fetch(fetchRequest).first {
            existingActivity.groupName = activity.groupName
            existingActivity.title = activity.title
        } else {
            let newActivity = CachedActivity(context: context)
            newActivity.id = activity.id
            newActivity.groupName = activity.groupName
            newActivity.title = activity.title
        }
        
        CoreDataHelper.shared.saveContext()
    }
}

// Action Buttons Component
struct GroupActionButtons: View {
    let groupId: String
        let groupName: String
        let members: [GroupMember]
        @Binding var showingProposeActivitySheet: Bool
        @Binding var showingJoinCodeSheet: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            // Propose Activity Button
            Button(action: {
                showingProposeActivitySheet = true
            }) {
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
                
                NavigationLink(destination: VotingProposeActivityView(proposeActivityId: activity.id)) {
                    ActivityListCard(title: activity.title, group: activity.groupName, activityId: activity.id)
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
    @State private var showingProposeActivitySheet = false
    
    var groupMembers: [GroupMember] {
        viewModel.groupMembers.compactMap { memberId in
            GroupMember(name: viewModel.memberNames[memberId] ?? "Unknown", uid: memberId)
        }
    }
    
    let groupCode: String
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                VStack {
                    Spacer()
                    ProgressView("Loading group details...")
                    Spacer()
                }
                .frame(maxWidth: .infinity, minHeight: 300)
            } else {
                VStack(spacing: 20) {
                    // Group Info Section
                    VStack(alignment: .leading, spacing: 8) {
                        if !viewModel.groupDescription.isEmpty {
                            Text(viewModel.groupDescription)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        }
                    }
                    
                    // Calendar Section
                    GroupCalendarView(selectedDate: $selectedDate)
                        .padding(.horizontal)
                    
                    // Action Buttons
                    GroupActionButtons(
                        groupId: groupCode,
                        groupName: viewModel.groupName,
                        members: groupMembers,
                        showingProposeActivitySheet: $showingProposeActivitySheet,
                        showingJoinCodeSheet: $showingJoinCodeSheet
                    )
                    
                    // Proposed Activities
                    if !viewModel.proposeActivities.isEmpty {
                        ProposedActivitiesSection(activities: viewModel.proposeActivities)
                    }
                    
                    // Group Members
                    if !viewModel.groupMembers.isEmpty {
                        GroupMembersSection(
                            members: viewModel.groupMembers,
                            memberNames: viewModel.memberNames
                        )
                    }
                }
            }
        }
        .navigationTitle(viewModel.groupName)
        .navigationBarItems(trailing: NavigationLink("Edit", destination: EditGroupView(groupName: viewModel.groupName, description: viewModel.groupDescription, groupCode: groupCode)))
        .sheet(isPresented: $showingJoinCodeSheet) {
            JoinCodeSheet(joinCode: groupCode)
        }
        .sheet(isPresented: $showingProposeActivitySheet) {
            ProposeActivityView(
                groupId: groupCode,
                groupName: viewModel.groupName,
                groupMembers: groupMembers
            )
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
        .toolbar(.hidden, for: .tabBar)
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
    @State private var isCopied = false
    @State private var isSaveSuccessAlertPresented = false
    @State private var isLoading = false
    let joinCode: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Copy join code or download\nQR code")
                    .multilineTextAlignment(.center)
                    .font(.title2)
                
                Spacer().frame(height: 20)
                
                // Join Code Display
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
                    saveQRCodeImage()
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
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $isSaveSuccessAlertPresented) {
                Alert(title: Text("Success"), message: Text("QR Code image saved to Photos"), dismissButton: .default(Text("OK")))
            }
            if isLoading {
                LoadingScreen()
            }
        }
    }
    
    // Function to generate and save QR code as an image
    private func saveQRCodeImage() {
        isLoading = true  // Start loading
        let qrCodeImage = generateHighQualityQRCode(from: joinCode)
        
        // Save QR code to the photo library
        let imageSaver = ImageSaver { success in
            isLoading = false  // Stop loading
            if success {
                isSaveSuccessAlertPresented = true
            }
        }
        imageSaver.writeToPhotoAlbum(image: qrCodeImage)
    }

    // Function to generate a high-quality QR code image from a string
    private func generateHighQualityQRCode(from string: String) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)

        let transform = CGAffineTransform(scaleX: 10, y: 10) // Scale for higher resolution

        if let outputImage = filter.outputImage?.transformed(by: transform),
           let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return UIImage(systemName: "xmark.circle") ?? UIImage()
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
