//
//  AppDelegate.swift
//  PlanMate
//
//  Created by COBSCCOMPY4231P-005 on 2024-11-05.
//

import UIKit
import Firebase
import GoogleSignIn
import UserNotifications
import FirebaseAuth

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            // Configure Firebase
            FirebaseApp.configure()
            
            // Set notification delegate
            UNUserNotificationCenter.current().delegate = self
            
            // Request notification authorization and start listener if authorized
            NotificationManager.shared.requestAuthorization { granted in
                if granted {
                    // If user is logged in, start notification listener
                    if let userId = Auth.auth().currentUser?.uid {
                        NotificationManager.shared.startNotificationListener(for: userId)
                    }
                }
            }
            
            return true
        }
        
        // background states
        func applicationDidEnterBackground(_ application: UIApplication) {
            // Make sure listener continues in background
            if let userId = Auth.auth().currentUser?.uid {
                NotificationManager.shared.startNotificationListener(for: userId)
            }
        }
        
        func applicationWillEnterForeground(_ application: UIApplication) {
            if let userId = Auth.auth().currentUser?.uid {
                NotificationManager.shared.startNotificationListener(for: userId)
            }
        }
        
        func applicationWillTerminate(_ application: UIApplication) {
            // clean listener when app terminates
            NotificationManager.shared.stopNotificationListener()
        }
        
        // UNUserNotificationCenterDelegate
        func userNotificationCenter(
            _ center: UNUserNotificationCenter,
            willPresent notification: UNNotification,
            withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
        ) {
            // Show notification when app is in foreground
            completionHandler([.banner, .sound, .badge])
        }
        
        func userNotificationCenter(
            _ center: UNUserNotificationCenter,
            didReceive response: UNNotificationResponse,
            withCompletionHandler completionHandler: @escaping () -> Void
        ) {
            // Handle notification tap
            let userInfo = response.notification.request.content.userInfo
            if let activityId = userInfo["activityId"] as? String {
                // Handle navigation to activity
                NotificationCenter.default.post(
                    name: NSNotification.Name("OpenActivity"),
                    object: nil,
                    userInfo: ["activityId": activityId]
                )
            }
            completionHandler()
        }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
