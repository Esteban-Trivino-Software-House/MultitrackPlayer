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
    @Published var trackControllers: [TrackControlViewModel] = []
    @Published var selectedMultitrackIndex: UUID?
    @Published var isLoading = true
    
    let multitrackRepository: MultitrackRepository
    var loginViewModel: LoginViewModel
    private let dataManager = CoreDataMultitrackManager()
    
    init(multitrackRepository: MultitrackRepository,
         loginViewModel: LoginViewModel) {
        self.multitrackRepository = multitrackRepository
        self.loginViewModel = loginViewModel
    }
    
    func onAppear() {
        // Reset CoreData context to clear cached data from previous user
        dataManager.resetContext()
        
        // Create user-specific directories if needed
        UserPathManager.shared.createUserDirectoriesIfNeeded()
        
        // Migrate old multitracks if this is first launch after update
        UserPathManager.shared.migrateOldMultitracks()
        
        // Loads local multitracks
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
                // Tracks are already sorted by order from repository
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
            let path = UserPathManager.shared.getTrackPath(relativePath: track.relativePath)
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
            for (index, tmpUrl) in tracksTmpUrls.enumerated() {
                let track = self.saveTrack(from: tmpUrl, order: Int32(index))
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
    
    private func saveTrack(from tmpUrl: URL, order: Int32) -> Track {
        let trackId = UUID()
        let track = Track(
            id: trackId,
            name: tmpUrl.standardizedFileURL.deletingPathExtension().lastPathComponent,
            relativePath: trackId.uuidString.appending(tmpUrl.lastPathComponent),
            config: .init(pan: 0, volume: 0.5, isMuted: false),
            order: order
        )
        
        let destinationPath = UserPathManager.shared.getTrackPath(relativePath: track.relativePath)
        let destinationUrl = URL(fileURLWithPath: destinationPath)
        let fileManager = FileManager.default
        
        // Ensure the destination directory exists
        let destinationDir = destinationUrl.deletingLastPathComponent()
        do {
            try fileManager.createDirectory(at: destinationDir, withIntermediateDirectories: true, attributes: nil)
        } catch {
            AppLogger.general.error("Failed to create destination directory: \(error.localizedDescription)")
            return track
        }
        
        // Copy the file from source to destination
        // With asCopy: false, we need to handle security-scoped access
        var success = false
        
        // First, try with security-scoped access
        if tmpUrl.startAccessingSecurityScopedResource() {
            defer {
                tmpUrl.stopAccessingSecurityScopedResource()
            }
            
            do {
                // Remove existing file if it exists
                if fileManager.fileExists(atPath: destinationPath) {
                    try fileManager.removeItem(atPath: destinationPath)
                }
                
                // Copy the file
                try fileManager.copyItem(at: tmpUrl, to: destinationUrl)
                success = true
                AppLogger.general.info("Successfully copied track to: \(destinationPath)")
                AppLogger.general.info("File exists after copy: \(fileManager.fileExists(atPath: destinationPath))")
            } catch {
                AppLogger.general.error("Failed to copy track with security-scoped access: \(error.localizedDescription)")
            }
        } else {
            // Fallback: try without security-scoped access (for asCopy: true or already-copied files)
            do {
                if fileManager.fileExists(atPath: destinationPath) {
                    try fileManager.removeItem(atPath: destinationPath)
                }
                
                try fileManager.copyItem(at: tmpUrl, to: destinationUrl)
                success = true
                AppLogger.general.info("Successfully copied track (without security scope) to: \(destinationPath)")
            } catch {
                AppLogger.general.error("Failed to copy track without security-scoped access: \(error.localizedDescription)")
            }
        }
        
        if !success {
            AppLogger.general.warning("Track copy may have failed for: \(track.name)")
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
        self.trackControllers.append(TrackControlViewModel(track: track, onTrackUpdate: { [weak self] updatedTrack in
            self?.updateTrackInMultitrack(updatedTrack)
        }))
    }
    
    private func updateTrackInMultitrack(_ track: Track) {
        guard let selectedMultitrackIndex = self.selectedMultitrackIndex,
              let trackIndex = multitracks[selectedMultitrackIndex]?.tracks.firstIndex(where: { $0.id == track.id }) else {
            return
        }
        
        // Preserve the order from the current multitrack
        var updatedTrack = track
        updatedTrack.order = multitracks[selectedMultitrackIndex]!.tracks[trackIndex].order
        
        // Update in memory
        multitracks[selectedMultitrackIndex]?.tracks[trackIndex] = updatedTrack
        
        // Persist to CoreData with order preserved
        dataManager.updateTrack(updatedTrack)
    }
    
    func moveTrack(from source: IndexSet, to destination: Int) {
        trackControllers.move(fromOffsets: source, toOffset: destination)
        
        // Update order values and save to CoreData
        var tracksToUpdate: [Track] = []
        for (index, controller) in trackControllers.enumerated() {
            var track = controller.getTrack()
            track.order = Int32(index)
            tracksToUpdate.append(track)
        }
        
        // Update the multitrack's tracks order in memory
        if let selectedMultitrackIndex = self.selectedMultitrackIndex {
            self.multitracks[selectedMultitrackIndex]?.tracks = tracksToUpdate
        }
        
        // Persist to CoreData
        multitrackRepository.updateTracksOrder(tracksToUpdate)
    }
    
    func editMultitrackName(_ newName: String) {
        guard let selectedMultitrackIndex else { return }
        self.multitracks[selectedMultitrackIndex]?.name = newName
        multitrackRepository.updateMultitrackName(multitrackId: selectedMultitrackIndex, newName: newName)
    }
    
    func playTracks() {
        if let firstController = trackControllers.first {
            let timeToPlay = firstController.deviceCurrentTime + 1
            for controller in trackControllers {
                controller.play(at: timeToPlay)
            }
        }
    }
    
    func pauseTracks() {
        if let firstController = trackControllers.first {
            let currentPosition = firstController.currentTime
            for controller in trackControllers {
                controller.pauseTrack()
                controller.currentTime = currentPosition
            }
        }
    }
    
    func stopTracks() {
        for controller in trackControllers {
            controller.stopTrack()
        }
    }
    
    func didTapOnLogOut() {
        loginViewModel.logOut()
    }
}
