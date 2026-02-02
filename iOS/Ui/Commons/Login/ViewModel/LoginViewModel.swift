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
    @Published var isDeleting: Bool = false
    @Published var showDeleteConfirmation: Bool = false
    @Published var deletionSuccess: Bool = false
    @Published var userEmail: String?
    
    private let authService: AuthenticationService
    private lazy var accountDeletionService = AccountDeletionService()
    private var skipSessionRestore = false
    
    /// Initialize with custom authentication service (useful for testing)
    init(authService: AuthenticationService) {
        self.authService = authService
    }
    
    func onAppear() {
        // Skip session restore if we just deleted the account
        if skipSessionRestore {
            skipSessionRestore = false
            showInitialView = true
            return
        }
        
        authService.restoreSession { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.loadUserEmail()
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
                self.loadUserEmail()
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
                self.loadUserEmail()
                loginSuccessful = true
            case .failure:
                errorMessage = String(localized: "login_error")
            }
        }
    }
    
    func logOut() {
        authService.signOut()
        userEmail = nil
        loginSuccessful = false
        showInitialView = true
    }
    
    /// Request account deletion with confirmation
    /// Shows a confirmation dialog to prevent accidental deletion
    func requestAccountDeletion() {
        showDeleteConfirmation = true
    }
    
    /// Confirm and proceed with account deletion
    /// This will permanently delete the user account and all associated data
    func confirmAccountDeletion() {
        showDeleteConfirmation = false
        isDeleting = true
        
        accountDeletionService.deleteAccount { [weak self] result in
            guard let self = self else { return }
            
            self.isDeleting = false
            
            switch result {
            case .success:
                // Account deleted successfully
                // Set flag to skip session restore on next onAppear
                self.skipSessionRestore = true
                self.loginSuccessful = false
                self.showInitialView = true
                self.errorMessage = nil
                self.deletionSuccess = true
                
            case .failure:
                self.errorMessage = String(localized: "account_deletion_error")
            }
        }
    }
    
    /// Cancel account deletion request
    func cancelAccountDeletion() {
        showDeleteConfirmation = false
    }
    
    /// Dismiss the deletion success confirmation
    func dismissDeletionSuccess() {
        deletionSuccess = false
        // Reset login state to trigger navigation back to login screen
        // This will close the DashboardScreen and show LoginView
        self.loginSuccessful = false
        self.showInitialView = true
    }
    
    // MARK: - Private Methods
    
    private func loadUserEmail() {
        if let user = SessionManager.shared.user {
            userEmail = user.email
        }
    }
    
}
