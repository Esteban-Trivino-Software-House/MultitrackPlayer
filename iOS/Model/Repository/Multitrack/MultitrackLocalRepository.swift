//
//  MultitrackRepository.swift
//  Play Secuence (iOS)
//
//  Created by Esteban Rafael Trivino Guerra on 25/02/23.
//

import Foundation

class MultitrackLocalRepository: MultitrackRepository {
    
    private let dataManager: CoreDataMultitrackManager
    
    public init(dataManager: CoreDataMultitrackManager) {
        self.dataManager = dataManager
    }
    
    func saveMultitrack(_ multitrack: Multitrack) {
        self.dataManager.saveMultitrack(multitrack)
        self.dataManager.commit()
    }
    
    func loadMultitracks() -> Dictionary<UUID, Multitrack> {
        var multitracks = Dictionary<UUID, Multitrack>()
        self.dataManager.loadMultitracks().forEach() { multitrackDao in
            var multitrack = multitrackDao.mapToMultitrack()
            /// Loads multitrack's tracks
            multitrack.tracks = self.dataManager.loadTracks(for: multitrackDao).map() { $0.mapToTrack() }
            
            multitracks[multitrack.id] = multitrack
        }
        return multitracks
    }
    
    func loadMultitrack(id: UUID) -> Multitrack {
    Multitrack(id: id, name: String.empty, tracks: [])
    }
    
    func deleteMultitrack(_ multitrackId: UUID) {
        self.dataManager.deleteMultitrack(multitrackId)
        self.dataManager.commit()
    }
    
    func updateMultitrackName(multitrackId: UUID, newName: String) {
        dataManager.updateMultitrackName(multitrackId: multitrackId, newName: newName)
    }
}
