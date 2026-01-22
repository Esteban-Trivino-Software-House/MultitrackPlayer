//
//  AccountDeletionService.swift
//  Play Secuence
//
//  Created by Esteban Triviño on 22/01/26.
//  This file is part of the Multitrack Player project.
//

import Foundation
import FirebaseAuth
import GoogleSignIn

/// Service responsible for handling account deletion across providers
/// Complies with App Store Guideline 5.1.1(v) - Account Deletion
final class AccountDeletionService {
    
    private let googleProvider = GoogleAuthProvider()
    
    /// Delete the current user account permanently
    /// This will:
    /// 1. Sign out from all providers (Google, Apple)
    /// 2. Delete Firebase Auth user
    /// 3. Clear local session data
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        // Get current user info before deletion
        guard let sessionUser = UserDefaultsManager.shared.getObject(PSUser.self, forKey: UserDefaultsKeys.Session.user) else {
            let error = NSError(
                domain: "AccountDeletionService",
                code: 3000,
                userInfo: [NSLocalizedDescriptionKey: "No hay usuario en sesión para eliminar"]
            )
            completion(.failure(error))
            return
        }
        
        // Log the deletion request
        FirebaseAnalyticsManager.shared.logAuthEvent(
            "account_deletion_initiated",
            method: "-",
            userEmail: sessionUser.email,
            userId: sessionUser.id,
            isAnonymous: nil
        )
        
        // Step 1: Sign out from all providers to revoke tokens
        // This is important to prevent session restoration
        GIDSignIn.sharedInstance.signOut()
        
        // Step 2: Delete Firebase Auth user if authenticated
        if let firebaseUser = Auth.auth().currentUser {
            firebaseUser.delete { [weak self] error in
                if let error = error {
                    FirebaseAnalyticsManager.shared.logAuthEvent(
                        "account_deletion_failed",
                        method: "-",
                        userEmail: sessionUser.email,
                        userId: sessionUser.id,
                        error: error
                    )
                    completion(.failure(error))
                    return
                }
                
                // Step 3: Clear local session data
                self?.clearLocalSessionData()
                
                // Log successful deletion
                FirebaseAnalyticsManager.shared.logAuthEvent(
                    "account_deletion_success",
                    method: "-",
                    userEmail: sessionUser.email,
                    userId: sessionUser.id
                )
                
                completion(.success(()))
            }
        } else {
            // No Firebase user, just clear local data
            clearLocalSessionData()
            
            FirebaseAnalyticsManager.shared.logAuthEvent(
                "account_deletion_success",
                method: "-",
                userEmail: sessionUser.email,
                userId: sessionUser.id
            )
            
            completion(.success(()))
        }
    }
    
    /// Clear all local session data
    private func clearLocalSessionData() {
        // Sign out from Firebase Auth
        try? Auth.auth().signOut()
        
        // Clear UserDefaults
        UserDefaultsManager.shared.remove(forKey: UserDefaultsKeys.Session.user)
        
        // Clear SessionManager
        SessionManager.shared.clearSession()
    }
}
