//
//  AuthenticationService.swift
//  Play Secuence
//
//  Created by Esteban Triviño on 22/01/26.
//  This file is part of the Multitrack Player project.
//

import Foundation
import FirebaseAuth

/// Facade/Coordinator for managing authentication across different providers
/// Provides a unified API for the app to interact with multiple authentication methods
final class AuthenticationService {
    
    // Authentication providers
    private let googleProvider: GoogleAuthProvider
    private let appleProvider: AppleAuthProvider
    
    // Track the currently active provider
    private var currentProvider: AuthenticationProvider?
    
    /// Initialize with custom providers (useful for testing)
    init(googleProvider: GoogleAuthProvider = GoogleAuthProvider(),
         appleProvider: AppleAuthProvider = AppleAuthProvider()) {
        self.googleProvider = googleProvider
        self.appleProvider = appleProvider
    }
    
    // MARK: - Public API
    
    /// Sign in with Google
    func signInWithGoogle(completion: @escaping (Result<PSUser, Error>) -> Void) {
        googleProvider.signIn { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                self.currentProvider = self.googleProvider
                self.saveUserSession(user)
                completion(.success(user))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Sign in with Apple
    func signInWithApple(completion: @escaping (Result<PSUser, Error>) -> Void) {
        appleProvider.signIn { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                self.currentProvider = self.appleProvider
                self.saveUserSession(user)
                completion(.success(user))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Sign out from the current session
    /// Clears the session regardless of which provider was used
    func signOut() {
        currentProvider?.signOut()
        currentProvider = nil
        SessionManager.shared.clearSession()
        UserDefaultsManager.shared.remove(forKey: UserDefaultsKeys.Session.user)
    }
    
    /// Attempt to restore a previous session from any provider
    /// Tries Google first, then Apple
    func restoreSession(completion: @escaping (Result<PSUser, Error>) -> Void) {
        // First try to restore from Google
        googleProvider.restoreSession { [weak self] googleResult in
            guard let self = self else { return }
            
            switch googleResult {
            case .success(let user):
                self.currentProvider = self.googleProvider
                self.saveUserSession(user)
                completion(.success(user))
                
            case .failure:
                // If Google fails, try Apple
                self.appleProvider.restoreSession { [weak self] appleResult in
                    guard let self = self else { return }
                    
                    if case .success(let user) = appleResult {
                        self.currentProvider = self.appleProvider
                        self.saveUserSession(user)
                    }
                    completion(appleResult)
                }
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func saveUserSession(_ user: PSUser) {
        SessionManager.shared.setSession(user: user)
        UserDefaultsManager.shared.setObject(user, forKey: UserDefaultsKeys.Session.user)
    }
}
