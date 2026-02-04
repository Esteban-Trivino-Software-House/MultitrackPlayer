//
//  ContentView.swift
//  Shared
//
//  Created by Esteban Rafael Trivino Guerra on 8/09/22.
//

import SwiftUI
import AVFoundation

struct DashboardScreen: View {
    @State private var showPicker: Bool = false
    @State private var showNewMultitrackNameInputDialog: Bool = false
    @State private var showEditMultitrackNameInputDialog: Bool = false
    @State private var showAccountScreen: Bool = false
    @State private var showAppInfo: Bool = false
    @StateObject private var viewModel: DashboardViewModel
    @State private var presentModalDelete: Bool = false
    @State private var newMultitrackNameTmp: String = String.empty
    @State private var selectedAudioFilesUrls: [URL] = []
    @State private var suggestedMultitrackName: String = ""
    @Environment(\.dismiss) var dismiss
    
    init(viewModel: DashboardViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .center) {
                VStack {
                    Header(showAccountScreenBinding: $showAccountScreen, showAppInfoBinding: $showAppInfo)
                    switch viewModel.isLoading {
                        case true:
                        LoadingScreen()
                        case false:
                        content
                    }
                }
                .onAppear(){
                    self.viewModel.onAppear()
                }
                .onChange(of: viewModel.loginViewModel.loginSuccessful) { oldValue, newValue in
                    // When loginSuccessful becomes false, dismiss this screen to go back to login
                    if !newValue && oldValue {
                        dismiss()
                    }
                }
                
                // Overlay for app info dialog - centered on entire screen
                if showAppInfo {
                    ZStack {
                        AppInfoView(showAppInfo: $showAppInfo)
                            .transition(.scale.combined(with: .opacity))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.3))
                    .ignoresSafeArea()
                }
            }
        }
        .sheet(isPresented: $showAccountScreen) {
            AccountScreen(loginViewModel: viewModel.loginViewModel, showAccountScreen: $showAccountScreen)
        }
    }
    
    @ViewBuilder
    var content: some View {
        ZStack(alignment: .center) {
            VStack(spacing: 0) {
                if viewModel.multitracks.isEmpty {
                    noMultitracksView
                } else {
                    playerView
                }
            }
            .sheet(isPresented: $showPicker) {
                DocumentPicker() { urls in
                    self.selectedAudioFilesUrls = urls
                    print("selectedAudioFilesUrls URLS: \(urls)")
                    
                    // With asCopy: false, URLs point to original files
                    // Extract original directory name from the first URL
                    var originalDirectoryName: String? = nil
                    if let firstUrl = urls.first {
                        // Start accessing the security-scoped resource
                        if firstUrl.startAccessingSecurityScopedResource() {
                            defer {
                                firstUrl.stopAccessingSecurityScopedResource()
                            }
                            
                            // Get the parent directory of the accessed resource
                            let parentUrl = firstUrl.deletingLastPathComponent()
                            originalDirectoryName = parentUrl.lastPathComponent
                            print("Original directory name: \(originalDirectoryName ?? "unknown")")
                            
                            // Optionally: Save bookmark data for later access
                            if let bookmarkData = try? parentUrl.bookmarkData(options: .suitableForBookmarkFile, 
                                                                              relativeTo: nil) {
                                print("Successfully obtained bookmark for original directory")
                                // Could store this in UserDefaults or elsewhere for persistent access
                            }
                        }
                    }
                    
                    // Get AI-suggested name for the multitrack
                    Task {
                        let suggested = await TrackNamingService.suggestMultitrackName(
                            from: urls,
                            originalDirectoryName: originalDirectoryName
                        )
                        DispatchQueue.main.async {
                            self.suggestedMultitrackName = suggested
                            self.showNewMultitrackNameInputDialog = true
                        }
                    }
                }
            }
            .confirmationDialog(String(localized: "confirm_delete"), isPresented: self.$presentModalDelete) {
                Button("delete \(viewModel.getSelectedMultitrackName())", role: .destructive) {
                    self.viewModel.deleteSelectedMultitrack()
                }
            }
            
            // Overlay for new multitrack dialog
            if showNewMultitrackNameInputDialog {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    NameInputDialogView(suggestedName: suggestedMultitrackName.isEmpty ? nil : suggestedMultitrackName) { newMultitrackName in
                        self.viewModel.createMultitrack(
                            withName: newMultitrackName,
                            using: self.selectedAudioFilesUrls
                        )
                        newMultitrackNameTmp = String.empty
                        selectedAudioFilesUrls = []
                        suggestedMultitrackName = ""
                        showNewMultitrackNameInputDialog = false
                    } onCancel: {
                        newMultitrackNameTmp = String.empty
                        selectedAudioFilesUrls = []
                        suggestedMultitrackName = ""
                        showNewMultitrackNameInputDialog = false
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            
            // Overlay for edit multitrack dialog
            if showEditMultitrackNameInputDialog {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    NameInputDialogView(name: viewModel.getSelectedMultitrackName()) { newMultitrackName in
                        viewModel.editMultitrackName(newMultitrackName)
                        showEditMultitrackNameInputDialog = false
                    } onCancel: {
                        showEditMultitrackNameInputDialog = false
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }
    
    var noMultitracksView: some View {
        VStack {
            Spacer()
            Text(String(localized: "add_multitrack"))
                .font(.largeTitle)
            Button(action: { self.showPicker = true }) {
                Image(systemName: "folder.badge.plus")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150, alignment: .center)
            }
            .padding(.leading)
            Spacer()
        }
    }
    
    var playerView: some View {
        VStack(alignment: .leading, spacing: 0) {
            controlButtons
                .frame(height: 40)
            Divider().padding(.top, 8)
            HStack(spacing: 16) {
                // MARK: Multitrack Picker
                if let selectedMultitrackIndex = viewModel.selectedMultitrackIndex {
                    HStack {
                        Text(String(localized: "current_multitrack"))
                        MultitrackPicker(
                            selectedMultitrackIndex: selectedMultitrackIndex,
                            multitracks: Array(viewModel.multitracks.values)) { selectedMultitrackIndex in
                                self.viewModel.selectMultitrack(selectedMultitrackIndex)
                            }
                    }
                }
                Spacer()
                if let _ = self.viewModel.selectedMultitrackIndex {
                    Button(action: {
                        showEditMultitrackNameInputDialog = true
                    }) {
                        Image(systemName: "pencil.line")
                            .resizable()
                            .scaledToFit()
                    }
                    Button(action: {
                        self.presentModalDelete.toggle()
                    }) {
                        Image(systemName: "trash")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Color("PSRed"))
                    }
                }
            }
            .frame(minHeight:30, maxHeight: 40)
            .padding(.vertical)
            Divider().padding(.bottom, 8)
            Spacer()
            SequenceControlsScreen(viewModel: viewModel)
        }
        .padding(.horizontal, 30)
    }
    
    @ViewBuilder
    var controlButtons: some View {
        HStack(spacing: 16) {
            Button(action: { self.viewModel.playTracks() }) {
                Image(systemName: "play.square")
                    .resizable()
                    .scaledToFit()
            }
            Button(action: { self.viewModel.stopTracks() }) {
                Image(systemName: "stop.circle")
                    .resizable()
                    .scaledToFit()
            }
            Spacer()
            // MARK: Add new multitrack button
            Button(action: { self.showPicker = true }) {
                Image(systemName: "folder.badge.plus")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30, alignment: .center)
            }
            .padding(.leading)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = DashboardViewModel(multitrackRepository: MultitrackLocalRepository(dataManager: .init()),
                                           loginViewModel: .init(authService: AuthenticationService()))
        let id1 = UUID()
        viewModel.multitracks[id1] = (
            .init(
                id: id1,
                name: "Rey de reyes",
                tracks: [.init(
                    id: id1,
                    name: "Click",
                    relativePath: String.empty,
                    config: .init(pan: 0, volume: 0.5, isMuted: false),
                    order: 0
                )]
            )
        )
        viewModel.appendTrackController(
            using: Track(
                id: UUID(),
                name: "Click",
                relativePath: String.empty,
                config: .init(pan: -1, volume: 0.5, isMuted: false),
                order: 0
            )
        )
        return DashboardScreen(viewModel: viewModel)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}

// MARK: - TrackNamingService
/// Extracts song names from directory paths using heuristic pattern matching
class TrackNamingService {
    
    static func suggestMultitrackName(from urls: [URL], originalDirectoryName: String? = nil) async -> String {
        guard !urls.isEmpty else { return "" }
        
        let fileUrl = urls.first!
        
        // Try parent directory first
        let parentDir = fileUrl.deletingLastPathComponent().lastPathComponent
        var result = extractSongName(from: parentDir)
        if !result.isEmpty { return result }
        
        // Try grandparent
        let grandparentDir = fileUrl.deletingLastPathComponent().deletingLastPathComponent().lastPathComponent
        result = extractSongName(from: grandparentDir)
        if !result.isEmpty { return result }
        
        // Try great-grandparent
        let greatGrandparentDir = fileUrl.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().lastPathComponent
        result = extractSongName(from: greatGrandparentDir)
        if !result.isEmpty { return result }
        
        return ""
    }
    
    /// Extract song name from directory path using pattern matching
    /// Examples:
    ///   - "ORIGINAL_Socorro_Un_Corazon_100bpm_4_4_D" → "Socorro Un Corazon"
    ///   - "Nada nos Detendrá-G#m-110bpm" → "Nada Nos Detendrá"
    ///   - "Multitracks Nada nos Detendrá-G#m-110bpm" → "Nada Nos Detendrá"
    ///   - "Tu Proveeras (feat. Christine DClario)-Gb-72.00bpm" → "Tu Proveeras (feat. Christine Dclario)"
    ///   - "Quien Dices Que Soy (Comp s 4-4) BPM 86 Tono Gb" → "Quien Dices Que Soy"
    static func extractSongName(from directoryName: String) -> String {
        guard !directoryName.isEmpty else { return "" }
        
        // Check if it's a generic directory name
        if isGenericDirectoryName(directoryName) {
            return ""
        }
        
        var text = directoryName
        
        // 1. Remove common prefixes
        text = text.replacingOccurrences(of: "^ORIGINAL_", with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: "^BACKUP_", with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: "^DEMO_", with: "", options: .regularExpression)
        
        // 1.5. Remove MultiTrack/Multitracks prefix at the beginning (with or without space)
        // Try plural first, then singular to avoid leaving "s" behind
        text = text.replacingOccurrences(of: "^(multitracks|multitrack)\\s*", with: "", options: [.regularExpression, .caseInsensitive])
        text = text.trimmingCharacters(in: .whitespaces)
        
        // 2. Remove MultiTrack/MT suffix at the end (before other processing)
        text = text.replacingOccurrences(of: "\\s*-?\\s*(multitrack|multitracks|MT)\\s*$", 
                                         with: "", options: [.regularExpression, .caseInsensitive])
        text = text.trimmingCharacters(in: .whitespaces)
        
        // 3. Remove BPM patterns (including decimals like 72.00bpm)
        // Patterns: "- 142bpm", "_100bpm", "-G#m-110bpm", " BPM 86", "-Gb-72.00bpm"
        text = text.replacingOccurrences(of: "\\s*-\\s*\\d+(?:\\.\\d+)?bpm.*$", with: "", options: [.regularExpression, .caseInsensitive])
        text = text.replacingOccurrences(of: "-[A-G](?:#|b)?m?-\\d+(?:\\.\\d+)?bpm.*$", with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: "_\\d+(?:\\.\\d+)?bpm.*$", with: "", options: [.regularExpression, .caseInsensitive])
        // "BPM 86" or "BPM 72.00" format
        text = text.replacingOccurrences(of: "\\s+BPM\\s+\\d+(?:\\.\\d+)?.*$", with: "", options: [.regularExpression, .caseInsensitive])
        // Also catch "-Gb-72.00bpm" or "-A-54" patterns
        text = text.replacingOccurrences(of: "-[A-G](?:#|b)?-\\d+(?:\\.\\d+)?.*$", with: "", options: .regularExpression)
        
        // 4. Remove tonality patterns: - G, - Bb, - G#m, Tono Gb
        // Must remove ALL tonality patterns, not just at end
        text = text.replacingOccurrences(of: "\\s*-\\s*[A-G](?:#|b)?m?\\s*(?=-|$|\\s)", with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: "\\s*-\\s*Tono\\s+[A-G](?:#|b)?.*$", with: "", options: [.regularExpression, .caseInsensitive])
        text = text.replacingOccurrences(of: "\\s*Tono\\s+[A-G](?:#|b)?.*$", with: "", options: [.regularExpression, .caseInsensitive])
        text = text.trimmingCharacters(in: .whitespaces)
        
        // 5. Remove composite patterns like "(Comp s 4-4)" or "Comp s 4-4"
        text = text.replacingOccurrences(of: "\\s*\\(Comp.*?\\).*$", with: "", options: [.regularExpression, .caseInsensitive])
        text = text.replacingOccurrences(of: "\\s+Comp\\s+.*?\\d-\\d.*$", with: "", options: [.regularExpression, .caseInsensitive])
        text = text.trimmingCharacters(in: .whitespaces)
        
        // 6. Remove known record labels/metadata keywords
        let labelsAndMetadata = ["418records", "418 records", "records", "recursos"]
        for label in labelsAndMetadata {
            text = text.replacingOccurrences(of: "\\s*-?\\s*" + NSRegularExpression.escapedPattern(for: label) + ".*$", 
                                            with: "", options: [.regularExpression, .caseInsensitive])
            text = text.trimmingCharacters(in: .whitespaces)
        }
        
        // 7. Clean up special characters
        text = text.replacingOccurrences(of: "^[¿!¡]+", with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: "[¿!¡]+$", with: "", options: .regularExpression)
        text = text.trimmingCharacters(in: .whitespaces)
        
        // 8. Replace separators with spaces (underscores, hyphens)
        text = text.replacingOccurrences(of: "_", with: " ")
        text = text.replacingOccurrences(of: "-", with: " ")
        text = text.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        text = text.trimmingCharacters(in: .whitespaces)
        
        // 9. Validate result
        if text.isEmpty {
            return ""
        }
        
        // 10. Format as title case
        return formatAsTitle(text)
    }
    
    private static func isGenericDirectoryName(_ name: String) -> Bool {
        let genericNames = [
            // Storage/System paths
            "MultiTracks", "Multitracks", "Tracks", "Audio", "Audios", "Music", "Media",
            "Downloads", "Documents", "Desktop", "Files", "Inbox", "Draft", "Trash",
            "Mobile", "Library", "Caches", "iCloud", "CloudDocs", "com~apple~CloudDocs",
            "var", "private", "tmp", "Containers", "Data", "Application",
            // Audio formats and technical folders
            "MP3", "MP4", "WAV", "FLAC", "AAC", "M4A", "OGG", "WMA", "AIFF",
            "Stems", "Instrumentals", "Vocals", "Drums", "Bass", "Guitar", "Keys", "Strings",
            // Common folder names
            "Samples", "Imported", "Exports", "Projects", "Sessions", "Recordings",
            "Backups", "Archives", "Temp", "Cache", "Logs",
            // iOS specific
            "Documents", "Library", "Application", "PluginKitPlugin", "Frameworks",
            "Resources", "Bundle"
        ]
        let lowerName = name.lowercased()
        return genericNames.contains { $0.lowercased() == lowerName }
    }
    
    private static func formatAsTitle(_ text: String) -> String {
        return text
            .split(separator: " ")
            .map { word in
                let lower = word.lowercased()
                return lower.prefix(1).uppercased() + lower.dropFirst()
            }
            .joined(separator: " ")
    }
}
