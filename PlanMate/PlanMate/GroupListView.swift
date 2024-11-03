//
//  GroupListView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI

struct Group: Identifiable {
    let id = UUID()
    let name: String
    let memberCount: Int
}

struct GroupListView: View {
    @State private var groups = [
        Group(name: "Office", memberCount: 10),
        Group(name: "Friends", memberCount: 6),
        Group(name: "Cousins", memberCount: 8),
        Group(name: "Trip Friends", memberCount: 7),
        Group(name: "Campus Friends", memberCount: 5),
        Group(name: "IT Committee", memberCount: 12),
        Group(name: "School A/L Class", memberCount: 8)
    ]
    
    @State private var showAlert = false
    @State private var groupToLeave: Group?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(groups) { group in
                    HStack {
                        Image("defaultimg")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(group.memberCount > 6 ? .blue : .green)
                        VStack(alignment: .leading) {
                            Text(group.name)
                                .font(.headline)
                            Text("\(group.memberCount) members")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            groupToLeave = group
                            showAlert = true
                        } label: {
                            Text("Leave")
                        }
                    }
                }
            }
            .alert("Leave Group", isPresented: $showAlert, presenting: groupToLeave) { group in
                Button("Leave", role: .destructive) {
                    if let index = groups.firstIndex(where: { $0.id == group.id }) {
                        groups.remove(at: index)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: { group in
                Text("Are you sure you want to leave \(group.name)?")
            }
            .navigationTitle("Groups")
            .navigationBarTitleDisplayMode(.inline)
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
            .background(Color.white)
        }
    }
}

struct GroupsView_Previews: PreviewProvider {
    static var previews: some View {
        GroupListView()
    }
}
