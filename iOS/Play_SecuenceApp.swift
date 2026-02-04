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

// MARK: - Orientation Manager
class OrientationManager: NSObject, ObservableObject {
    static let shared = OrientationManager()
    
    @Published var isLandscapeLocked = false
    
    func lockToLandscape() {
        self.isLandscapeLocked = true
        // Force the orientation change
        AppDelegate.forceOrientation(.landscapeRight)
    }
    
    func unlockOrientation() {
        self.isLandscapeLocked = false
        // Allow auto-rotation
        if UIDevice.current.userInterfaceIdiom == .phone {
            AppDelegate.forceOrientation(.portrait)
        }
    }
}

// MARK: - AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    static let orientationManager = OrientationManager.shared
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        application.isIdleTimerDisabled = true
        FirebaseApp.configure()
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        // For iPad, always allow all orientations
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .allButUpsideDown
        }
        
        // For iPhone
        if AppDelegate.orientationManager.isLandscapeLocked {
            // Force landscape (prefer right, but allow left)
            return .landscape
        } else {
            // Allow all orientations
            return .allButUpsideDown
        }
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = SceneDelegate.self
        return sceneConfiguration
    }
    
    static func forceOrientation(_ orientation: UIInterfaceOrientation) {
        let orientation_value = orientation.rawValue
        UIDevice.current.setValue(orientation_value, forKey: "orientation")
        
        // Use the new iOS 16+ API
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.setNeedsUpdateOfSupportedInterfaceOrientations()
            }
        }
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Scene configuration
    }
}

@main
struct Play_SecuenceApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var isLoggedIn = false
    
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
