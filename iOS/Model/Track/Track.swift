//
//  AudioUrl.swift
//  Play Secuence (iOS)
//
//  Created by Esteban Rafael Trivino Guerra on 9/09/22.
//

import Foundation
import CoreData

struct Track: Identifiable {
    var id: UUID
    var name: String
    var relativePath: String
    var config: Track.Config
    var order: Int32
    
    struct Config {
        var pan: Float
        var volume: Float
        var isMuted: Bool
        
        var volumeWithMute: Float {
            isMuted ? 0 : volume
        }
    }
}

extension Track {
    func mapToTrackDao(context: NSManagedObjectContext, with multitrack: MultitrackDao) -> TrackDao {
        let trackDao = TrackDao(context: context)
        trackDao.multitrack = multitrack
        trackDao.id = self.id
        trackDao.name = self.name
        trackDao.relativePath = self.relativePath
        trackDao.pan = self.config.pan
        trackDao.volume = self.config.volume
        trackDao.order = self.order
        return trackDao
    }
}

extension TrackDao {
    func mapToTrack() -> Track {
        Track(
            id: self.id ?? UUID(),
            name: self.name ?? String.empty,
            relativePath: self.relativePath ?? String.empty,
            config: .init(pan: self.pan, volume: self.volume, isMuted: self.mute),
            order: self.order
        )
    }
}
