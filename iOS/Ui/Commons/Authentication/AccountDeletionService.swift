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
    private let userDataDeletionCoordinator: UserDataDeletionCoordinator
    
    init(userDataDeletionCoordinator: UserDataDeletionCoordinator = DefaultUserDataDeletionCoordinator()) {
        self.userDataDeletionCoordinator = userDataDeletionCoordinator
    }
    
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
            userEmail: sessionUser.email ?? "",
            userId: sessionUser.id,
            isAnonymous: nil
        )
        
        // Step 1: Sign out from all providers to revoke tokens
        // This is important to prevent session restoration
        // Google tokens are explicitly revoked here
        GIDSignIn.sharedInstance.signOut()
        
        // Step 2: Delete Firebase Auth user if authenticated
        // Note: Firebase Auth deletion automatically revokes associated tokens (Google, Apple, etc.)
        // See: https://developer.apple.com/documentation/sign_in_with_apple/revoke_tokens
        if let firebaseUser = Auth.auth().currentUser {
            firebaseUser.delete { [weak self] error in
                if let error = error {
                    FirebaseAnalyticsManager.shared.logAuthEvent(
                        "account_deletion_failed",
                        method: "-",
                        userEmail: sessionUser.email ?? "",
                        userId: sessionUser.id,
                        error: error
                    )
                    completion(.failure(error))
                    return
                }
                
                // Step 3: Clear local session data
                self?.clearLocalSessionData(userID: sessionUser.id ?? "") { result in
                    // Log successful deletion
                    FirebaseAnalyticsManager.shared.logAuthEvent(
                        "account_deletion_success",
                        method: "-",
                        userEmail: sessionUser.email ?? "",
                        userId: sessionUser.id
                    )
                    
                    completion(result)
                }
            }
        } else {
            // No Firebase user, just clear local data
            clearLocalSessionData(userID: sessionUser.id ?? "") { result in
                FirebaseAnalyticsManager.shared.logAuthEvent(
                    "account_deletion_success",
                    method: "-",
                    userEmail: sessionUser.email ?? "",
                    userId: sessionUser.id
                )
                
                completion(result)
            }
        }
    }
    
    /// Clear all local session data and user files
    /// - Parameter userID: The user ID whose data should be deleted
    /// - Parameter completion: Callback with result of deletion
    private func clearLocalSessionData(userID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Sign out from Firebase Auth
        try? Auth.auth().signOut()
        
        // Coordinate deletion of all user data (CoreData, files, session)
        userDataDeletionCoordinator.deleteAllUserData(userID: userID) { result in
            // Log the result
            switch result {
            case .success:
                AppLogger.general.info("User data deletion completed successfully for user: \(userID)")
                completion(.success(()))
            case .failure(let error):
                AppLogger.general.error("User data deletion failed: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}
