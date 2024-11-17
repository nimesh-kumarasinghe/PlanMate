//
//  CoreDataManager.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-16.
//

import CoreData
import SwiftUI

class CoreDataHelper {
    static let shared = CoreDataHelper()
    let container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "PlanMate")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error)")
            }
        }
    }
    
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving Core Data: \(error.localizedDescription)")
            }
        }
    }
}

