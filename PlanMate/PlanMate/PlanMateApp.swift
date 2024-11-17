//
//  PlanMateApp.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-10-27.
//

import SwiftUI
import Firebase

@main
struct PlanMateApp: App {

    // Link the AppDelegate to the SwiftUI lifecycle
        @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            //ContentView()
            
            SplashScreenView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
