//
//  SubletEZApp.swift
//  SubletEZ
//
//  Created by Soham Kalgaonkar on 2025-06-06.
//

import SwiftUI
import FirebaseCore

@main
struct SubletEZApp: App {
    // Register AppDelegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}

// Create AppDelegate for Firebase configuration
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
