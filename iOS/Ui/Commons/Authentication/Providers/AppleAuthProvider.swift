//
//  AppleAuthProvider.swift
//  Play Secuence
//
//  Created by Esteban Triviño on 22/01/26.
//  This file is part of the Multitrack Player project.
//

import Foundation
import AuthenticationServices
import CryptoKit

/// Apple Sign-In authentication provider
final class AppleAuthProvider: NSObject, AuthenticationProvider {
    
    let providerName = "apple"
    
    // Callback for completion
    private var currentCompletion: ((Result<PSUser, Error>) -> Void)?
    
    // Unhashed nonce for security
    private var currentNonce: String?
    
    // MARK: - AuthenticationProvider
    
    func restoreSession(completion: @escaping (Result<PSUser, Error>) -> Void) {
        // First, check if there's a stored user
        guard let storedUser = UserDefaultsManager.shared.getObject(PSUser.self, forKey: UserDefaultsKeys.Session.user),
              !storedUser.isAnonymous else {
            let error = NSError(
                domain: "AppleAuthProvider",
                code: 2000,
                userInfo: [NSLocalizedDescriptionKey: "No hay sesión de Apple almacenada"]
            )
            FirebaseAnalyticsManager.shared.logAuthEvent(
                "restore_session_failed",
                method: providerName,
                error: error
            )
            completion(.failure(error))
            return
        }
        
        // Verify that the Apple ID credential is still valid
        // This prevents the app from thinking there's a session when Apple has revoked it
        guard let userId = storedUser.id else {
            let error = NSError(
                domain: "AppleAuthProvider",
                code: 2001,
                userInfo: [NSLocalizedDescriptionKey: "User ID no disponible"]
            )
            FirebaseAnalyticsManager.shared.logAuthEvent(
                "restore_session_failed",
                method: providerName,
                error: error
            )
            completion(.failure(error))
            return
        }
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: userId) { [weak self] credentialState, error in
            guard let self = self else { return }
            
            switch credentialState {
            case .authorized:
                // User is still authorized, session is valid
                FirebaseAnalyticsManager.shared.logAuthEvent(
                    "restore_session_success",
                    method: self.providerName,
                    userEmail: storedUser.email,
                    userId: storedUser.id,
                    isAnonymous: storedUser.isAnonymous
                )
                completion(.success(storedUser))
                
            case .revoked, .notFound:
                // User revoked their authorization or the credential is no longer valid
                // Clear the stored session
                UserDefaultsManager.shared.remove(forKey: UserDefaultsKeys.Session.user)
                SessionManager.shared.clearSession()
                
                let error = NSError(
                    domain: "AppleAuthProvider",
                    code: 2002,
                    userInfo: [NSLocalizedDescriptionKey: "La sesión de Apple ha sido revocada"]
                )
                FirebaseAnalyticsManager.shared.logAuthEvent(
                    "restore_session_failed",
                    method: self.providerName,
                    error: error
                )
                completion(.failure(error))
                
            @unknown default:
                let error = NSError(
                    domain: "AppleAuthProvider",
                    code: 2003,
                    userInfo: [NSLocalizedDescriptionKey: "Estado de credencial desconocido"]
                )
                FirebaseAnalyticsManager.shared.logAuthEvent(
                    "restore_session_failed",
                    method: self.providerName,
                    error: error
                )
                completion(.failure(error))
            }
        }
    }
    
    func signIn(completion: @escaping (Result<PSUser, Error>) -> Void) {
        self.currentCompletion = completion
        
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func signOut() {
        // Get current user if available for analytics
        let sessionUser = UserDefaultsManager.shared.getObject(PSUser.self, forKey: UserDefaultsKeys.Session.user)
        FirebaseAnalyticsManager.shared.logAuthEvent(
            "logout",
            method: providerName,
            userEmail: sessionUser?.email,
            userId: sessionUser?.id,
            isAnonymous: sessionUser?.isAnonymous
        )
        
        // Apple doesn't require explicit sign out at SDK level
        // Session is cleared at the service level
    }
    
    // MARK: - Private Helpers
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleAuthProvider: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            let error = NSError(
                domain: "AppleAuthProvider",
                code: 2001,
                userInfo: [NSLocalizedDescriptionKey: "No se pudieron obtener las credenciales de Apple"]
            )
            FirebaseAnalyticsManager.shared.logAuthEvent("login_failed", method: providerName, error: error)
            currentCompletion?(.failure(error))
            return
        }
        
        // Extract user information
        let userId = appleIDCredential.user
        let email = appleIDCredential.email
        let fullName = appleIDCredential.fullName
        
        var name: String?
        if let givenName = fullName?.givenName, let familyName = fullName?.familyName {
            name = "\(givenName) \(familyName)"
        } else if let givenName = fullName?.givenName {
            name = givenName
        }
        
        let user = PSUser(
            id: userId,
            name: name,
            email: email,
            isAnonymous: false
        )
        
        FirebaseAnalyticsManager.shared.logAuthEvent(
            "login_success",
            method: providerName,
            userEmail: user.email,
            userId: user.id,
            isAnonymous: user.isAnonymous
        )
        
        currentCompletion?(.success(user))
        currentCompletion = nil
        currentNonce = nil
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        FirebaseAnalyticsManager.shared.logAuthEvent("login_failed", method: providerName, error: error)
        currentCompletion?(.failure(error))
        currentCompletion = nil
        currentNonce = nil
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleAuthProvider: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
            .first else {
            fatalError("No se pudo obtener la ventana principal")
        }
        return window
    }
}
