//
//  UserFileRepository.swift
//  Multitrack Player
//
//  Created by Esteban Triviño on 3/02/26.
//  This file is part of the Multitrack Player project.
//

import Foundation

/// Protocol for managing user-related file operations
protocol UserFileRepository {
    /// Delete all files associated with a specific user
    /// - Parameter userID: The user ID whose files should be deleted
    /// - Throws: FileManagerError if deletion fails
    func deleteUserData(userID: String) throws
}

/// Implementation of UserFileRepository using FileManager
final class DefaultUserFileRepository: UserFileRepository {
    private let userPathManager: UserPathManager
    
    init(userPathManager: UserPathManager = UserPathManager.shared) {
        self.userPathManager = userPathManager
    }
    
    func deleteUserData(userID: String) throws {
        // UserPathManager.deleteUserData already handles file deletion
        userPathManager.deleteUserData(userID: userID)
        AppLogger.general.info("User files deleted for userID: \(userID)")
    }
}
