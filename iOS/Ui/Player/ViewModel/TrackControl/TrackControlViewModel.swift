//
//  AudioPlayer.swift
//  Play Secuence (iOS)
//
//  Created by Esteban Rafael Trivino Guerra on 9/09/22.
//

import AVFoundation

class TrackControlViewModel: ObservableObject, Identifiable {
    
    private let dataManager = CoreDataMultitrackManager()
    
    private(set) var id: UUID
    private var player: AVAudioPlayer
    private var track: Track
    
    init(track: Track) {
        self.track = track
        self.id = track.id
        self.player = TrackControlViewModel.buildPlayer(track: track)
    }
    
    //TODO: Mover de lugar
    class func buildPlayer(track: Track) -> AVAudioPlayer {
        var player: AVAudioPlayer
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            let newTrackPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(track.relativePath)
            let newTrackUrl = URL(fileURLWithPath: newTrackPath)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: newTrackUrl, fileTypeHint: AVFileType.mp3.rawValue)

            /* iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            player.setVolume(track.config.volumeWithMute, fadeDuration: .infinity)
            player.pan = track.config.pan
            player.prepareToPlay()
            
        } catch let error {
            player = AVAudioPlayer()
            AppLogger.general.error("\(error.localizedDescription)")
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
    
// MARK: Player methods
    func play(at interval: TimeInterval) {
        self.player.play(atTime: interval)
    }
    
    private func muteTrack() {
        self.player.setVolume(0, fadeDuration: .zero)
        self.track.config.isMuted = true
    }
    
    private func unmuteTrack() {
        self.player.setVolume(self.track.config.volume, fadeDuration: .zero)
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
        self.dataManager.updateTrack(self.track)
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
