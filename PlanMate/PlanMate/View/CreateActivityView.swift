//
//  CreateActivityView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI
import FirebaseFirestore
import MapKit
import FirebaseAuth

// Task Creation Sheet View
struct AddTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ActivityViewModel
    @State private var taskText: String = ""
    @State private var selectedMember: TeamMember?
    @Binding var isShowingSheet: Bool
    let availableMembers: [TeamMember]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add Tasks")
                    .font(.title2)
                    .padding(.top)
                
                TextField("write task", text: $taskText)
                    .padding(.horizontal)
                
                Menu {
                    ForEach(availableMembers) { member in
                        Button(member.name) {
                            selectedMember = member
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedMember?.name ?? "Member")
                            .foregroundColor(selectedMember == nil ? .gray : .black)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
                .padding(.horizontal)
                
                Button(action: {
                    if let member = selectedMember, !taskText.isEmpty {
                        viewModel.tasks.append(Task(person: member, assignment: taskText))
                        isShowingSheet = false
                    }
                }) {
                    Text("Add")
                        .foregroundColor(.white)
                        .frame(width: 200, height: 44)
                        .background(Color("CustomBlue"))
                        .cornerRadius(50)
                }
                
                if !viewModel.tasks.isEmpty {
                    List {
                        ForEach(viewModel.tasks) { task in
                            HStack {
                                Text(task.person.name)
                                    .foregroundColor(Color("CustomeBlue"))
                                Text(task.assignment)
                            }
                        }
                        .onDelete(perform: deleteTask)
                    }
                }
                
                Spacer()
            }
            .navigationBarItems(
                leading: Button("Cancel") {
                    isShowingSheet = false
                }
            )
        }
    }
    
    private func deleteTask(at offsets: IndexSet) {
        viewModel.tasks.remove(atOffsets: offsets)
    }
}

// Notes View
struct NotesView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ActivityViewModel
    @State private var noteText: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $noteText)
                    .padding()
                    .frame(height: 200)
                
                Button("Add Note") {
                    if !noteText.isEmpty {
                        viewModel.notes.append(Note(content: noteText))
                        noteText = ""
                        dismiss()
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Notes")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
        }
    }
}

// URL Input View
struct URLInputView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ActivityViewModel
    @State private var urlString: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter URL", text: $urlString)
                    .padding()
                
                Button("Add URL") {
                    if !urlString.isEmpty {
                        viewModel.urls.append(urlString)
                        dismiss()
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Add URL")
            .navigationBarItems(leading: Button("Cancel") { dismiss() })
        }
    }
}

// Main View
struct CreateActivityView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ActivityViewModel()
    
    var isEditMode: Bool = false
    var editActivityId: String?
    
    @State private var title: String = ""
    @State private var isAllDay: Bool = true
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var selectedReminder = "10 min before"
    @State private var isShowingTaskSheet = false
    @State private var isShowingNotes = false
    @State private var isShowingLocationSearch = false
    @State private var isShowingURL = false
    @State private var isLoading: Bool = false
    @State private var showDeleteConfirmation = false
    @State private var navigateToActivityList = false
    @State private var showLeaveConfirmation = false
    
    // Alret Status
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    // New states for groups and members
    @State private var groups: [TeamGroup] = []
    @State private var selectedGroup: TeamGroup?
    @State private var groupMembers: [TeamMember] = []
    @State private var isShowingGroupMenu = false
    @State private var isShowingMembersSheet = false
    @State private var userGroups: [String] = []
    
    @State private var saveToCalendar = false
    @State private var calendarAccessGranted = false
    
    let reminderOptions = [
        "5 min before",
        "10 min before",
        "15 min before",
        "30 min before",
        "1 hour before"
    ]
    
    var selectedMembersCount: Int {
        groupMembers.filter { $0.isSelected }.count
    }
    var selectedGroupMembers: [TeamMember] {
        // Only return members that are selected
        return groupMembers.filter { $0.isSelected }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Title", text: $title)
                        .padding(.horizontal)
                    
                    Toggle("All-day", isOn: $isAllDay)
                    
                    DatePicker("Starts",
                               selection: $startDate,
                               displayedComponents: isAllDay ? .date : [.date, .hourAndMinute])
                    
                    DatePicker("Ends",
                               selection: $endDate,
                               displayedComponents: isAllDay ? .date : [.date, .hourAndMinute])
                }
                
                
                Section {
                    Menu {
                        ForEach(groups) { group in
                            Button(group.name) {
                                selectedGroup = group
                                loadGroupMembers(groupCode: group.groupCode)
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedGroup?.name ?? "Select Group")
                                .foregroundColor(selectedGroup == nil ? .gray : .black)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Button {
                        isShowingMembersSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "person.2")
                                .foregroundColor(Color("CustomBlue"))
                            Text("Participants")
                            Spacer()
                            Text("\(selectedMembersCount) selected")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section {
                    Menu {
                        ForEach(reminderOptions, id: \.self) { option in
                            Button(option) {
                                selectedReminder = option
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "alarm")
                                .foregroundColor(Color("CustomBlue"))
                            Text("Set event reminders")
                                .foregroundColor(.black)
                            Spacer()
                            Text(selectedReminder)
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                    }
                }
                Section {
                    Button{
                        isShowingLocationSearch = true
                    }
                label: {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                        Text("Add Location")
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .foregroundColor(Color("CustomBlue"))
                }
                    
                    Button(action: {
                        isShowingNotes = true
                    }) {
                        HStack {
                            Image(systemName: "note.text")
                            Text("Add Notes")
                                .foregroundColor(.black)
                            Spacer()
                        }
                    }
                    .foregroundColor(Color("CustomBlue"))
                    
                    Button(action: {
                        isShowingURL = true
                    }) {
                        HStack {
                            Image(systemName: "link")
                            Text("Add URL")
                                .foregroundColor(.black)
                            Spacer()
                        }
                    }
                    .foregroundColor(Color("CustomBlue"))
                }
                
                if !viewModel.locations.isEmpty {
                    Section(header: Text("Added Locations")) {
                        ForEach(viewModel.locations) { location in
                            VStack(alignment: .leading){
                                HStack {
                                    Image(systemName: "mappin.and.ellipse")
                                    Text(location.name)
                                }
                                Text(location.address)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                        }
                        .onDelete { indexSet in
                            viewModel.locations.remove(atOffsets: indexSet)
                        }
                    }
                }
                
                if !viewModel.notes.isEmpty {
                    Section(header: Text("Notes")) {
                        ForEach(viewModel.notes) { note in
                            HStack {
                                Image(systemName: "note.text")
                                Text(note.content)
                            }
                        }
                        .onDelete { indexSet in
                            viewModel.notes.remove(atOffsets: indexSet)
                        }
                    }
                }
                
                if !viewModel.urls.isEmpty {
                    Section(header: Text("Added URLs")) {
                        ForEach(viewModel.urls, id: \.self) { url in
                            HStack {
                                Image(systemName: "link")
                                Text(url)
                            }
                        }
                        .onDelete { indexSet in
                            viewModel.urls.remove(atOffsets: indexSet)
                        }
                    }
                }
                
                Section(header: Text("Task Assign")) {
                    ForEach(viewModel.tasks) { task in
                        HStack {
                            Text(task.person.name)
                                .foregroundColor(Color("CustomBlue"))
                            Text(task.assignment)
                        }
                    }
                    .onDelete(perform: deleteTask)
                    
                    Button(action: {
                        if !selectedGroupMembers.isEmpty{
                            isShowingTaskSheet = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Task")
                        }
                        .foregroundColor(selectedGroupMembers.isEmpty ? .gray : Color("CustomBlue"))
                    }
                    .disabled(selectedGroupMembers.isEmpty)
                }
                
                if isEditMode {
                    Section {
                        HStack{
                            Image(systemName: "calendar")
                                .foregroundColor(Color("CustomBlue"))
                            Toggle("Save to Phone Calendar", isOn: $saveToCalendar)
                                .onChange(of: saveToCalendar) { newValue in
                                    if newValue {
                                        // Request calendar access when toggle is enabled
                                        EventKitManager.shared.requestAccess { granted in
                                            if granted {
                                                calendarAccessGranted = true
                                            } else {
                                                // If access is denied, reset the toggle
                                                saveToCalendar = false
                                                alertTitle = "Calendar Access"
                                                alertMessage = "Please enable calendar access in Settings to use this feature."
                                                showAlert = true
                                            }
                                        }
                                    }
                                }
                        }
                    }
                    Section{
                        Button(action: {
                            showLeaveConfirmation = true
                            
                        }) {
                            HStack {
                                Spacer()
                                Text("Leave Activity")
                                    .foregroundColor(.orange)
                                Spacer()
                            }
                        }
                    }
                    Section {
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            HStack {
                                Spacer()
                                Text("Delete Activity")
                                    .foregroundColor(.red)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $isShowingMembersSheet) {
                ParticipantsSelectionView(members: $groupMembers)
            }
            .sheet(isPresented: $isShowingTaskSheet) {
                AddTaskSheet(
                    viewModel: viewModel,
                    isShowingSheet: $isShowingTaskSheet,
                    availableMembers: selectedGroupMembers
                )
            }
            .sheet(isPresented: $isShowingNotes) {
                NotesView(viewModel: viewModel)
            }
            .sheet(isPresented: $isShowingURL) {
                URLInputView(viewModel: viewModel)
            }
            .sheet(isPresented: $isShowingLocationSearch) {
                LocationSearchView { location in
                    viewModel.locations.append(location)
                }
            }
            .navigationTitle(isEditMode ? "Edit Activity" : "Create an Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveActivity()
                        dismiss()
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToActivityList) {
                MainHomeView()
            }
            .alert(alertTitle, isPresented: $showAlert){
                Button("Ok", role: .cancel){}
            }message :{
                Text(alertMessage)
            }
            .alert("Leave Activity", isPresented: $showLeaveConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Leave", role: .destructive) {
                    leaveActivity()
                }
            } message: {
                Text("Are you sure you want to leave from this activity? This action cannot be undone.")
            }
            .alert("Delete Activity", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteActivity()
                }
            } message: {
                Text("Are you sure you want to delete this activity? This action cannot be undone.")
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                if isEditMode{
                    loadActivityData()
                }
                loadGroups()
            }
            .overlay {
                if isLoading {
                    LoadingScreen()
                }
            }
        }
    }
    
    @ViewBuilder
    func LoadingScreen() -> some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
            
            ProgressView()
                .frame(width: 45, height: 45)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color(.systemBackground))
                )
        }
    }
    
    // leaving the activity
    private func leaveActivity() {
        guard let activityId = editActivityId,
              let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        let db = Firestore.firestore()
        
        // Create a batch write
        let batch = db.batch()
        
        // Remove the activity ID from the user's activities array
        let userRef = db.collection("users").document(currentUserId)
        batch.updateData([
            "activities": FieldValue.arrayRemove([activityId])
        ], forDocument: userRef)
        
        // Update the activity's participants array to remove the current user
        let activityRef = db.collection("activities").document(activityId)
        batch.updateData([
            "participants": FieldValue.arrayRemove([currentUserId])
        ], forDocument: activityRef)
        
        // Commit the batch
        batch.commit { error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.alertTitle = "Error"
                    self.alertMessage = "Failed to leave activity: \(error.localizedDescription)"
                    self.showAlert = true
                } else {
                    self.alertTitle = "Success"
                    self.alertMessage = "You have left the activity successfully"
                    self.showAlert = true
                    self.navigateToActivityList = true
                    self.dismiss()
                }
            }
        }
    }
    
    // delete activity from all users
    private func deleteActivity() {
        guard let activityId = editActivityId else { return }
        isLoading = true
        
        let db = Firestore.firestore()
        
        // First, get the activity document to find all participants
        db.collection("activities").document(activityId).getDocument { document, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.alertTitle = "Error"
                    self.alertMessage = "Failed to fetch activity: \(error.localizedDescription)"
                    self.showAlert = true
                }
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data(),
                  let participants = data["participants"] as? [String] else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.alertTitle = "Error"
                    self.alertMessage = "Failed to get activity participants"
                    self.showAlert = true
                }
                return
            }
            
            // Create a batch operation
            let batch = db.batch()
            
            // Delete the activity document
            let activityRef = db.collection("activities").document(activityId)
            batch.deleteDocument(activityRef)
            
            // Get the creator's ID (current user) and add to participants if not already included
            var allParticipants = Set(participants)
            if let currentUserId = Auth.auth().currentUser?.uid {
                allParticipants.insert(currentUserId)
            }
            
            // Remove activity ID from each participant's activities array
            for participantId in allParticipants {
                let userRef = db.collection("users").document(participantId)
                batch.updateData([
                    "activities": FieldValue.arrayRemove([activityId])
                ], forDocument: userRef)
            }
            
            // Commit the batch operation
            batch.commit { error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        self.alertTitle = "Error"
                        self.alertMessage = "Failed to delete activity: \(error.localizedDescription)"
                        self.showAlert = true
                    } else {
                        self.alertTitle = "Success"
                        self.alertMessage = "Activity deleted successfully"
                        self.showAlert = true
                        self.navigateToActivityList = true
                        self.dismiss()
                    }
                }
            }
        }
    }
    
    private func loadUserGroups() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No user logged in")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(currentUser.uid).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            
            if let data = snapshot?.data(),
               let userGroups = data["groups"] as? [String] {
                self.userGroups = userGroups
                loadGroupsForUser(groupCodes: userGroups)
            }
        }
    }
    
    private func loadGroupsForUser(groupCodes: [String]) {
        let db = Firestore.firestore()
        
        // Create a query that only gets groups with matching group codes
        let groupsRef = db.collection("groups")
        
        // If there are no group codes, don't proceed with the query
        guard !groupCodes.isEmpty else {
            self.groups = []
            return
        }
        
        groupsRef.whereField("groupCode", in: groupCodes).getDocuments { snapshot, error in
            if let error = error {
                print("Error loading groups: \(error.localizedDescription)")
                return
            }
            
            self.groups = snapshot?.documents.compactMap { document -> TeamGroup? in
                let data = document.data()
                return TeamGroup(
                    id: document.documentID,
                    name: data["groupName"] as? String ?? "",
                    groupCode: data["groupCode"] as? String ?? "",
                    members: data["members"] as? [String] ?? []
                )
            } ?? []
        }
    }
    
    // Replace the existing loadGroups() function with this:
    private func loadGroups() {
        loadUserGroups()
    }
    
    // Add function to load activity data for editing
    private func loadActivityData() {
        guard let activityId = editActivityId,
              let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        let db = Firestore.firestore()
        
        // Create a dispatch group to manage multiple async operations
        let group = DispatchGroup()
        
        // Enter dispatch group for activity data
        group.enter()
        db.collection("activities").document(activityId).getDocument { document, error in
            defer { group.leave() }
            
            if let error = error {
                print("Error fetching activity: \(error)")
                return
            }
            
            if let document = document, document.exists, let data = document.data() {
                DispatchQueue.main.async {
                    // Populate form fields with existing data
                    self.title = data["title"] as? String ?? ""
                    self.isAllDay = data["isAllDay"] as? Bool ?? true
                    if let startTimestamp = data["startDate"] as? Timestamp {
                        self.startDate = startTimestamp.dateValue()
                    }
                    if let endTimestamp = data["endDate"] as? Timestamp {
                        self.endDate = endTimestamp.dateValue()
                    }
                    self.selectedReminder = data["reminder"] as? String ?? "10 min before"
                    
                    // Load group
                    let groupId = data["groupId"] as? String ?? ""
                    if !groupId.isEmpty {
                        self.loadGroup(groupId: groupId) {
                            if let participants = data["participants"] as? [String] {
                                // Update selection status for each member
                                for index in self.groupMembers.indices {
                                    self.groupMembers[index].isSelected = participants.contains(self.groupMembers[index].id)
                                }
                            }
                        }
                    }
                    
                    // Load tasks
                    if let tasks = data["tasks"] as? [[String: Any]] {
                        self.viewModel.tasks = tasks.compactMap { taskData in
                            guard let memberId = taskData["memberId"] as? String,
                                  let memberName = taskData["memberName"] as? String,
                                  let assignment = taskData["assignment"] as? String else {
                                return nil
                            }
                            return Task(person: TeamMember(id: memberId, name: memberName), assignment: assignment)
                        }
                    }
                    
                    // Load notes
                    if let notes = data["notes"] as? [String] {
                        self.viewModel.notes = notes.map { Note(content: $0) }
                    }
                    
                    // Load URLs
                    self.viewModel.urls = data["urls"] as? [String] ?? []
                    
                    // Load locations
                    if let locations = data["locations"] as? [[String: Any]] {
                        self.viewModel.locations = locations.compactMap { locationData in
                            guard let latitude = locationData["latitude"] as? Double,
                                  let longitude = locationData["longitude"] as? Double else {
                                return nil
                            }
                            
                            let coordinate = CLLocationCoordinate2D(
                                latitude: latitude,
                                longitude: longitude
                            )
                            
                            return LocationData(
                                name: locationData["name"] as? String ?? "",
                                address: locationData["address"] as? String ?? "",
                                coordinate: coordinate,
                                category: locationData["category"] as? String ?? "default"
                            )
                        }
                    }
                }
            }
        }
        
        // Enter dispatch group for user settings
        group.enter()
        db.collection("users").document(currentUserId).getDocument { document, error in
            defer { group.leave() }
            
            if let document = document,
               let data = document.data(),
               let activitySettings = data["activitySettings"] as? [String: [String: Any]],
               let settings = activitySettings[activityId] {
                DispatchQueue.main.async {
                    self.saveToCalendar = settings["saveToCalendar"] as? Bool ?? false
                    
                    // If calendar was previously enabled, check for permission
                    if self.saveToCalendar {
                        EventKitManager.shared.requestAccess { granted in
                            DispatchQueue.main.async {
                                self.calendarAccessGranted = granted
                                if !granted {
                                    self.saveToCalendar = false
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // When all async operations are complete
        group.notify(queue: .main) {
            self.isLoading = false
        }
    }
    
    private func loadGroup(groupId: String, completion: @escaping () -> Void = {}) {
        let db = Firestore.firestore()
        db.collection("groups").document(groupId).getDocument { document, error in
            if let document = document, document.exists,
               let data = document.data() {
                DispatchQueue.main.async {
                    self.selectedGroup = TeamGroup(
                        id: document.documentID,
                        name: data["groupName"] as? String ?? "",
                        groupCode: data["groupCode"] as? String ?? "",
                        members: data["members"] as? [String] ?? []
                    )
                    
                    // Load group members with completion handler
                    self.loadGroupMembers(groupCode: data["groupCode"] as? String ?? "", completion: completion)
                }
            }
        }
    }
    
    private func loadGroupMembers(groupCode: String, completion: @escaping () -> Void = {}) {
        guard let selectedGroup = selectedGroup else { return }
        
        let db = Firestore.firestore()
        let dispatchGroup = DispatchGroup()
        var tempMembers: [TeamMember] = []
        
        for uid in selectedGroup.members {
            dispatchGroup.enter()
            
            db.collection("users").document(uid).getDocument { snapshot, error in
                defer { dispatchGroup.leave() }
                
                if let error = error {
                    print("Error loading member: \(error.localizedDescription)")
                    return
                }
                
                if let data = snapshot?.data(),
                   let name = data["name"] as? String {
                    let member = TeamMember(id: uid, name: name)
                    tempMembers.append(member)
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.groupMembers = tempMembers
            completion() // Call completion handler after members are loaded
        }
    }
    
    private func saveActivity() {
        guard !title.trim().isEmpty else {
            alertTitle = "Invalid Input"
            alertMessage = "Please enter a title for the activity"
            showAlert = true
            return
        }
        
        isLoading = true
        let db = Firestore.firestore()
        
        if isEditMode && saveToCalendar && calendarAccessGranted {
            // Get the first location if any exists
            let firstLocation = viewModel.locations.first
            
            EventKitManager.shared.saveToCalendar(
                title: title,
                startDate: startDate,
                endDate: endDate,
                isAllDay: isAllDay,
                location: firstLocation,
                notes: viewModel.notes,
                urls: viewModel.urls,
                reminder: selectedReminder
            ) { success, error in
                if let error = error {
                    DispatchQueue.main.async {
                        alertTitle = "Calendar Error"
                        alertMessage = "Failed to save to calendar: \(error.localizedDescription)"
                        showAlert = true
                    }
                }
            }
        }
        
        // Determine if we're creating or updating
        let activityRef: DocumentReference
        var activityId: String
        if let editId = editActivityId {
            activityRef = db.collection("activities").document(editId)
            activityId = editId
        } else {
            activityRef = db.collection("activities").document()
            activityId = activityRef.documentID
        }
        
        // Create activity data without saveToCalendar field
        var activityData: [String: Any] = [
            "title": title,
            "isAllDay": isAllDay,
            "startDate": Timestamp(date: startDate),
            "endDate": Timestamp(date: endDate),
            "reminder": selectedReminder,
            "groupId": selectedGroup?.id ?? "",
            "groupName": selectedGroup?.name ?? "",
            "participants": groupMembers.filter { $0.isSelected }.map { $0.id },
            "tasks": viewModel.tasks.map { [
                "memberId": $0.person.id,
                "memberName": $0.person.name,
                "assignment": $0.assignment
            ] },
            "locations": viewModel.locations.map { location in [
                "name": location.name,
                "address": location.address,
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude,
                "category": location.category
            ] },
            "notes": viewModel.notes.map { $0.content },
            "urls": viewModel.urls,
            "updatedAt": Timestamp(date: Date())
        ]
        
        let saveOperation: (Error?) -> Void = { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.alertTitle = "Error"
                    self.alertMessage = "Failed to save activity: \(error.localizedDescription)"
                    self.showAlert = true
                }
                return
            }
            
            // Get current user ID
            guard let currentUserId = Auth.auth().currentUser?.uid else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.alertTitle = "Error"
                    self.alertMessage = "No user logged in"
                    self.showAlert = true
                }
                return
            }
            
            // Get all selected participants
            var allParticipantIds = Set(self.groupMembers.filter { $0.isSelected }.map { $0.id })
            allParticipantIds.insert(currentUserId) // Add creator if not already included
            
            let batch = db.batch()
            
            // Update current user's document with saveToCalendar setting for this activity
            let currentUserRef = db.collection("users").document(currentUserId)
            let activitySettingsField = "activitySettings.\(activityId)"
            batch.updateData([
                "activities": FieldValue.arrayUnion([activityId]),
                activitySettingsField: ["saveToCalendar": self.saveToCalendar]
            ], forDocument: currentUserRef)
            
            // Update other participants' activities arrays (without saveToCalendar setting)
            for userId in allParticipantIds where userId != currentUserId {
                let userRef = db.collection("users").document(userId)
                batch.updateData([
                    "activities": FieldValue.arrayUnion([activityId])
                ], forDocument: userRef)
                
                // notification for this activity
                let notificationMessage = "\(self.title) has been created and you are a participant. Check it out."
                let notificationTitle = "New Event!"
                batch.updateData([
                    "notifications": FieldValue.arrayUnion([
                        [
                            "id": UUID().uuidString,
                            "message": notificationMessage,
                            "activityId": activityId,
                            "title":notificationTitle,
                            "timestamp": Timestamp(date: Date()),
                            "type": "Event"
                        ]
                    ])
                ], forDocument: userRef)
            }
            
            // Commit the batch update
            batch.commit { batchError in
                if let batchError = batchError {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.alertTitle = "Error"
                        self.alertMessage = "Failed to update participant activities: \(batchError.localizedDescription)"
                        self.showAlert = true
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.alertTitle = "Success"
                    self.alertMessage = "Activity saved successfully!"
                    self.clearFields()
                    self.dismiss()
                    self.showAlert = true
                }
            }
        }
        
        if editActivityId != nil {
            activityRef.updateData(activityData, completion: saveOperation)
        } else {
            activityRef.setData(activityData, completion: saveOperation)
        }
    }
    
    
    private func clearFields() {
        title = ""
        isAllDay = false
        startDate = Date()
        endDate = Date()
        selectedReminder = ""
        viewModel.tasks.removeAll()
        viewModel.locations.removeAll()
        viewModel.notes.removeAll()
        viewModel.urls.removeAll()
        for index in groupMembers.indices {
            groupMembers[index].isSelected = false
        }
    }
    
    private func handleSaveCompletion(_ error: Error?) {
        if let error = error {
            alertTitle = "Error"
            alertMessage = "Failed to save activity: \(error.localizedDescription)"
            showAlert = true
        } else {
            alertTitle = "Success"
            alertMessage = isEditMode ? "Successfully updated activity!" : "Successfully created activity!"
            showAlert = true
            isLoading = false
            dismiss()
            
            // Clear all fields after saving
            title = ""
            isAllDay = false
            startDate = Date()
            endDate = Date()
            selectedReminder = ""
            viewModel.tasks.removeAll()
            viewModel.locations.removeAll()
            viewModel.notes.removeAll()
            viewModel.urls.removeAll()
            for index in groupMembers.indices {
                groupMembers[index].isSelected = false
            }
        }
    }
    
    private func loadGroupMembers(groupCode: String) {
        guard let selectedGroup = selectedGroup else { return }
        
        let db = Firestore.firestore()
        let batch = db.batch()
        var tempMembers: [TeamMember] = []
        
        let dispatchGroup = DispatchGroup()
        
        for uid in selectedGroup.members {
            dispatchGroup.enter()
            
            db.collection("users").document(uid).getDocument { snapshot, error in
                defer { dispatchGroup.leave() }
                
                if let error = error {
                    print("Error loading member: \(error.localizedDescription)")
                    return
                }
                
                if let data = snapshot?.data(),
                   let name = data["name"] as? String {
                    let member = TeamMember(id: uid, name: name)
                    tempMembers.append(member)
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.groupMembers = tempMembers
        }
    }
    
    private func deleteTask(at offsets: IndexSet) {
        viewModel.tasks.remove(atOffsets: offsets)
    }
}

// Extension to trim whitespace
extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct ParticipantsSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var members: [TeamMember]
    @State private var selectAll: Bool = false
    @State private var selectedMembers: Set<TeamMember> = []
    
    var body: some View {
        NavigationView {
            VStack {
                Toggle("Select All", isOn: $selectAll)
                    .padding()
                    .onChange(of: selectAll) { newValue in
                        if newValue {
                            selectedMembers = Set(members)
                        } else {
                            selectedMembers.removeAll()
                        }
                    }
                
                List {
                    ForEach(members) { member in
                        HStack {
                            Text(member.name)
                            Spacer()
                            Image(systemName: selectedMembers.contains(member) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedMembers.contains(member) ? .blue : .gray)
                                .onTapGesture {
                                    // Toggle member selection
                                    if selectedMembers.contains(member) {
                                        selectedMembers.remove(member)
                                    } else {
                                        selectedMembers.insert(member)
                                    }
                                    selectAll = selectedMembers.count == members.count
                                }
                        }
                    }
                }
            }
            .navigationTitle("Select Participants")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Done") {
                    // Update the members binding with selected status before dismissing
                    for index in members.indices {
                        members[index].isSelected = selectedMembers.contains(members[index])
                    }
                    dismiss()
                }
            )
        }
    }
}


#Preview {
    CreateActivityView()
}
