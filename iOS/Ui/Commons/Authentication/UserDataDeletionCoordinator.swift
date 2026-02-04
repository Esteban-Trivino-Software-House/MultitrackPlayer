//
//  UserDataDeletionCoordinator.swift
//  Multitrack Player
//
//  Created by Esteban Triviño on 3/02/26.
//  This file is part of the Multitrack Player project.
//

import Foundation

/// Protocol for coordinating complete user data deletion
protocol UserDataDeletionCoordinator {
    /// Delete all user data including CoreData records, files, and session
    /// - Parameters:
    ///   - userID: The user ID whose data should be deleted
    ///   - completion: Callback with result of deletion operation
    func deleteAllUserData(userID: String, completion: @escaping (Result<Void, Error>) -> Void)
}

/// Coordinator that orchestrates deletion of all user-related data
final class DefaultUserDataDeletionCoordinator: UserDataDeletionCoordinator {
    private let coreDataRepository: UserCoreDataRepository
    private let fileRepository: UserFileRepository
    private let sessionManager: SessionManager
    
    /// Initialize with repositories and session manager
    /// - Parameters:
    ///   - coreDataRepository: Repository for CoreData operations
    ///   - fileRepository: Repository for file operations
    ///   - sessionManager: Manager for user session
    init(coreDataRepository: UserCoreDataRepository = DefaultUserCoreDataRepository(),
         fileRepository: UserFileRepository = DefaultUserFileRepository(),
         sessionManager: SessionManager = SessionManager.shared) {
        self.coreDataRepository = coreDataRepository
        self.fileRepository = fileRepository
        self.sessionManager = sessionManager
    }
    
    func deleteAllUserData(userID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                completion(.failure(NSError(domain: "UserDataDeletionCoordinator", code: -1, userInfo: [NSLocalizedDescriptionKey: "Coordinator deallocated"])))
                return
            }
            
            do {
                // 1. Delete CoreData records
                AppLogger.general.info("Starting CoreData deletion for user: \(userID)")
                try self.coreDataRepository.deleteUserData(userID: userID)
                
                // 2. Delete files
                AppLogger.general.info("Starting file deletion for user: \(userID)")
                try self.fileRepository.deleteUserData(userID: userID)
                
                // 3. Clear session on main thread
                DispatchQueue.main.async { [weak self] in
                    self?.sessionManager.clearSession()
                    AppLogger.general.info("User session cleared for user: \(userID)")
                    completion(.success(()))
                }
            } catch {
                AppLogger.general.error("Error during user data deletion: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}
