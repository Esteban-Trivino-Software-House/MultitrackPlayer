//
//  LoginViewModel.swift
//  Play Secuence
//
//  Created by Esteban Triviño on 2/09/25.
//

import Foundation


final class LoginViewModel: ObservableObject {
    
    @Published var loginSuccessful: Bool = false
    @Published var showInitialView: Bool = false
    @Published var errorMessage: String?
    
    let authenticator: GoogleAuthenticatorManager
    
    init(authenticator: GoogleAuthenticatorManager) {
        self.authenticator = authenticator
    }
    
    func onAppear() {
        authenticator.restoreSession { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let user):
                SessionManager.shared.setSession(user: user)
                loginSuccessful = true
            case .failure:
                showInitialView = true
            }
        }
    }
    
    func onTapLoginWithGoogle() {
        authenticator.signIn{ [weak self] loginResult in
            guard let self else { return }
            switch loginResult {
            case .success(let user):
                SessionManager.shared.setSession(user: user)
                loginSuccessful = true
            case .failure:
                errorMessage = String(localized: "login_error")
            }
        }
    }
    
    func logOut() {
        authenticator.signOut()
        SessionManager.shared.clearSession()
        loginSuccessful = false
        showInitialView = true
    }
    
}
