//
//  AudioEnginePlayer.swift
//  Play Secuence (iOS)
//
//  Created by Esteban Rafael Trivino Guerra on 6/02/26.
//  Audio playback engine with pitch shifting support
//

import AVFoundation

/// Audio player with real-time pitch shifting via AVAudioEngine
class AudioEnginePlayer {
    // MARK: - Audio Engine Components
    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let pitchNode = AVAudioUnitTimePitch()
    private let mixerNode = AVAudioMixerNode()
    
    // MARK: - Audio File Storage
    private var audioFile: AVAudioFile?
    
    // MARK: - State
    private var _volume: Float = 1.0
    private var _pan: Float = 0.0
    private var _pitch: Float = 0.0
    private var isEngineRunning = false
    
    // MARK: - Initialization
    init() {
        setupAudioEngine()
    }
    
    // MARK: - Setup
    private func setupAudioEngine() {
        do {
            // Configure audio session
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .duckOthers])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            // Attach nodes to engine
            audioEngine.attach(playerNode)
            audioEngine.attach(pitchNode)
            audioEngine.attach(mixerNode)
            
            // Initialize mixer pan to center
            mixerNode.pan = 0.0
            
            // Connect nodes: playerNode -> mixerNode (pan/volume) -> pitchNode -> outputNode
            let outputNode = audioEngine.outputNode
            
            audioEngine.connect(playerNode, to: mixerNode, format: nil)
            audioEngine.connect(mixerNode, to: pitchNode, format: nil)
            audioEngine.connect(pitchNode, to: outputNode, format: nil)
            
            // Start the engine
            try audioEngine.start()
            isEngineRunning = true
            
            // Log node formats for debugging
            let playerFormat = playerNode.outputFormat(forBus: 0)
            let mixerFormat = mixerNode.outputFormat(forBus: 0)
            let pitchFormat = pitchNode.outputFormat(forBus: 0)
            let outputFormat = outputNode.outputFormat(forBus: 0)
            
            AppLogger.general.info("Player Node Format - Channels: \(playerFormat.channelCount), Sample Rate: \(playerFormat.sampleRate)")
            AppLogger.general.info("Mixer Node Format - Channels: \(mixerFormat.channelCount), Sample Rate: \(mixerFormat.sampleRate)")
            AppLogger.general.info("Pitch Node Format - Channels: \(pitchFormat.channelCount), Sample Rate: \(pitchFormat.sampleRate)")
            AppLogger.general.info("Output Node Format - Channels: \(outputFormat.channelCount), Sample Rate: \(outputFormat.sampleRate)")
            AppLogger.general.info("AudioEngine initialized successfully")
        } catch {
            AppLogger.general.error("Failed to setup AudioEngine: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Load and Prepare
    func loadAudioFile(at url: URL, fileTypeHint: String) throws {
        // Load audio file
        let audioFile = try AVAudioFile(forReading: url)
        self.audioFile = audioFile
        
        // Schedule the audio file for playback
        try playerNode.scheduleFile(audioFile, at: nil)
        
        let format = audioFile.processingFormat
        AppLogger.general.info("Audio file loaded: \(url.lastPathComponent)")
        AppLogger.general.info("Audio format - Channels: \(format.channelCount), Sample Rate: \(format.sampleRate), Bit Depth: \(format.commonFormat.rawValue)")
    }
    
    func prepareToPlay() {
        // Player node is ready when file is scheduled
        AppLogger.general.info("Audio engine prepared")
    }
    
    // MARK: - Playback Control
    func play(atTime time: TimeInterval? = nil) {
        guard isEngineRunning else {
            AppLogger.general.warning("Audio engine not running")
            return
        }
        
        if !playerNode.isPlaying {
            if let time = time, time > 0 {
                // Schedule file again starting at specific time
                do {
                    if let audioFile = audioFile {
                        let frameCount = audioFile.length
                        let startFrame = AVAudioFramePosition(Double(time) * Double(audioFile.processingFormat.sampleRate))
                        
                        if startFrame < frameCount {
                            playerNode.stop()
                            try playerNode.scheduleSegment(audioFile, startingFrame: startFrame, frameCount: AVAudioFrameCount(frameCount - startFrame), at: nil)
                        }
                    }
                } catch let error {
                    AppLogger.general.error("Failed to schedule audio segment: \(error.localizedDescription)")
                }
            }
            
            playerNode.play()
            AppLogger.general.info("Playback started")
        }
    }
    
    func pause() {
        playerNode.pause()
        AppLogger.general.info("Playback paused")
    }
    
    func stop() {
        playerNode.stop()
        AppLogger.general.info("Playback stopped")
    }
    
    // MARK: - Properties
    var isPlaying: Bool {
        return playerNode.isPlaying
    }
    
    var volume: Float {
        get { _volume }
        set {
            let clampedVolume = max(0, min(1, newValue))
            _volume = clampedVolume
            mixerNode.outputVolume = clampedVolume
        }
    }
    
    var pan: Float {
        get {
            AppLogger.general.debug("Pan getter: \(self._pan)")
            return self._pan
        }
        set {
            let clampedValue = max(-1, min(1, newValue))
            AppLogger.general.info("Pan setter called: newValue=\(newValue), clamped=\(clampedValue)")
            self._pan = clampedValue
            
            // Set pan on mixer node
            let beforePan = self.mixerNode.pan
            self.mixerNode.pan = clampedValue
            let afterPan = self.mixerNode.pan
            
            AppLogger.general.info("Pan updated - before: \(beforePan), after: \(afterPan), _pan: \(self._pan)")
            AppLogger.general.info("Mixer pan property now: \(self.mixerNode.pan)")
        }
    }
    
    /// Pitch in semitones (-6 to +6)
    /// Updates AVAudioUnitTimePitch in real-time
    var pitch: Float {
        get { _pitch }
        set {
            let clampedPitch = max(-6, min(6, newValue))
            _pitch = clampedPitch
            
            // Convert semitones to pitch cents (100 cents = 1 semitone)
            let pitchCents = clampedPitch * 100.0
            pitchNode.pitch = pitchCents
            
            AppLogger.general.info("Pitch updated: \(clampedPitch) semitones (\(pitchCents) cents)")
        }
    }
    
    var currentTime: TimeInterval {
        get {
            guard let audioFile = audioFile else { return 0 }
            let sampleRate = audioFile.processingFormat.sampleRate
            let currentSampleTime = Double(playerNode.lastRenderTime?.sampleTime ?? 0)
            return currentSampleTime / Double(sampleRate)
        }
        set {
            // Seek to new time by rescheduling the file
            guard let audioFile = audioFile else { return }
            
            let sampleRate = audioFile.processingFormat.sampleRate
            let newSampleTime = AVAudioFramePosition(newValue * Double(sampleRate))
            
            playerNode.stop()
            do {
                try playerNode.scheduleSegment(audioFile, startingFrame: newSampleTime, frameCount: AVAudioFrameCount(audioFile.length - newSampleTime), at: nil)
                if isPlaying {
                    playerNode.play()
                }
            } catch let error {
                AppLogger.general.error("Failed to seek: \(error.localizedDescription)")
            }
        }
    }
    
    var deviceCurrentTime: TimeInterval {
        // Return the same as currentTime for consistency
        // In a real implementation, AVAudioEngine doesn't have a direct deviceCurrentTime equivalent
        return currentTime
    }
    
    // MARK: - Cleanup
    deinit {
        stop()
        audioEngine.stop()
    }
}
