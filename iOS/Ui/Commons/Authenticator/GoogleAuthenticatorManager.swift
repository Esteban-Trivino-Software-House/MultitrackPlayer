
//
//  GoogleAuthenticatorManager.swift
//  Play Secuence
//
//  Created by Esteban Triviño on 2/09/25.
//  This file is part of the Multitrack Player project.
//

import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn

final class GoogleAuthenticatorManager {
    
    // MARK: Google authentication
    
    func restoreSession(onComplete: @escaping (Result<PSUser, Error>) -> Void) {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                FirebaseAnalyticsManager.shared.logAuthEvent("restore_session_failed", method: "google", userEmail: nil, userId: nil, isAnonymous: nil, error: error)
                onComplete(.failure(error))
                return
            }
            if let user = user?.psUser {
                FirebaseAnalyticsManager.shared.logAuthEvent("restore_session_success", method: "google", userEmail: user.email, userId: user.id, isAnonymous: user.isAnonymous)
                onComplete(.success(user))
            }
        }
    }
    
    func signIn(onComplete: @escaping (Result<PSUser, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Google configuration
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        guard let rootViewController = UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                .first?.rootViewController else {
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) {
            result,
            error in
            if let error {
                FirebaseAnalyticsManager.shared.logAuthEvent("login_failed", method: "google", error: error)
                return onComplete(.failure(error))
            }
            guard let user = result?.user.psUser else {
                let nsError = NSError(
                    domain: "GoogleAuthenticatorManager",
                    code: 1001,
                    userInfo: [NSLocalizedDescriptionKey : "No se pudo obtener el usuario"]
                )
                FirebaseAnalyticsManager.shared.logAuthEvent(
                    "login_failed",
                    method: "google",
                    error: nsError
                )
                return onComplete(.failure(nsError))
            }
            FirebaseAnalyticsManager.shared.logAuthEvent(
                "login_success",
                method: "google",
                userEmail: user.email,
                userId: user.id,
                isAnonymous: user.isAnonymous
            )
            onComplete(.success(user))
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        // Get current user if available
        let sessionUser = UserDefaultsManager.shared.getObject(PSUser.self, forKey: UserDefaultsKeys.Session.user)
        FirebaseAnalyticsManager.shared.logAuthEvent(
            "logout",
            method: "google",
            userEmail: sessionUser?.email,
            userId: sessionUser?.id,
            isAnonymous: sessionUser?.isAnonymous
        )
    }
    
    // MARK: Anonymous authentication - Not yet implemented for production
    
    func signInAnonymouslyIfNeeded() {
        guard let sessionUser = UserDefaultsManager.shared.getObject(PSUser.self, forKey: UserDefaultsKeys.Session.user) else {
            signInWithGoogleAnonymously()
            return
        }
        SessionManager.shared.setSession(user: sessionUser)
    }
    
    func signInWithGoogleAnonymously() {
        Auth.auth().signInAnonymously { authResult, error in
            guard let user = authResult?.user else { return }
            let sessionUser = PSUser(id: user.uid, isAnonymous: true)
            UserDefaultsManager.shared.setObject(sessionUser, forKey: UserDefaultsKeys.Session.user)
            SessionManager.shared.setSession(user: sessionUser)
        }
    }
}

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
