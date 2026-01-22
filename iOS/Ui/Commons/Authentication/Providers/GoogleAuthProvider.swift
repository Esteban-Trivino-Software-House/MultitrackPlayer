//
//  GoogleAuthProvider.swift
//  Play Secuence
//
//  Created by Esteban Triviño on 22/01/26.
//  This file is part of the Multitrack Player project.
//

import FirebaseCore
import FirebaseAuth
import GoogleSignIn

/// Google Sign-In authentication provider
final class GoogleAuthProvider: AuthenticationProvider {
    
    let providerName = "google"
    
    // MARK: - AuthenticationProvider
    
    func restoreSession(completion: @escaping (Result<PSUser, Error>) -> Void) {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                FirebaseAnalyticsManager.shared.logAuthEvent(
                    "restore_session_failed",
                    method: self.providerName,
                    userEmail: nil,
                    userId: nil,
                    isAnonymous: nil,
                    error: error
                )
                completion(.failure(error))
                return
            }
            
            if let user = user?.psUser {
                FirebaseAnalyticsManager.shared.logAuthEvent(
                    "restore_session_success",
                    method: self.providerName,
                    userEmail: user.email,
                    userId: user.id,
                    isAnonymous: user.isAnonymous
                )
                completion(.success(user))
            } else {
                let error = NSError(
                    domain: "GoogleAuthProvider",
                    code: 1002,
                    userInfo: [NSLocalizedDescriptionKey: "No se pudo obtener el usuario de la sesión"]
                )
                completion(.failure(error))
            }
        }
    }
    
    func signIn(completion: @escaping (Result<PSUser, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            let error = NSError(
                domain: "GoogleAuthProvider",
                code: 1000,
                userInfo: [NSLocalizedDescriptionKey: "No se pudo obtener el clientID de Firebase"]
            )
            FirebaseAnalyticsManager.shared.logAuthEvent(
                "login_failed",
                method: providerName,
                error: error
            )
            completion(.failure(error))
            return
        }
        
        // Configure Google Sign-In
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        
        guard let rootViewController = UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                .first?.rootViewController else {
            let error = NSError(
                domain: "GoogleAuthProvider",
                code: 1003,
                userInfo: [NSLocalizedDescriptionKey: "No se pudo obtener el rootViewController"]
            )
            completion(.failure(error))
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                FirebaseAnalyticsManager.shared.logAuthEvent(
                    "login_failed",
                    method: self.providerName,
                    error: error
                )
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user.psUser else {
                let nsError = NSError(
                    domain: "GoogleAuthProvider",
                    code: 1001,
                    userInfo: [NSLocalizedDescriptionKey: "No se pudo obtener el usuario"]
                )
                FirebaseAnalyticsManager.shared.logAuthEvent(
                    "login_failed",
                    method: self.providerName,
                    error: nsError
                )
                completion(.failure(nsError))
                return
            }
            
            FirebaseAnalyticsManager.shared.logAuthEvent(
                "login_success",
                method: self.providerName,
                userEmail: user.email,
                userId: user.id,
                isAnonymous: user.isAnonymous
            )
            completion(.success(user))
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        
        // Get current user if available for analytics
        let sessionUser = UserDefaultsManager.shared.getObject(PSUser.self, forKey: UserDefaultsKeys.Session.user)
        FirebaseAnalyticsManager.shared.logAuthEvent(
            "logout",
            method: providerName,
            userEmail: sessionUser?.email,
            userId: sessionUser?.id,
            isAnonymous: sessionUser?.isAnonymous
        )
    }
}

// MARK: - GIDGoogleUser Extension

extension GIDGoogleUser {
    var psUser: PSUser {
        .init(
            id: self.userID,
            name: self.profile?.name,
            email: self.profile?.email,
            isAnonymous: false
        )
    }
}
