//
//  CreateActivityView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

//import SwiftUI
//
//// Models
//struct Task: Identifiable {
//    let id = UUID()
//    var person: String
//    var assignment: String
//}
//
//struct Member: Identifiable {
//    let id = UUID()
//    let name: String
//}
//
//struct Location: Identifiable {
//    let id = UUID()
//    let name: String
//}
//
//// View Models
//class ActivityViewModel: ObservableObject {
//    @Published var tasks: [Task] = []
//    @Published var members: [Member] = [
//        Member(name: "Dilanjana"),
//        Member(name: "Lakshan"),
//        Member(name: "Lakshika")
//    ]
//    @Published var locations: [Location] = []
//    @Published var notes: String = ""
//    @Published var urls: [String] = []
//}
//
//// Task Creation Sheet View
//struct AddTaskSheet: View {
//    @Environment(\.dismiss) private var dismiss
//    @ObservedObject var viewModel: ActivityViewModel
//    @State private var taskText: String = ""
//    @State private var selectedMember: Member?
//    @Binding var isShowingSheet: Bool
//    
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 20) {
//                Text("Add Tasks")
//                    .font(.title2)
//                    .padding(.top)
//                
//                TextField("write task", text: $taskText)
//                    .padding(.horizontal)
//                
//                Menu {
//                    ForEach(viewModel.members) { member in
//                        Button(member.name) {
//                            selectedMember = member
//                        }
//                    }
//                } label: {
//                    HStack {
//                        Text(selectedMember?.name ?? "Member")
//                            .foregroundColor(selectedMember == nil ? .gray : .black)
//                        Spacer()
//                        Image(systemName: "chevron.down")
//                            .foregroundColor(.gray)
//                    }
//                    .padding()
//                }
//                .padding(.horizontal)
//                
//                Button(action: {
//                    if let member = selectedMember, !taskText.isEmpty {
//                        viewModel.tasks.append(Task(person: member.name, assignment: taskText))
//                        isShowingSheet = false
//                    }
//                }) {
//                    Text("Add")
//                        .foregroundColor(.white)
//                        .frame(width: 200, height: 44)
//                        .background(Color.blue)
//                        .cornerRadius(8)
//                }
//                
//                if !viewModel.tasks.isEmpty {
//                    List {
//                        ForEach(viewModel.tasks) { task in
//                            HStack {
//                                Text(task.person)
//                                    .foregroundColor(.blue)
//                                Text(task.assignment)
//                            }
//                        }
//                        .onDelete(perform: deleteTask)
//                    }
//                }
//                
//                Spacer()
//            }
//            .navigationBarItems(
//                leading: Button("Cancel") {
//                    isShowingSheet = false
//                }
//            )
//            .background(Color.white)
//        }
//    }
//    
//    private func deleteTask(at offsets: IndexSet) {
//        viewModel.tasks.remove(atOffsets: offsets)
//    }
//}
//
//// Notes View
//struct NotesView: View {
//    @Environment(\.dismiss) private var dismiss
//    @ObservedObject var viewModel: ActivityViewModel
//    
//    var body: some View {
//        NavigationView {
//            TextEditor(text: $viewModel.notes)
//                .padding()
//                .navigationTitle("Notes")
//                .navigationBarItems(
//                    leading: Button("Cancel") {
//                        dismiss()
//                    },
//                    trailing: Button("Save") {
//                        dismiss()
//                    }
//                )
//                .background(Color.white)
//        }
//    }
//}
//
//// Location Input View
//struct LocationInputView: View {
//    @Environment(\.dismiss) private var dismiss
//    @ObservedObject var viewModel: ActivityViewModel
//    @State private var locationName: String = ""
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                TextField("Enter location", text: $locationName)
//                    .padding()
//                
//                Button("Add Location") {
//                    if !locationName.isEmpty {
//                        viewModel.locations.append(Location(name: locationName))
//                        dismiss()
//                    }
//                }
//                .padding()
//                
//                Spacer()
//            }
//            .navigationTitle("Add Location")
//            .navigationBarItems(leading: Button("Cancel") { dismiss() })
//            .background(Color.white)
//        }
//    }
//}
//
//// URL Input View
//struct URLInputView: View {
//    @Environment(\.dismiss) private var dismiss
//    @ObservedObject var viewModel: ActivityViewModel
//    @State private var urlString: String = ""
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                TextField("Enter URL", text: $urlString)
//                    .padding()
//                
//                Button("Add URL") {
//                    if !urlString.isEmpty {
//                        viewModel.urls.append(urlString)
//                        dismiss()
//                    }
//                }
//                .padding()
//                
//                Spacer()
//            }
//            .navigationTitle("Add URL")
//            .navigationBarItems(leading: Button("Cancel") { dismiss() })
//            .background(Color.white)
//        }
//    }
//}
//
//// Main View
//struct CreateActivityView: View {
//    @Environment(\.dismiss) private var dismiss
//    @StateObject private var viewModel = ActivityViewModel()
//    @State private var title: String = ""
//    @State private var isAllDay: Bool = true
//    @State private var startDate = Date()
//    @State private var endDate = Date()
//    @State private var selectedReminder = "10 min before"
//    @State private var isShowingTaskSheet = false
//    @State private var isShowingNotes = false
//    @State private var isShowingLocation = false
//    @State private var isShowingURL = false
//    
//    let reminderOptions = [
//        "5 min before",
//        "10 min before",
//        "15 min before",
//        "30 min before",
//        "1 hour before"
//    ]
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                Section {
//                    TextField("Title", text: $title)
//                        .padding(.horizontal)
//                    
//                    Toggle("All-day", isOn: $isAllDay)
//                    
//                    DatePicker("Starts",
//                             selection: $startDate,
//                             displayedComponents: isAllDay ? .date : [.date, .hourAndMinute])
//                    
//                    DatePicker("Ends",
//                             selection: $endDate,
//                             displayedComponents: isAllDay ? .date : [.date, .hourAndMinute])
//                }
//                .listRowBackground(Color.white)
//                
//                Section {
//                    NavigationLink("Select Group") {
//                        Text("Cousins Selection View")
//                    }
//                    
//                    NavigationLink {
//                        Text("Participants Selection View")
//                    } label: {
//                        HStack {
//                            Image(systemName: "person.2")
//                                .foregroundColor(Color(("CustomBlue")))
//                            Text("Participants")
//                        }
//                    }
//                }
//                .listRowBackground(Color.white)
//                
//                Section {
//                    Menu {
//                        ForEach(reminderOptions, id: \.self) { option in
//                            Button(option) {
//                                selectedReminder = option
//                            }
//                        }
//                    } label: {
//                        HStack {
//                            Image(systemName: "alarm")
//                                .foregroundColor(Color(("CustomBlue")))
//                            Text("Set event reminders")
//                                .foregroundColor(.black)
//                            Spacer()
//                            Text(selectedReminder)
//                                .foregroundColor(.gray)
//                            Image(systemName: "chevron.down")
//                                .foregroundColor(.gray)
//                        }
//                    }
//                }
//                .listRowBackground(Color.white)
//
//                // Separate Buttons for Locations, Notes, and URLs
//                Section {
//                    HStack {
//                        Button(action: {
//                            isShowingLocation = true
//                        }) {
//                            HStack {
//                                Image(systemName: "mappin.and.ellipse")
//                                Text("Add Location")
//                            }
//                        }
//                        .foregroundColor(Color(("CustomBlue")))
//                        
//                        Spacer()
//                        
//                        Button(action: {
//                            isShowingNotes = true
//                        }) {
//                            HStack {
//                                Image(systemName: "note.text")
//                                Text("Add Notes")
//                            }
//                        }
//                        .foregroundColor(Color(("CustomBlue")))
//                        
//                        Spacer()
//                        
//                        Button(action: {
//                            isShowingURL = true
//                        }) {
//                            HStack {
//                                Image(systemName: "link")
//                                Text("Add URL")
//                            }
//                        }
//                        .foregroundColor(Color(("CustomBlue")))
//                    }
//                }
//
//                // Added Items
//                Section(header: Text("Added Locations")) {
//                    ForEach(viewModel.locations) { location in
//                        HStack {
//                            Image(systemName: "mappin.and.ellipse")
//                            Text(location.name)
//                        }
//                    }
//                    .onDelete { indexSet in
//                        viewModel.locations.remove(atOffsets: indexSet)
//                    }
//                }
//                .listRowBackground(Color.white)
//                
//                if !viewModel.notes.isEmpty {
//                    Section(header: Text("Notes")) {
//                        HStack {
//                            Image(systemName: "note.text")
//                            Text(viewModel.notes)
//                        }
//                    }
//                }
//                
//                Section(header: Text("Added URLs")) {
//                    ForEach(viewModel.urls, id: \.self) { url in
//                        HStack {
//                            Image(systemName: "link")
//                            Text(url)
//                        }
//                    }
//                    .onDelete { indexSet in
//                        viewModel.urls.remove(atOffsets: indexSet)
//                    }
//                }
//                .listRowBackground(Color.white)
//
//                Section(header: Text("Task Assign")) {
//                    ForEach(viewModel.tasks) { task in
//                        HStack {
//                            Text(task.person)
//                                .foregroundColor(.blue)
//                            Text(task.assignment)
//                        }
//                    }
//                    .onDelete(perform: deleteTask)
//                    
//                    Button(action: {
//                        isShowingTaskSheet = true
//                    }) {
//                        HStack {
//                            Image(systemName: "plus")
//                            Text("Add Task")
//                        }
//                        .foregroundColor(Color(("CustomBlue")))
//                    }
//                }
//                .listRowBackground(Color.white)
//            }
//            .sheet(isPresented: $isShowingTaskSheet) {
//                AddTaskSheet(viewModel: viewModel, isShowingSheet: $isShowingTaskSheet)
//            }
//            .sheet(isPresented: $isShowingNotes) {
//                NotesView(viewModel: viewModel)
//            }
//            .sheet(isPresented: $isShowingLocation) {
//                LocationInputView(viewModel: viewModel)
//            }
//            .sheet(isPresented: $isShowingURL) {
//                URLInputView(viewModel: viewModel)
//            }
//            .navigationTitle("Create an Activity")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                }
//                
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Save") {
//                        saveActivity()
//                        dismiss()
//                    }
//                }
//            }
//            .background(Color.white)
//        }
//    }
//    
//    private func deleteTask(at offsets: IndexSet) {
//        viewModel.tasks.remove(atOffsets: offsets)
//    }
//    
//    private func saveActivity() {
//        // Implement save functionality
//        print("Saving activity with:")
//        print("- \(viewModel.tasks.count) tasks")
//        print("- \(viewModel.locations.count) locations")
//        print("- Notes: \(viewModel.notes)")
//        print("- \(viewModel.urls.count) URLs")
//    }
//}
//
//#Preview {
//    CreateActivityView()
//}

import SwiftUI

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
    
    let reminderOptions = [
        "5 min before",
        "10 min before",
        "15 min before",
        "30 min before",
        "1 hour before"
    ]
    
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
                    NavigationLink("Select Group") {
                        Text("Cousins Selection View")
                    }
                    
                    NavigationLink {
                        Text("Participants Selection View")
                    } label: {
                        HStack {
                            Image(systemName: "person.2")
                                .foregroundColor(Color.blue)
                            Text("Participants")
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

#Preview {
    CreateActivityView()
}
