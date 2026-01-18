//
//  SequenceControlsViewModel.swift
//  Play Secuence (iOS)
//
//  Created by Esteban Rafael Trivino Guerra on 8/09/22.
//

import Foundation
import os

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var multitracks = Dictionary<UUID, Multitrack>()
    @Published var trackControllers = Dictionary<UUID, TrackControlViewModel>()
    @Published var selectedMultitrackIndex: UUID?
    @Published var isLoading = true
    
    let multitrackRepository: MultitrackRepository
    let loginViewModel: LoginViewModel
    
    init(multitrackRepository: MultitrackRepository,
         loginViewModel: LoginViewModel) {
        self.multitrackRepository = multitrackRepository
        self.loginViewModel = loginViewModel
    }
    
    func onAppear() {
        // Loads local multiracks
        reloadMultitracks()
        
        // TODO: Get the selectedMultitrackIndex value from userdefaults and assign the value to selectedMultitrackIndex
        if let selectedMultitrackIndex = self.multitracks.first?.key {
            self.selectMultitrack(selectedMultitrackIndex)
        }
        hideLoader()
    }
    
    func selectMultitrack(_ multitrackId: UUID) {
        if self.selectedMultitrackIndex != multitrackId {
            reloadMultitracks()
            selectedMultitrackIndex = multitrackId
            stopTracks()
            trackControllers.removeAll()
            if let selectedMultitrackIndex = self.selectedMultitrackIndex,
               let tracks = multitracks[selectedMultitrackIndex]?.tracks {
                for track in tracks {
                    self.appendTrackController(using: track)
                }
            }
        }
    }
    
    private func reloadMultitracks() {
        self.multitracks = multitrackRepository.loadMultitracks()
    }
    
    func deleteMultitrack(_ multitrackId: UUID) {
        showLoader()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            guard let self = self else { return }
            if let selectedMultitrackIndex = self.selectedMultitrackIndex, multitrackId == selectedMultitrackIndex {
                stopTracks()
                trackControllers.removeAll()
                guard let multitrackToSelectIndex = self.multitracks.first?.key else {
                    self.selectedMultitrackIndex = nil
                    return
                }
                selectMultitrack(multitrackToSelectIndex)
            }
            deleteTracks(for: multitrackId)
            multitracks.removeValue(forKey: multitrackId)
            multitrackRepository.deleteMultitrack(multitrackId)
            hideLoader()
        }
    }
    
    private func deleteTracks(for multitrackId: UUID) {
        guard let multitrack = multitracks[multitrackId] else { return }
        let fileManager = FileManager.default
        
        multitrack.tracks.forEach { track in
            let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(track.relativePath)
            do {
                try fileManager.removeItem(at: URL(fileURLWithPath: path))
            } catch {
                AppLogger.general.error("Error deleting file \(path): \(error.localizedDescription)")
            }
        }
    }
    
    func deleteSelectedMultitrack() {
        guard let selectedMultitrackIndex = self.selectedMultitrackIndex else { return }
        self.deleteMultitrack(selectedMultitrackIndex)
    }
    
    func getSelectedMultitrackName() -> String {
        guard let selectedMultitrackIndex = self.selectedMultitrackIndex,
              let name = self.multitracks[selectedMultitrackIndex]?.name else {
            return "Multitrack"
        }
        return name
    }
    
    func createMultitrack(withName name: String, using tracksTmpUrls: [URL]) {
        showLoader()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            guard let self = self else { return }
            var multitrack = Multitrack(id: UUID(),
                                        name: name)
            for tmpUrl in tracksTmpUrls {
                let track = self.saveTrack(from: tmpUrl)
                multitrack.tracks.append(track)
            }
            self.multitracks[multitrack.id]  = multitrack
            self.multitrackRepository.saveMultitrack(multitrack)
            self.selectMultitrack(multitrack.id)
            self.hideLoader()
        }
    }
    
    func showLoader() {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = true
        }
    }
    
    func hideLoader() {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
        }
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
        
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(track.relativePath)
        
        let encryptedData = NSData(contentsOf: tmpUrl)
        if(encryptedData != nil){
            let fileManager = FileManager.default
            fileManager.createFile(atPath: path as String, contents: encryptedData as Data?, attributes: nil)
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
    
    func editMultitrackName(_ newName: String) {
        guard let selectedMultitrackIndex else { return }
        self.multitracks[selectedMultitrackIndex]?.name = newName
        multitrackRepository.updateMultitrackName(multitrackId: selectedMultitrackIndex, newName: newName)
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
    
    func didTapOnLogOut() {
        loginViewModel.logOut()
    }
}
