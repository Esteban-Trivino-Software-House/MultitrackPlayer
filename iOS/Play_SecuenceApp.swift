//
//  Play_SecuenceApp.swift
//  Shared
//
//  Created by Esteban Rafael Trivino Guerra on 8/09/22.
//


/*
 Ideas to implement:
 For your multitrack player, consider Firebase Authentication for user management, Cloud Storage for Firebase to store audio tracks, and Cloud Firestore or Realtime Database for managing song metadata and user data. These are excellent starting points for your "multitrack-player---ios---dev" project.
 */

import SwiftUI
import FirebaseCore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    
    static var orientationLock = UIInterfaceOrientationMask.all //By default you want all your views to rotate freely
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        AppDelegate.orientationLock = .landscapeRight // Making sure it stays that way
        application.isIdleTimerDisabled = true
        FirebaseApp.configure()
        return true
    }
    
}

@main
struct Play_SecuenceApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                LoginView(viewModel: .init(authService: AuthenticationService()))
                    .onAppear() {
                        UIApplication.shared.isIdleTimerDisabled = true
                    }
                    .onOpenURL { url in
                        _ = GIDSignIn.sharedInstance.handle(url)
                    }
            }
        }
    }
}
