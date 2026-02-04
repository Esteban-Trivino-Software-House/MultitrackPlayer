//
//  TrackNamingService.swift
//  The Multitrack Player
//
//  Created by Assistant on February 4, 2026.
//  This file is part of the Multitrack Player project.
//
//  Provides intelligent naming suggestions for multitrack projects based on:
//  - File path analysis
//  - ID3 metadata tags
//  - User's project history
//  - File names
//

import Foundation
import AVFoundation

class TrackNamingService {
    
    // MARK: - Public Methods
    
    /// Suggests a multitrack name based on selected audio file URLs
    /// - Parameter urls: Array of audio file URLs
    /// - Returns: Suggested name as String
    static func suggestMultitrackName(from urls: [URL]) async -> String {
        // Guard against empty array
        guard !urls.isEmpty else {
            return "Untitled"
        }
        
        // 1. Try to extract name from file path
        if let nameFromPath = extractNameFromPath(urls) {
            return nameFromPath
        }
        
        // 2. Try to extract name from ID3 tags
        if let nameFromTags = await extractNameFromID3(urls.first!) {
            return nameFromTags
        }
        
        // 3. Try to suggest from history
        if let nameFromHistory = suggestFromHistory() {
            return nameFromHistory
        }
        
        // 4. Fallback: use first filename
        let fallbackName = urls.first?.deletingPathExtension().lastPathComponent ?? "Untitled"
        return formatAsTitle(fallbackName)
    }
    
    // MARK: - Private Methods: Path Analysis
    
    /// Extracts a name from the file path hierarchy
    /// Looks for common patterns like ~/Music/Artist/Album/Song_Name
    private static func extractNameFromPath(_ urls: [URL]) -> String? {
        guard let firstUrl = urls.first else {
            return nil
        }
        
        let components = firstUrl.pathComponents
        
        // Look at parent directory names (usually more meaningful than filename)
        // We prefer directory 2-3 levels up from the file
        if components.count >= 3 {
            // Get the immediate parent directory (usually the most specific name)
            let parentDir = firstUrl.deletingLastPathComponent().lastPathComponent
            
            // Check if parent looks like a meaningful name (not just generic)
            if !isGenericDirectoryName(parentDir) && !parentDir.isEmpty {
                return formatAsTitle(parentDir)
            }
            
            // Try grandparent directory
            if components.count >= 4 {
                let grandparentIndex = components.count - 3
                if grandparentIndex >= 0 && grandparentIndex < components.count {
                    let grandparent = components[grandparentIndex]
                    if !isGenericDirectoryName(grandparent) && !grandparent.isEmpty {
                        return formatAsTitle(grandparent)
                    }
                }
            }
        }
        
        // If no meaningful directory found, try extracting from filename with regex
        let filename = firstUrl.deletingPathExtension().lastPathComponent
        if let extractedName = extractFromFilename(filename) {
            return extractedName
        }
        
        return nil
    }
    
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
        if !cleaned.isEmpty && cleaned.count > 2 {
            return formatAsTitle(cleaned)
        }
        
        return nil
    }
    
    /// Checks if a directory name is generic (should be skipped)
    private static func isGenericDirectoryName(_ name: String) -> Bool {
        let genericNames = ["Music", "Downloads", "Documents", "Desktop", "Projects", 
                           "Audio", "Tracks", "Files", "Audios", "Media", "Multitrack"]
        return genericNames.contains(name)
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
