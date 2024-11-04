//
//  PlanMateApp.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-27.
//

import SwiftUI

@main
struct PlanMateApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            GroupDetailView()
        }
    }
}
