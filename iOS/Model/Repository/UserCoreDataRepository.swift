//
//  UserCoreDataRepository.swift
//  Multitrack Player
//
//  Created by Esteban Triviño on 3/02/26.
//  This file is part of the Multitrack Player project.
//

import Foundation
import CoreData

/// Protocol for managing user-related CoreData operations
protocol UserCoreDataRepository {
    /// Delete all CoreData records for a specific user
    /// - Parameter userID: The user ID whose data should be deleted
    /// - Throws: CoreDataError if deletion fails
    func deleteUserData(userID: String) throws
}

/// Implementation of UserCoreDataRepository using CoreData
final class DefaultUserCoreDataRepository: UserCoreDataRepository {
    private let dataManager: CoreDataMultitrackManager
    
    init(dataManager: CoreDataMultitrackManager = CoreDataMultitrackManager()) {
        self.dataManager = dataManager
    }
    
    func deleteUserData(userID: String) throws {
        // Get all multitracks for this user
        let fetchRequest: NSFetchRequest<MultitrackDao> = MultitrackDao.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %@", userID)
        
        do {
            let userMultitracks = try dataManager.context.fetch(fetchRequest)
            
            // Delete all tracks associated with each multitrack
            for multitrackDao in userMultitracks {
                let trackFetchRequest: NSFetchRequest<TrackDao> = TrackDao.fetchRequest()
                trackFetchRequest.predicate = NSPredicate(format: "multitrack == %@", multitrackDao)
                
                do {
                    let tracks = try dataManager.context.fetch(trackFetchRequest)
                    for trackDao in tracks {
                        dataManager.context.delete(trackDao)
                    }
                } catch {
                    AppLogger.coreData.error("Error fetching tracks: \(error.localizedDescription)")
                }
                
                // Delete the multitrack
                dataManager.context.delete(multitrackDao)
            }
            
            // Commit changes
            dataManager.commit()
            AppLogger.coreData.info("Successfully deleted all CoreData records for user: \(userID)")
        } catch {
            AppLogger.coreData.error("Error deleting user data from CoreData: \(error.localizedDescription)")
            throw error
        }
    }
}
