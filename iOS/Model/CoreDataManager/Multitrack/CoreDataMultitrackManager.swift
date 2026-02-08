//
//  CoreDataMultitrackManager.swift
//  Play Secuence (iOS)
//
//  Created by Esteban Rafael Trivino Guerra on 27/02/23.
//

import Foundation
import os
import CoreData



class CoreDataMultitrackManager {// Get Core Data managed object context
    
    let container = NSPersistentContainer(name: "Sequences")
    
    var context: NSManagedObjectContext {
        self.container.viewContext
    }
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                AppLogger.coreData.error("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    func commit() {
        do {
            try self.container.viewContext.save()
        } catch {
            AppLogger.coreData.error("Core Data commit error: \(error.localizedDescription)")
        }
    }
    
    /// Reset the Core Data context to clear cached data
    /// Call this when user logs out to ensure clean data when new user logs in
    func resetContext() {
        self.container.viewContext.reset()
    }
    
    // MARK: Multitracks
    func saveMultitrack(_ multitrack: Multitrack) {
        let multitrackDao = multitrack.mapToMultitrackDao(context: self.context)
        self.saveTracks(multitrack.tracks, for: multitrackDao)
    }
    
    func updateMultitrackName(multitrackId: UUID, newName: String) {
        let fetchRequest: NSFetchRequest<MultitrackDao> = MultitrackDao.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", multitrackId as CVarArg)
        
        do {
            if let multitrackDao = try self.context.fetch(fetchRequest).first {
                multitrackDao.name = newName
                self.commit()
            }
        } catch {
            AppLogger.coreData.error("Unable to Update MultitrackDao in updateMultitrackName, (\(error.localizedDescription))")
        }
    }
    
    func updateMultitrackPitch(multitrackId: UUID, pitch: Float) {
        let fetchRequest: NSFetchRequest<MultitrackDao> = MultitrackDao.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", multitrackId as CVarArg)
        
        do {
            if let multitrackDao = try self.context.fetch(fetchRequest).first {
                multitrackDao.pitch = pitch
                self.commit()
            }
        } catch {
            AppLogger.coreData.error("Unable to Update MultitrackDao in updateMultitrackPitch, (\(error.localizedDescription))")
        }
    }
    
    func loadMultitracks() -> [MultitrackDao] {
        var multitracks: [MultitrackDao] = []
        let fetchRequest: NSFetchRequest<MultitrackDao> = MultitrackDao.fetchRequest()
        
        // Filter by current user
        let currentUserId = SessionManager.shared.user?.id ?? ""
        fetchRequest.predicate = NSPredicate(format: "userId == %@", currentUserId)
        
        do {
            multitracks = try self.context.fetch(fetchRequest)
        } catch {
            AppLogger.coreData.error("Unable to Fetch MultitrackDaos, (\(error.localizedDescription))")
        }
        return multitracks
    }
    
    // MARK: Tracks
    
    func updateTrack(_ track: Track) {
        let fetchRequest: NSFetchRequest<TrackDao> = TrackDao.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", track.id as CVarArg)
        do {
            if let trackDao = try self.context.fetch(fetchRequest).first {
                trackDao.name = track.name
                trackDao.relativePath = track.relativePath
                trackDao.volume = track.config.volume
                trackDao.pan = track.config.pan
                trackDao.mute = track.config.isMuted
                trackDao.order = track.order
                self.commit()
            }
        } catch {
            AppLogger.coreData.error("Unable to Update TrackDao in updateTrack, (\(error.localizedDescription))")
        }
    }
    
    func updateTracksOrder(_ tracks: [Track]) {
        for track in tracks {
            let fetchRequest: NSFetchRequest<TrackDao> = TrackDao.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", track.id as CVarArg)
            do {
                if let trackDao = try self.context.fetch(fetchRequest).first {
                    trackDao.order = track.order
                }
            } catch {
                AppLogger.coreData.error("Unable to Update TrackDao order, (\(error.localizedDescription))")
            }
        }
        self.commit()
    }
    
    func saveTracks(_ tracks: [Track], for multitrack: MultitrackDao) {
        tracks.forEach() { track in
            _ = track.mapToTrackDao(context: self.context, with: multitrack)
        }
    }
    
    func loadTracks(for multitrack: MultitrackDao) -> [TrackDao] {
        var tracks: [TrackDao] = []
        let fetchRequest: NSFetchRequest<TrackDao> = TrackDao.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "multitrack == %@", multitrack)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        do {
            tracks = try self.context.fetch(fetchRequest)
        } catch {
            AppLogger.coreData.error("Unable to Fetch TrackDaos in loadTracks, (\(error.localizedDescription))")
        }
        return tracks
    }
    
    func deleteMultitracks() {
        // Load only current user's multitracks
        let currentUserId = SessionManager.shared.user?.id ?? ""
        let fetchRequest: NSFetchRequest<MultitrackDao> = MultitrackDao.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %@", currentUserId)
        
        do {
            let userMultitracks = try self.context.fetch(fetchRequest)
            userMultitracks.forEach() { multitrackDao in
                self.loadTracks(for: multitrackDao).forEach() { trackDao in
                    self.context.delete(trackDao)
                }
                self.context.delete(multitrackDao)
            }
            self.commit()
        } catch {
            AppLogger.coreData.error("Unable to Delete MultitrackDaos in deleteMultitracks, (\(error.localizedDescription))")
        }
    }
    
    func deleteMultitrack(_ multitrackId: UUID) {
        let fetchRequest: NSFetchRequest<MultitrackDao> = MultitrackDao.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", multitrackId as CVarArg)
        do {
            if let multitrackDao = try self.context.fetch(fetchRequest).first {
                self.loadTracks(for: multitrackDao).forEach() { trackDao in
                    self.context.delete(trackDao)
                }
                self.context.delete(multitrackDao)
                self.commit()
            }
        } catch {
            AppLogger.coreData.error("Unable to Delete MultitrackDao in deleteMultitrack, (\(error.localizedDescription))")
        }
    }
}
