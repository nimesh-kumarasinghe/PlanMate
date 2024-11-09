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
import EventKit

// Add EventKit permission handler
class EventKitManager {
    static let shared = EventKitManager()
    private let eventStore = EKEventStore()
    
    func requestAccess(completion: @escaping (Bool) -> Void) {
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents { granted, error in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        } else {
            eventStore.requestAccess(to: .event) { granted, error in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        }
    }
    
    func saveToCalendar(
        title: String,
        startDate: Date,
        endDate: Date,
        isAllDay: Bool,
        location: LocationData?,
        notes: [Note],
        urls: [String],
        reminder: String,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.isAllDay = isAllDay
        
        // Set location if available
        if let location = location {
            event.location = "\(location.name): \(location.address)"
        }
        
        // Combine notes into a single string
        if !notes.isEmpty {
            event.notes = notes.map { $0.content }.joined(separator: "\n\n")
        }
        
        // Add URLs to notes
        if !urls.isEmpty {
            let urlString = "\n\nURLs:\n" + urls.joined(separator: "\n")
            event.notes = (event.notes ?? "") + urlString
        }
        
        // Set calendar
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        // Add reminder alarm
        if let alarm = createAlarm(from: reminder) {
            event.addAlarm(alarm)
        }
        
        do {
            try eventStore.save(event, span: .thisEvent)
            completion(true, nil)
        } catch {
            completion(false, error)
        }
    }
    
    private func createAlarm(from reminder: String) -> EKAlarm? {
        let components = reminder.components(separatedBy: " ")
        guard components.count >= 2,
              let timeValue = Int(components[0]) else {
            return nil
        }
        
        var offset: TimeInterval = 0
        switch components[1] {
        case "min":
            offset = TimeInterval(-timeValue * 60)
        case "hour":
            offset = TimeInterval(-timeValue * 60 * 60)
        default:
            return nil
        }
        
        return EKAlarm(relativeOffset: offset)
    }
}

// Models
struct Task: Identifiable {
    let id = UUID()
    var person: TeamMember
    var assignment: String
}

struct Member: Identifiable {
    let id = UUID()
    let name: String
}

struct Location: Identifiable {
    let id = UUID()
    let name: String
}

struct Note: Identifiable {
    let id = UUID()
    var content: String
}

// Using TeamGroup instead of Group to avoid conflicts
struct TeamGroup: Identifiable {
    let id: String
    let name: String
    let groupCode: String
    let members: [String] // UIDs of members
}

struct TeamMember: Identifiable, Hashable {
    let id: String // UID from Firebase
    let name: String
    var isSelected: Bool = false
}

// View Models
class ActivityViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var locations: [LocationData] = []
    @Published var notes: [Note] = []
    @Published var urls: [String] = []
}

// Task Creation Sheet View
struct AddTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ActivityViewModel
    @State private var taskText: String = ""
    @State private var selectedMember: TeamMember?
    @Binding var isShowingSheet: Bool
    let availableMembers: [TeamMember]  // New property to receive group members
    
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
    @State private var showCalendarPermissionAlert = false
    @State private var calendarError: String?
    
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
            .alert(alertTitle, isPresented: $showAlert){
                Button("Ok", role: .cancel){}
            }message :{
                Text(alertMessage)
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
                
                // Request calendar access when view appears
                EventKitManager.shared.requestAccess { granted in
                    if !granted {
                        showCalendarPermissionAlert = true
                    }
                }
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
            guard let activityId = editActivityId else { return }
            isLoading = true
            
            let db = Firestore.firestore()
            db.collection("activities").document(activityId).getDocument { document, error in
                if let error = error {
                    print("Error fetching activity: \(error)")
                    isLoading = false
                    return
                }
                
                if let document = document, document.exists, let data = document.data() {
                    // Populate form fields with existing data
                    title = data["title"] as? String ?? ""
                    isAllDay = data["isAllDay"] as? Bool ?? true
                    if let startTimestamp = data["startDate"] as? Timestamp {
                        startDate = startTimestamp.dateValue()
                    }
                    if let endTimestamp = data["endDate"] as? Timestamp {
                        endDate = endTimestamp.dateValue()
                    }
                    selectedReminder = data["reminder"] as? String ?? "10 min before"
                    
                    // Load group
                    let groupId = data["groupId"] as? String ?? ""
                    if !groupId.isEmpty {
                        loadGroup(groupId: groupId) {
                            // After loading group members, update selected participants
                            if let participants = data["participants"] as? [String] {
                                DispatchQueue.main.async {
                                    // Update selection status for each member
                                    for index in self.groupMembers.indices {
                                        self.groupMembers[index].isSelected = participants.contains(self.groupMembers[index].id)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Load tasks
                    DispatchQueue.main.async{
                        if let tasks = data["tasks"] as? [[String: Any]] {
                            viewModel.tasks = tasks.compactMap { taskData in
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
                            viewModel.notes = notes.map { Note(content: $0) }
                        }
                        
                        // Load URLs
                        viewModel.urls = data["urls"] as? [String] ?? []
                    }
                    
                    // Parse the JSON data
                    if let locations = data["locations"] as? [[String: Any]] {
                        DispatchQueue.main.async{
                            self.viewModel.locations = locations.compactMap { locationData in
                                // Extract coordinate data
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
                DispatchQueue.main.async{
                    self.isLoading = false
                }
                
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
        
        // Modify saveActivity function to handle both create and update
        private func saveActivity() {
            guard !title.trim().isEmpty else {
                alertTitle = "Invalid Input"
                alertMessage = "Please enter a title for the activity"
                showAlert = true
                return
            }
            
            isLoading = true
            let db = Firestore.firestore()
            
            // Determine if we're creating or updating
            let activityRef: DocumentReference
            if let editId = editActivityId {
                activityRef = db.collection("activities").document(editId)
            } else {
                activityRef = db.collection("activities").document()
            }
            
            // Create activity data (same as before)
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
                    "catgeory": location.category
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
                        
                        // After successful Firestore save, save to calendar
                        EventKitManager.shared.requestAccess { granted in
                            if granted {
                                EventKitManager.shared.saveToCalendar(
                                    title: self.title,
                                    startDate: self.startDate,
                                    endDate: self.endDate,
                                    isAllDay: self.isAllDay,
                                    location: self.viewModel.locations.first,
                                    notes: self.viewModel.notes,
                                    urls: self.viewModel.urls,
                                    reminder: self.selectedReminder
                                ) { success, error in
                                    DispatchQueue.main.async {
                                        self.isLoading = false
                                        if success {
                                            self.alertTitle = "Success"
                                            self.alertMessage = "Activity saved to Firestore and Calendar!"
                                            self.clearFields()
                                            self.dismiss()
                                        } else {
                                            self.alertTitle = "Partial Success"
                                            self.alertMessage = "Saved to Firestore but failed to save to Calendar: \(error?.localizedDescription ?? "Unknown error")"
                                        }
                                        self.showAlert = true
                                    }
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.isLoading = false
                                    self.alertTitle = "Calendar Access Denied"
                                    self.alertMessage = "Please enable calendar access in Settings to save events to your calendar."
                                    self.showAlert = true
                                }
                            }
                        }
                    }
                    
                    // Execute the Firestore operation
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
    @State private var selectedMembers: Set<TeamMember> = []  // Track selected members
    
    var body: some View {
        NavigationView {
            VStack {
                Toggle("Select All", isOn: $selectAll)
                    .padding()
                    .onChange(of: selectAll) { newValue in
                        // Update selected members based on "Select All" status
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
                                    // Update "Select All" toggle based on selection status
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
