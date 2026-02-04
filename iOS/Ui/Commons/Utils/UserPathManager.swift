//
//  UserPathManager.swift
//  Multitrack Player
//
//  Created by Esteban Triviño on 2/02/26.
//  This file is part of the Multitrack Player project.
//

import Foundation

/// Manages file paths for user-specific data
/// Ensures multitracks are separated by user and can be properly deleted with account
final class UserPathManager {
    static let shared = UserPathManager()
    
    private init() {}
    
    /// Get the current user's ID
    /// Returns "" if no user is logged in
    var currentUserID: String {
        SessionManager.shared.user?.id ?? ""
    }
    
    /// Get the Documents directory
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    /// Get the Users base directory
    private var usersDirectory: URL {
        documentsDirectory.appendingPathComponent("Users")
    }
    
    /// Get the current user's directory
    var currentUserDirectory: URL {
        usersDirectory.appendingPathComponent(currentUserID)
    }
    
    /// Get the Multitracks directory for the current user
    var currentUserMultitracksDirectory: URL {
        currentUserDirectory.appendingPathComponent("Multitracks")
    }
    
    /// Create user directories if they don't exist
    func createUserDirectoriesIfNeeded() {
        let fileManager = FileManager.default
        let multitracksDir = currentUserMultitracksDirectory
        
        if !fileManager.fileExists(atPath: multitracksDir.path) {
            do {
                try fileManager.createDirectory(at: multitracksDir, withIntermediateDirectories: true)
            } catch {
                AppLogger.general.error("Error creating user directories: \(error.localizedDescription)")
            }
        }
    }
    
    /// Get the full path for a track file
    /// - Parameter relativePath: The relative path within the user's multitracks directory
    /// - Returns: Full path as string
    func getTrackPath(relativePath: String) -> String {
        let userMultitracksDir = currentUserMultitracksDirectory
        return (userMultitracksDir.path as NSString).appendingPathComponent(relativePath)
    }
    
    /// Get the full URL for a track file
    /// - Parameter relativePath: The relative path within the user's multitracks directory
    /// - Returns: Full URL
    func getTrackURL(relativePath: String) -> URL {
        currentUserMultitracksDirectory.appendingPathComponent(relativePath)
    }
    
    /// Delete all user data including multitracks
    /// - Parameter userID: The user ID whose data should be deleted
    func deleteUserData(userID: String) {
        let fileManager = FileManager.default
        let userDirectory = usersDirectory.appendingPathComponent(userID)
        
        do {
            if fileManager.fileExists(atPath: userDirectory.path) {
                try fileManager.removeItem(at: userDirectory)
                AppLogger.general.info("User data deleted for userID: \(userID)")
            }
        } catch {
            AppLogger.general.error("Error deleting user data: \(error.localizedDescription)")
        }
    }
    
    /// Migrate old multitracks (without user folder) to new structure
    /// Call this once when updating to the new version
    func migrateOldMultitracks() {
        let fileManager = FileManager.default
        let oldMultitracksPath = documentsDirectory.appendingPathComponent("Multitracks")
        let newMultitracksPath = currentUserMultitracksDirectory
        
        // Only migrate if old path exists and new path doesn't
        if fileManager.fileExists(atPath: oldMultitracksPath.path) &&
           !fileManager.fileExists(atPath: newMultitracksPath.path) {
            do {
                // Create user directory first
                try fileManager.createDirectory(at: currentUserDirectory, withIntermediateDirectories: true)
                // Move old multitracks to new location
                try fileManager.moveItem(at: oldMultitracksPath, to: newMultitracksPath)
                AppLogger.general.info("Migrated old multitracks to user-specific folder")
            } catch {
                AppLogger.general.error("Error migrating old multitracks: \(error.localizedDescription)")
            }
        }
    }
}
