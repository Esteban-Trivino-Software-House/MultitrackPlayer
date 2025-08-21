//
//  SequenceControlsViewModel.swift
//  Play Secuence (iOS)
//
//  Created by Esteban Rafael Trivino Guerra on 8/09/22.
//

import Foundation

final class DashboardViewModel: ObservableObject {
    @Published var multitracks = Dictionary<UUID, Multitrack>()
    @Published var trackControllers = Dictionary<UUID, TrackControlViewModel>()
    private(set) var selectedMultitrackIndex: UUID?
    
    let multitrackRepository: MultitrackRepository = MultitrackLocalRepository()
    
    func onAppear() {
        // Loads local multiracks
        self.multitracks = multitrackRepository.loadMultitracks()
        
        // TODO: Get the selectedMultitrackIndex value from userdefaults and assign the value to selectedMultitrackIndex
        if let selectedMultitrackIndex = self.multitracks.first?.key {
            self.selectMultitrack(selectedMultitrackIndex)
        }
    }
    
    func selectMultitrack(_ multitrackId: UUID) {
        if self.selectedMultitrackIndex != multitrackId {
            self.selectedMultitrackIndex = multitrackId
            self.stopTracks()
            trackControllers.removeAll()
            if let selectedMultitrackIndex = self.selectedMultitrackIndex,
               let tracks = multitracks[selectedMultitrackIndex]?.tracks {
                for track in tracks {
                    self.appendTrackController(using: track)
                }
                self.objectWillChange.send()
            }
        }
    }
    
    func deleteMultitrack(_ multitrackId: UUID) {
        if let selectedMultitrackIndex = self.selectedMultitrackIndex,
           multitrackId == selectedMultitrackIndex {
            self.selectedMultitrackIndex = nil
        }
        self.multitracks.removeValue(forKey: multitrackId)
        self.multitrackRepository.deleteMultitrack(multitrackId)
    }
    
    func deleteSelectedMultitrack() {
        if let selectedMultitrackIndex = self.selectedMultitrackIndex {
            self.deleteMultitrack(selectedMultitrackIndex)
        }
    }
    
    func getSelectedMultitrackName() -> String {
        guard let selectedMultitrackIndex = self.selectedMultitrackIndex,
              let name = self.multitracks[selectedMultitrackIndex]?.name else {
            return "Multitrack"
        }
        return name
    }
    
    func createMultitrack(with tracksTmpUrls: [URL]) {
        var multitrack = Multitrack(id: UUID(),
                                    name: "Multitrack \(self.multitracks.count)")
        for tmpUrl in tracksTmpUrls {
            let track = self.saveTrack(from: tmpUrl)
            multitrack.tracks.append(track)
        }
        self.multitracks[multitrack.id]  = multitrack
        self.multitrackRepository.saveMultitrack(multitrack)
        self.selectMultitrack(multitrack.id)
    }
    
    private func saveTrack(from tmpUrl: URL) -> Track {
        
//        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let urlToSave = documentsUrl.appendingPathComponent(url.lastPathComponent)
        
        let trackId = UUID()
        let track = Track(
            id: trackId,
            name: tmpUrl.standardizedFileURL.deletingPathExtension().lastPathComponent,
            relativePath: trackId.uuidString.appending(tmpUrl.lastPathComponent),
            config: .init(pan: 0, volume: 0.5, isMuted: false)
        )
        
        let basePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(track.relativePath)
        print(basePath)
        
        let encryptedData = NSData(contentsOf: tmpUrl)
        if(encryptedData != nil){
            let fileManager = FileManager.default
            fileManager.createFile(atPath: basePath as String, contents: encryptedData as Data?, attributes: nil)
        }
        return track
    }

    func getSelectedMultitrack() -> Multitrack? {
        if let selectedMultitrack = self.selectedMultitrackIndex {
            return self.multitracks[selectedMultitrack]
        } else {
            return nil
        }
    }
    
    func appendTrackController(using track: Track) {
        self.trackControllers[track.id] = TrackControlViewModel(track: track)
    }
    
    func playTracks() {
        if let firstController = trackControllers.first?.value {
            let timeToPlay = firstController.deviceCurrentTime + 1
            for controller in trackControllers.values.map({$0}) {
                controller.play(at: timeToPlay)
            }
        }
    }
    
    func pauseTracks() {
        if let firstController = trackControllers.first?.value {
            let currentPosition = firstController.currentTime
            for controller in trackControllers.values.map({$0}) {
                controller.pauseTrack()
                controller.currentTime = currentPosition
            }
        }
    }
    
    func stopTracks() {
        for controller in trackControllers {
            controller.value.stopTrack()
        }
    }
}
