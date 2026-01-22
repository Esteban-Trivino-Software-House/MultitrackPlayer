//
//  AuthenticationProvider.swift
//  Play Secuence
//
//  Created by Esteban Triviño on 22/01/26.
//  This file is part of the Multitrack Player project.
//

import Foundation

/// Protocol that defines the contract for authentication providers
/// Each authentication method (Google, Apple, Email, etc.) implements this protocol
protocol AuthenticationProvider {
    /// Name of the provider for logging and analytics purposes
    var providerName: String { get }
    
    /// Sign in with this provider
    /// - Parameter completion: Result with PSUser on success or Error on failure
    func signIn(completion: @escaping (Result<PSUser, Error>) -> Void)
    
    /// Sign out from this provider
    func signOut()
    
    /// Attempt to restore a previous session
    /// - Parameter completion: Result with PSUser on success or Error on failure
    func restoreSession(completion: @escaping (Result<PSUser, Error>) -> Void)
}
