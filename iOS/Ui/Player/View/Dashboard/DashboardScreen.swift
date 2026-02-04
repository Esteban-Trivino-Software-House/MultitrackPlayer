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
/// Provides intelligent naming suggestions for multitrack projects based on:
/// - File path analysis
/// - ID3 metadata tags
/// - User's project history
/// - File names
class TrackNamingService {
    
    // MARK: - Public Methods
    
    /// Suggests a multitrack name based on selected audio file URLs
    /// - Parameter urls: Array of audio file URLs from file manager
    /// - Parameter originalDirectoryName: The parent directory name from security-scoped resource access
    /// - Returns: Suggested name as String
    static func suggestMultitrackName(from urls: [URL], originalDirectoryName: String? = nil) async -> String {
        // Guard against empty array
        guard !urls.isEmpty else {
            return "Untitled"
        }
        
        // 1. If we have the original directory name from security-scoped access, use it
        if let dirName = originalDirectoryName,
           !isGenericDirectoryName(dirName) && 
           !isBundleIdentifier(dirName) && 
           !isSystemPath(dirName) {
            if let extracted = cleanDirectoryName(dirName) {
                return extracted
            }
        }
        
        // 2. Try to extract name from the directory structure of the URLs
        if let nameFromPath = extractNameFromDirectoryPath(urls) {
            return nameFromPath
        }
        
        // 3. Try to extract name from ID3 tags
        if let nameFromTags = await extractNameFromID3(urls.first!) {
            return nameFromTags
        }
        
        // 4. Try to suggest from history
        if let nameFromHistory = suggestFromHistory() {
            return nameFromHistory
        }
        
        // 5. Fallback: use first filename
        let fallbackName = urls.first?.deletingPathExtension().lastPathComponent ?? "Untitled"
        return formatAsTitle(fallbackName)
    }
    
    // MARK: - Private Methods: Directory Path Analysis
    
    /// Extracts project name from the directory structure of original URLs
    /// URLs from file manager contain the original folder hierarchy before sandbox copy
    /// Examples:
    ///   - /Users/user/Music/Rey de reyes/click.mp3 → "Rey de reyes"
    ///   - /Users/user/Music/ORIGINAL_Socorro_100bpm/drums.mp3 → "Socorro"
    ///   - /Volumes/ExternalDrive/Projects/MySong/bass.mp3 → "MySong"
    private static func extractNameFromDirectoryPath(_ urls: [URL]) -> String? {
        guard let firstUrl = urls.first else {
            return nil
        }
        
        // The directory containing the audio files (parent of the audio file)
        let parentDir = firstUrl.deletingLastPathComponent().lastPathComponent
        
        // Validate and extract name from parent directory
        if !isGenericDirectoryName(parentDir) && 
           !isBundleIdentifier(parentDir) && 
           !isSystemPath(parentDir) {
            if let extracted = cleanDirectoryName(parentDir) {
                return extracted
            }
        }
        
        // If parent didn't work, try grandparent directory (less specific)
        let grandparentPath = firstUrl.deletingLastPathComponent().deletingLastPathComponent()
        let grandparentDir = grandparentPath.lastPathComponent
        
        if parentDir != grandparentDir &&
           !isGenericDirectoryName(grandparentDir) && 
           !isBundleIdentifier(grandparentDir) && 
           !isSystemPath(grandparentDir) {
            if let extracted = cleanDirectoryName(grandparentDir) {
                return extracted
            }
        }
        
        return nil
    }
    
    /// Cleans and validates a directory name to extract a meaningful project name
    /// Removes common patterns and validates the result
    /// Examples:
    ///   - "Rey de reyes multitrack" → "Rey de reyes"
    ///   - "ORIGINAL_Socorro_Un_Corazon_100bpm" → "Socorro Un Corazon"
    ///   - "Song_Name_remix" → "Song Name"
    private static func cleanDirectoryName(_ dirName: String) -> String? {
        var cleaned = dirName
        
        // Remove common prefixes
        let prefixes = ["ORIGINAL_", "BACKUP_", "TEMP_", "NEW_", "FINAL_", "v1_", "v2_", "v3_"]
        for prefix in prefixes {
            if cleaned.uppercased().hasPrefix(prefix.uppercased()) {
                cleaned = String(cleaned.dropFirst(prefix.count))
                break
            }
        }
        
        // Remove "multitrack" suffix
        cleaned = cleaned.replacingOccurrences(
            of: #"\s*multitrack\s*$"#,
            with: "",
            options: [.regularExpression, .caseInsensitive]
        )
        
        // Remove BPM patterns like "_100bpm", " 120 BPM"
        cleaned = cleaned.replacingOccurrences(
            of: #"[\s_-]*\d{2,3}\s*bpm\s*$"#,
            with: "",
            options: [.regularExpression, .caseInsensitive]
        )
        
        // Remove common suffixes
        let suffixes = ["remix", "edit", "version", "take", "draft", "mix"]
        for suffix in suffixes {
            cleaned = cleaned.replacingOccurrences(
                of: #"[\s_-]*" + suffix + #"\s*$"#,
                with: "",
                options: [.regularExpression, .caseInsensitive]
            )
        }
        
        // Convert underscores and hyphens to spaces
        cleaned = cleaned
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
        
        // Validate result
        if cleaned.isEmpty || 
           cleaned.count < 2 || 
           isNumericOnly(cleaned) || 
           isGenericDirectoryName(cleaned) ||
           isBundleIdentifier(cleaned) ||
           isSystemPath(cleaned) {
            return nil
        }
        
        return formatAsTitle(cleaned)
    }
    
    // MARK: - Private Methods: Audio Filename Analysis (Deprecated)
    
    // MARK: - Private Methods: Path Analysis
    /// Extracts a clean name from filename using common patterns
    /// Examples:
    ///   "Song_Name_-_Key_Of_Song" → "Song Name Key Of Song"
    ///   "Artist-Album-Track" → "Artist Album Track"
    ///   "track_01_drums" → "Track 01 Drums"
    private static func extractFromFilename(_ filename: String) -> String? {
        let cleaned = filename
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespaces)
        
        // If the result looks meaningful (not too short, not all numbers)
        if !cleaned.isEmpty && cleaned.count > 2 && !isNumericOnly(cleaned) {
            return formatAsTitle(cleaned)
        }
        
        return nil
    }
    
    /// Checks if a directory name is generic (should be skipped)
    private static func isGenericDirectoryName(_ name: String) -> Bool {
        let genericNames = ["Music", "Downloads", "Documents", "Desktop", "Projects", 
                           "Audio", "Tracks", "Files", "Audios", "Media", "Multitrack", "Multitracks",
                           "Inbox", "Sent", "Draft", "Trash", "iCloud", "Library",
                           "Applications", "System", "Users", "var", "tmp", "private",
                           "Shared", "Public", "Pictures", "Movies", "Videos"]
        return genericNames.contains(name)
    }
    
    /// Checks if a string looks like a Bundle Identifier or App-related path
    /// Examples: "com.example.app", "Com.estebantrivino.multitrack", "com.apple.safari"
    private static func isBundleIdentifier(_ name: String) -> Bool {
        let lowerName = name.lowercased()
        
        // Pattern 1: Standard bundle ID format (com.something.something)
        let bundleIdPattern = #"^[a-z]+(\.[a-z0-9]+)+$"#
        do {
            let regex = try NSRegularExpression(pattern: bundleIdPattern, options: [])
            let range = NSRange(name.startIndex..., in: name)
            if regex.firstMatch(in: lowerName, options: [], range: range) != nil {
                return true
            }
        } catch {
            // Ignore regex errors
        }
        
        // Pattern 2: Apple-like identifiers with spaces (Com.example.app Bundle, Com.estebantrivino.multitrack Player)
        if lowerName.contains(".") && (lowerName.hasPrefix("com.") || lowerName.hasPrefix("com ") || lowerName.contains("player")) {
            return true
        }
        
        // Pattern 3: Mixed case com.* format (Com.estebantrivino...)
        if name.hasPrefix("Com.") || name.hasPrefix("com.") {
            return true
        }
        
        return false
    }
    
    /// Checks if a path segment looks like a system path
    /// Examples: "Containers", "Data", "Application", "PluginKitPlugin"
    private static func isSystemPath(_ name: String) -> Bool {
        let systemPathNames = [
            "Containers", "Data", "Application", "PluginKitPlugin",
            "Documents", "Library", "Caches", "Preferences",
            "Bundle", "Frameworks", "PlugIns", "Resources",
            "Plugins", "Extensions", "Watch", "iCloud"
        ]
        return systemPathNames.contains(name)
    }
    
    /// Checks if a string contains only numbers and spaces
    private static func isNumericOnly(_ text: String) -> Bool {
        let cleaned = text.trimmingCharacters(in: .whitespaces)
        return !cleaned.isEmpty && cleaned.allSatisfy { $0.isNumber || $0.isWhitespace }
    }
    
    // MARK: - Private Methods: ID3 Tag Analysis
    
    /// Extracts name from ID3 tags using AVAsset metadata
    /// Prefers: Title - Artist format
    private static func extractNameFromID3(_ url: URL) async -> String? {
        do {
            let asset = AVAsset(url: url)
            
            // Load metadata asynchronously
            let metadata = try await asset.load(.metadata)
            
            var title: String?
            var artist: String?
            var albumName: String?
            
            // Extract common metadata fields
            for item in metadata {
                if let identifier = item.identifier?.rawValue {
                    if identifier == AVMetadataIdentifier.commonIdentifierTitle.rawValue {
                        title = (try? await item.load(.stringValue)) ?? nil
                    } else if identifier == AVMetadataIdentifier.commonIdentifierArtist.rawValue {
                        artist = (try? await item.load(.stringValue)) ?? nil
                    } else if identifier == AVMetadataIdentifier.commonIdentifierAlbumName.rawValue {
                        albumName = (try? await item.load(.stringValue)) ?? nil
                    }
                }
            }
            
            // Format the result
            if let title = title, !title.isEmpty {
                if let artist = artist, !artist.isEmpty {
                    return "\(artist) - \(title)"
                }
                return formatAsTitle(title)
            }
            
            if let albumName = albumName, !albumName.isEmpty {
                return formatAsTitle(albumName)
            }
            
            return nil
        } catch {
            // If metadata extraction fails, return nil and fall back to other methods
            return nil
        }
    }
    
    // MARK: - Private Methods: History Analysis
    
    /// Suggests a name based on user's project history
    /// Examples:
    ///   If user has "Jazz Session 1" and "Jazz Session 2" → suggests "Jazz Session 3"
    private static func suggestFromHistory() -> String? {
        // This method requires access to existing multitracks
        // For now, we'll leave it for future implementation when we can access DashboardViewModel
        // TODO: Implement in Phase 2 with access to existing multitracks
        return nil
    }
    
    // MARK: - Private Methods: Formatting
    
    /// Formats a string as a proper title
    /// Examples:
    ///   "song name" → "Song Name"
    ///   "SONG NAME" → "Song Name"
    ///   "song-name" → "Song Name"
    private static func formatAsTitle(_ text: String) -> String {
        let cleaned = text
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespaces)
        
        // Split into words and capitalize each one
        let words = cleaned.split(separator: " ").map { word -> String in
            let lower = String(word).lowercased()
            
            // Skip common small words (articles, prepositions)
            let skipWords = ["a", "an", "the", "and", "or", "but", "in", "on", "at", "to", "for"]
            if skipWords.contains(lower) && !cleaned.hasPrefix(lower) {
                return lower
            }
            
            // Capitalize first letter
            return String(word).prefix(1).uppercased() + String(word).dropFirst().lowercased()
        }
        
        var result = words.joined(separator: " ")
        
        // Ensure first character is always uppercase
        if !result.isEmpty {
            result = String(result.prefix(1)).uppercased() + String(result.dropFirst())
        }
        
        return result.isEmpty ? "Untitled" : result
    }
}
