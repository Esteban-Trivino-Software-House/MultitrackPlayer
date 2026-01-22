//
//  LoginViewModel.swift
//  Play Secuence
//
//  Created by Esteban Triviño on 2/09/25.
//  This file is part of the Multitrack Player project.
//

import Foundation


final class LoginViewModel: ObservableObject {
    
    @Published var loginSuccessful: Bool = false
    @Published var showInitialView: Bool = false
    @Published var errorMessage: String?
    
    private let authService: AuthenticationService
    
    /// Initialize with custom authentication service (useful for testing)
    init(authService: AuthenticationService) {
        self.authService = authService
    }
    
    func onAppear() {
        authService.restoreSession { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                loginSuccessful = true
            case .failure:
                showInitialView = true
            }
        }
    }
    
    func onTapLoginWithGoogle() {
        authService.signInWithGoogle { [weak self] loginResult in
            guard let self else { return }
            switch loginResult {
            case .success:
                loginSuccessful = true
            case .failure:
                errorMessage = String(localized: "login_error")
            }
        }
    }
    
    func onTapLoginWithApple() {
        authService.signInWithApple { [weak self] loginResult in
            guard let self else { return }
            switch loginResult {
            case .success:
                loginSuccessful = true
            case .failure:
                errorMessage = String(localized: "login_error")
            }
        }
    }
    
    func logOut() {
        authService.signOut()
        loginSuccessful = false
        showInitialView = true
    }
    
}
