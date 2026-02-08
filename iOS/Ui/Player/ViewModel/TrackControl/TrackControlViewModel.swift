//
//  AudioPlayer.swift
//  Play Secuence (iOS)
//
//  Created by Esteban Rafael Trivino Guerra on 9/09/22.
//

import AVFoundation

class TrackControlViewModel: ObservableObject, Identifiable {
    
    private let dataManager = CoreDataMultitrackManager()
    private let onTrackUpdate: (Track) -> Void
    
    private(set) var id: UUID
    private var player: AudioEnginePlayer
    private var track: Track
    
    init(track: Track, onTrackUpdate: @escaping (Track) -> Void = { _ in }) {
        self.track = track
        self.id = track.id
        self.onTrackUpdate = onTrackUpdate
        self.player = TrackControlViewModel.buildPlayer(track: track)
    }
    
    //TODO: Mover de lugar
    class func buildPlayer(track: Track) -> AudioEnginePlayer {
        let player = AudioEnginePlayer()
        
        do {
            let newTrackPath = UserPathManager.shared.getTrackPath(relativePath: track.relativePath)
            let newTrackUrl = URL(fileURLWithPath: newTrackPath)
            
            AppLogger.general.info("Loading track from path: \(newTrackPath)")
            AppLogger.general.info("File exists: \(FileManager.default.fileExists(atPath: newTrackPath))")
            
            // Determine file type hint from file extension
            let fileExtension = newTrackUrl.pathExtension.lowercased()
            let fileTypeHint: String
            
            switch fileExtension {
            case "wav":
                fileTypeHint = AVFileType.wav.rawValue
                AppLogger.general.info("Detected WAV file")
            case "mp3":
                fileTypeHint = AVFileType.mp3.rawValue
                AppLogger.general.info("Detected MP3 file")
            case "m4a":
                fileTypeHint = AVFileType.m4a.rawValue
                AppLogger.general.info("Detected M4A file")
            default:
                // Default to MP3 for unknown formats
                fileTypeHint = AVFileType.mp3.rawValue
                AppLogger.general.warning("Unknown audio format: \(fileExtension), defaulting to MP3")
            }
            
            // Load audio file into engine
            try player.loadAudioFile(at: newTrackUrl, fileTypeHint: fileTypeHint)
            
            player.volume = track.config.volumeWithMute
            player.pan = track.config.pan
            player.prepareToPlay()
            
            AppLogger.general.info("Successfully loaded track: \(track.name)")
            
        } catch let error {
            AppLogger.general.error("Failed to load track: \(error.localizedDescription)")
        }
        return player
    }
    
// MARK: Track methods
    var trackName: String {
        self.track.name
    }
    
    var mute: Bool {
        self.track.config.isMuted
    }
    
    func getTrack() -> Track {
        self.track
    }
    
// MARK: Player methods
    func play(at interval: TimeInterval) {
        self.player.play(atTime: interval)
    }
    
    private func muteTrack() {
        self.player.volume = 0
        self.track.config.isMuted = true
    }
    
    private func unmuteTrack() {
        self.player.volume = self.track.config.volume
        self.track.config.isMuted = false
    }
    
    func toogleMute() {
        if self.player.volume == 0 {
            self.unmuteTrack()
        } else {
            self.muteTrack()
        }
        self.updateTrack()
        self.objectWillChange.send()
    }
    
    func pauseTrack() {
        player.pause()
    }
    
    func stopTrack() {
        player.stop()
        player.currentTime = 0
    }
    
    var trackVolume: Float {
        get {
            self.track.config.isMuted ?
            self.track.config.volume * 100 :
            self.player.volume * 100
        }
        set {
            if !self.track.config.isMuted {
                self.player.volume = newValue/100
            }
            self.track.config.volume = newValue/100
            self.updateTrack()
            objectWillChange.send()
        }
    }
    
    var trackPan: PanOptions {
        get {
            self.converToPanOptions(from: self.track.config.pan)
        }
        set {
            self.track.config.pan = newValue.rawValue
            self.player.pan = newValue.rawValue
            self.updateTrack()
            objectWillChange.send()
        }
    }
    
    private func updateTrack() {
        // Don't update directly to CoreData, let the parent ViewModel handle it
        self.onTrackUpdate(self.track)
    }
    
    var currentTime: TimeInterval {
        get {
            self.player.currentTime
        }
        set {
            self.player.currentTime = newValue
        }
    }
    
    var deviceCurrentTime: TimeInterval {
        self.player.deviceCurrentTime
    }
    
    // MARK: Global Pitch Control
    func setGlobalPitch(_ pitch: Float) {
        self.player.pitch = pitch
    }
    
// MARK: Pan Options
    enum PanOptions: Float {
        case left = -1
        case center = 0
        case right = 1
    }
    
    private func converToPanOptions(from float: Float) -> PanOptions {
        if float == 0.0 {
            return .center
        } else if float > 0 {
            return .right
        } else {
            return .left
        }
    }
}
