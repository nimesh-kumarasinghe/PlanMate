//
//  ProposeActivityView.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-28.
//

import SwiftUI

struct GroupMember: Identifiable, Hashable {
    let id = UUID()
    let name: String
}

struct ProposeActivityView: View {
    @State private var activityName: String = ""
    @State private var selectedMembers: Set<GroupMember> = []
    
    let groupMembers = [
        GroupMember(name: "Dilanjana"),
        GroupMember(name: "Lakshan"),
        GroupMember(name: "Haritha"),
        GroupMember(name: "Nisal"),
        GroupMember(name: "Lakshika")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer().frame(height: 1)
                TextField("Activity name", text: $activityName)
                    .padding()
                    .cornerRadius(10)
                    .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray3), lineWidth: 2)
                        )
                    .padding(.horizontal,20)
                
                Button(action: {
                    // Add location selection logic here
                }) {
                    HStack {
                        Text("Select Locations")
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(50)
                }
                .padding(.horizontal)
                
                // Group Members Section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Group Members (\(groupMembers.count))")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            if selectedMembers.count == groupMembers.count {
                                selectedMembers.removeAll()
                            } else {
                                selectedMembers = Set(groupMembers)
                            }
                        }) {
                            HStack {
                                Text("Select all")
                                Image(systemName: selectedMembers.count == groupMembers.count ? "checkmark.square" : "square")
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Member List
                    ForEach(groupMembers) { member in
                        Button(action: {
                            if selectedMembers.contains(member) {
                                selectedMembers.remove(member)
                            } else {
                                selectedMembers.insert(member)
                            }
                        }) {
                            HStack {
                                Image(systemName: selectedMembers.contains(member) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedMembers.contains(member) ? .blue : .gray)
                                
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.gray)
                                
                                Text(member.name)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                        }
                        Divider()
                            .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    // active save
                }) {
                    Text("Save")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("CustomBlue"))
                        .cornerRadius(50)
                }
                .padding(.horizontal, 40)
            }
            .navigationBarTitle("Propose an Activity", displayMode: .inline)
        }
    }
}

#Preview {
    ProposeActivityView()
}
