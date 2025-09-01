//
//  Play_SecuenceApp.swift
//  Shared
//
//  Created by Esteban Rafael Trivino Guerra on 8/09/22.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    
    static var orientationLock = UIInterfaceOrientationMask.all //By default you want all your views to rotate freely
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation") // Forcing the rotation to portrait
        AppDelegate.orientationLock = .landscapeRight // And making sure it stays that way
        application.isIdleTimerDisabled = true
        return true
    }
}

@main
struct Play_SecuenceApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                DashboardScreen()
                    .onAppear() {
                        UIApplication.shared.isIdleTimerDisabled = true
                    }
            }
        }
    }
}
