//
//  GoogleAuthenticatorManager.swift
//  Play Secuence
//
//  Created by Esteban Triviño on 2/09/25.
//

import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn

final class GoogleAuthenticatorManager {
    
    // MARK: Authentication with google
    
    func restoreSession(onComplete: @escaping (Result<PSUser, Error>) -> Void) {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                print("❌ No se pudo restaurar la sesión: \(error.localizedDescription)")
                onComplete(.failure(error))
                return
            }
            if let user = user?.psUser {
                onComplete(.success(user))
                print("✅ Sesión restaurada con: \(user.email ?? String.empty)")
            }
        }
    }
    
    func signIn(onComplete: @escaping (Result<PSUser, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Configuración de Google
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
                print("❌ Error al iniciar sesión con Google: \(error.localizedDescription)")
                return onComplete(.failure(error))
            }
            
            guard let user = result?.user.psUser else {
                return onComplete(
                    .failure(
                        NSError(
                            domain: "GoogleAuthenticatorManager",
                            code: 1001,
                            userInfo: [NSLocalizedDescriptionKey : "No se pudo obtener el usuario"]
                        )
                    )
                )
            }
            
            print("✅ Usuario: \(user.email ?? "Sin email")")
            onComplete(.success(user))
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }
    
    // MARK: Anonymous authentication
    
    func signInAnonymouslyIfNeeded() {
        guard let sessionUser = UserDefaultsManager.shared.get(forKey: UserDefaultsKeys.Session.user) as PSUser? else {
            signInWithGoogleAnonymously()
            return
        }
        SessionManager.shared.setSession(user: sessionUser)
    }
    
    func signInWithGoogleAnonymously() {
        Auth.auth().signInAnonymously { authResult, error in
            guard let user = authResult?.user else { return }
            let sessionUser = PSUser(id: user.uid, isAnonymous: true)
            UserDefaultsManager.shared.set(sessionUser, forKey: UserDefaultsKeys.Session.user)
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
