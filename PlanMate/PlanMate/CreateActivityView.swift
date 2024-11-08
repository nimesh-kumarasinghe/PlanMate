//
//  CreateActivityView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI
import FirebaseFirestore

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

struct TeamMember: Identifiable {
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
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                
                if !viewModel.tasks.isEmpty {
                    List {
                        ForEach(viewModel.tasks) { task in
                            HStack {
                                Text(task.person.name)
                                    .foregroundColor(.blue)
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
                                .foregroundColor(Color.blue)
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
                                .foregroundColor(Color.blue)
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
                        Spacer()
                    }
                    .foregroundColor(Color.blue)
                }
                    
                    Button(action: {
                        isShowingNotes = true
                    }) {
                        HStack {
                            Image(systemName: "note.text")
                            Text("Add Notes")
                            Spacer()
                        }
                    }
                    .foregroundColor(Color.blue)
                    
                    Button(action: {
                        isShowingURL = true
                    }) {
                        HStack {
                            Image(systemName: "link")
                            Text("Add URL")
                            Spacer()
                        }
                    }
                    .foregroundColor(Color.blue)
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
                                .foregroundColor(.blue)
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
                        .foregroundColor(selectedGroupMembers.isEmpty ? .gray : .blue)
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
            .navigationTitle("Create an Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                }
                
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
            .onAppear {
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
    
    private func loadGroups() {
        let db = Firestore.firestore()
        db.collection("groups").getDocuments { snapshot, error in
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
    
    private func saveActivity() {
        guard !title.trim().isEmpty else {
            alertTitle = "Invalid Input"
            alertMessage = "Please enter a title for the activity"
            showAlert = true
            return
        }
        isLoading = true
        let db = Firestore.firestore()
        let activityRef = db.collection("activities").document()
        
        // Get selected member IDs
        let selectedMemberIds = groupMembers.filter { $0.isSelected }.map { $0.id }
        
        // Format tasks for Firestore
        let assignedTasks = viewModel.tasks.map { [
            "memberId": $0.person.id,
            "memberName": $0.person.name,
            "assignment": $0.assignment
        ] }
        
        // Format locations for Firestore
        let locations = viewModel.locations.map { [
            "name": $0.name,
            "address": $0.address
        ] }
        
        // Create activity data
        let activityData: [String: Any] = [
            "title": title,
            "isAllDay": isAllDay,
            "startDate": Timestamp(date: startDate),
            "endDate": Timestamp(date: endDate),
            "reminder": selectedReminder,
            "groupId": selectedGroup?.id ?? "",
            "groupName": selectedGroup?.name ?? "",
            "participants": selectedMemberIds,
            "tasks": assignedTasks,
            "locations": locations,
            "notes": viewModel.notes.map { $0.content },
            "urls": viewModel.urls,
            "createdAt": Timestamp(date: Date()),
            "updatedAt": Timestamp(date: Date())
        ]
        
        // Save to Firestore
        activityRef.setData(activityData) { error in
            if let error = error {
                alertTitle = "Error"
                alertMessage = "Failed to save activity: \(error.localizedDescription)"
                showAlert = true
            } else {
                alertTitle = "Success"
                alertMessage = "Successfully activity created!"
                showAlert = true
                isLoading = false
                
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
                
                dismiss()
            }
        }
    }
    
    
    //        let selectedMemberIds = groupMembers.filter { $0.isSelected }.map { $0.id }
    //        let assignedTasks = viewModel.tasks.map { [
    //            "memberId": $0.person.id,
    //            "memberName": $0.person.name,
    //            "assignment": $0.assignment
    //        ] }
    //        
    //        print("Saving activity with:")
    //        print("- \(viewModel.tasks.count) tasks")
    //        print("- \(viewModel.locations.count) locations")
    //        print("- \(viewModel.notes.count) notes")
    //        print("- \(viewModel.urls.count) URLs")
    //        print("- Selected members: \(selectedMemberIds)")
    //        print("- Assigned tasks: \(assignedTasks)")
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
    
    var body: some View {
        NavigationView {
            List {
                ForEach($members) { $member in
                    HStack {
                        Text(member.name)
                        Spacer()
                        Toggle("", isOn: $member.isSelected)
                    }
                }
            }
            .navigationTitle("Select Participants")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Done") {
                    dismiss()
                }
            )
        }
    }
}

#Preview {
    CreateActivityView()
}
