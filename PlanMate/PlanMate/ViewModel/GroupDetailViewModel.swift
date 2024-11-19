//
//  GroupDetailViewModel.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-19.
//

import Foundation
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
    @Published var profileImageURL: String = ""
    
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
                    self.profileImageURL = data["profileImageURL"] as? String ?? ""
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
