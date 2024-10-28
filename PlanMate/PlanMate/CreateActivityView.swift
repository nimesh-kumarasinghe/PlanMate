//
//  CreateActivityView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI

struct CreateActivityView: View {
    @State private var title: String = ""
    @State private var isAllDay: Bool = true
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var selectedGroup = "Cousins"
    @State private var reminderTime = "10 min before"
    @State private var location: String = ""
    @State private var notes: String = ""
    @State private var url: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Title", text: $title)
                }
                
                Section {
                    HStack{
                        Image(systemName: "clock")
                        Toggle(isOn: $isAllDay) {
                            Text("All-day")
                        }
                    }
                    
                    if !isAllDay {
                        DatePicker("Starts", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                        DatePicker("Ends", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                    } else {
                        DatePicker("Starts", selection: $startDate, displayedComponents: .date)
                        DatePicker("Ends", selection: $endDate, displayedComponents: .date)
                    }
                }
                
                Section {
                    HStack {
                        Image(systemName: "person.2")
                        Text("Cousins")
                        Spacer()
                        Text(selectedGroup)
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Image(systemName: "person.3.fill")
                        Text("Invitees")
                        Spacer()
                        Text("Add people")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Image(systemName: "bell")
                        Text("Set event reminders")
                        Spacer()
                        Text(reminderTime)
                            .foregroundColor(.gray)
                    }
                }
                
                Section {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                        Text("Location")
                    }
                    
                    HStack {
                        Image(systemName: "note.text")
                        Text("Notes")
                    }
                    
                    HStack {
                        Image(systemName: "link")
                        Text("URL")
                    }
                }
                
                Section(header: Text("Task Assign")) {
                    Button(action: {
                        // Add task action
                    }) {
                        Label("Add task", systemImage: "plus.circle")
                            .foregroundColor(.blue)
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Dilanjana")
                                .foregroundColor(.blue)
                            Spacer()
                            Text("brings snacks")
                                .foregroundColor(.gray)
                        }
                        HStack {
                            Text("Lakshan")
                                .foregroundColor(.blue)
                            Spacer()
                            Text("brings cool drinks")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Create an Activity")
            .navigationBarItems(leading: Button("Cancel") {}, trailing: Button("Save") {})
        }
    }
}

struct CreateActivityView_Previews: PreviewProvider {
    static var previews: some View {
        CreateActivityView()
    }
}
