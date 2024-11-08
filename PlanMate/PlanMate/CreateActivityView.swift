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
    var person: String
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
    @Published var members: [Member] = [
        Member(name: "Dilanjana"),
        Member(name: "Lakshan"),
        Member(name: "Lakshika")
    ]
    @Published var locations: [Location] = []
    @Published var notes: [Note] = []
    @Published var urls: [String] = []
}

// Task Creation Sheet View
struct AddTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ActivityViewModel
    @State private var taskText: String = ""
    @State private var selectedMember: Member?
    @Binding var isShowingSheet: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add Tasks")
                    .font(.title2)
                    .padding(.top)
                
                TextField("write task", text: $taskText)
                    .padding(.horizontal)
                
                Menu {
                    ForEach(viewModel.members) { member in
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
                        viewModel.tasks.append(Task(person: member.name, assignment: taskText))
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
                                Text(task.person)
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
                    NavigationLink(isActive: $isShowingLocationSearch) {
                       LocationSearchView()
                    } label: {
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
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                Text(location.name)
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
                            Text(task.person)
                                .foregroundColor(.blue)
                            Text(task.assignment)
                        }
                    }
                    .onDelete(perform: deleteTask)
                    
                    Button(action: {
                        isShowingTaskSheet = true
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Task")
                        }
                        .foregroundColor(Color.blue)
                    }
                }
            }
            .sheet(isPresented: $isShowingMembersSheet) {
                ParticipantsSelectionView(members: $groupMembers)
            }
            .sheet(isPresented: $isShowingTaskSheet) {
                AddTaskSheet(viewModel: viewModel, isShowingSheet: $isShowingTaskSheet)
            }
            .sheet(isPresented: $isShowingNotes) {
                NotesView(viewModel: viewModel)
            }
            .sheet(isPresented: $isShowingURL) {
                URLInputView(viewModel: viewModel)
            }
            .navigationTitle("Create an Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveActivity()
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadGroups()
            }
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
        print("Saving activity with:")
        print("- \(viewModel.tasks.count) tasks")
        print("- \(viewModel.locations.count) locations")
        print("- \(viewModel.notes.count) notes")
        print("- \(viewModel.urls.count) URLs")
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
