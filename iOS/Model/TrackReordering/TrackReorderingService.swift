import Foundation

/// Service for intelligent track reordering based on classification
class TrackReorderingService {
    
    /// Reorders tracks based on intelligent classification
    /// - Parameter tracks: Original tracks to reorder
    /// - Returns: Reordered tracks with assigned types
    static func reorderTracks(_ tracks: [Track]) -> [Track] {
        // Step 1: Classify each track
        let classifiedTracks = tracks.map { track -> (track: Track, type: TrackType) in
            let type: TrackType
            
            // Try classification by filename first (80%+ reliable)
            let fileNameClassification = TrackClassifier.classify(fileName: track.name)
            
            if fileNameClassification != .other {
                type = fileNameClassification
            } else {
                // Fallback: Try audio analysis
                if let audioUrl = track.url {
                    type = TrackClassifier.analyzeAudio(at: audioUrl)
                } else {
                    type = .other
                }
            }
            
            return (track, type)
        }
        
        // Step 2: Sort by priority (type's rawValue)
        let sortedTracks = classifiedTracks.sorted { lhs, rhs in
            // Primary sort: by track type priority
            let priorityComparison = lhs.type.rawValue - rhs.type.rawValue
            if priorityComparison != 0 {
                return priorityComparison < 0
            }
            
            // Secondary sort: maintain original order for same type
            return tracks.firstIndex(where: { $0.id == lhs.track.id }) ?? 0 <
                   tracks.firstIndex(where: { $0.id == rhs.track.id }) ?? 0
        }
        
        // Step 3: Update track order indices
        var reorderedTracks = sortedTracks.enumerated().map { index, pair -> Track in
            var updatedTrack = pair.track
            updatedTrack.order = Int32(index)
            // Optionally store the detected type for UI display
            return updatedTrack
        }
        
        return reorderedTracks
    }
    
    /// Classifies a single track and returns its type
    static func classifyTrack(_ track: Track) -> TrackType {
        let fileNameClassification = TrackClassifier.classify(fileName: track.name)
        if fileNameClassification != .other {
            return fileNameClassification
        }
        
        if let audioUrl = track.url {
            return TrackClassifier.analyzeAudio(at: audioUrl)
        }
        
        return .other
    }
}
