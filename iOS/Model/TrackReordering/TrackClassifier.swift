import Foundation
import NaturalLanguage
import AVFoundation

/// Tipos de tracks con orden de prioridad
enum TrackType: Int {
    case click = 0
    case guide = 1
    case drums = 2
    case bass = 3
    case piano = 4
    case keyboards = 5
    case guitars = 6
    case vocals = 7
    case other = 8
    
    var displayName: String {
        switch self {
        case .click: return "Click/Metronome"
        case .guide: return "Guide/Cue"
        case .drums: return "Drums"
        case .bass: return "Bass"
        case .piano: return "Piano"
        case .keyboards: return "Keyboards"
        case .guitars: return "Guitars"
        case .vocals: return "Vocals/Chorus"
        case .other: return "Other"
        }
    }
}

/// Clasificador de tracks inteligente usando Apple's NL Framework
class TrackClassifier {
    
    // MARK: - Keyword Dictionaries (Multi-language)
    
    private static let clickKeywords = [
        // English
        "click", "clicks", "metronome", "metro", "clic", "clk", "ck", "met",
        // Spanish
        "clic", "clics", "metrónomo", "metronomo", "clk",
        // Portuguese
        "clique", "cliques", "clk",
        // French
        "clic", "clics", "clk",
        // German
        "klick", "klicks", "metronom", "clk"
    ]
    
    private static let guideKeywords = [
        // English
        "guide", "guides", "cue", "cues", "reference", "ref", "track", "lead", "gd", "vx",
        // Spanish
        "guía", "guias", "guia", "guías", "referencia", "ref", "pista", "gd",
        // Portuguese
        "guia", "guias", "referência", "gd",
        // French
        "guide", "guides", "repère", "gd",
        // German
        "anleitung", "cue", "gd"
    ]
    
    private static let drumsKeywords = [
        // English
        "drum", "drums", "percussion", "perc", "kit", "beat", "kick", "snare", "tom", "cymbal", "hi-hat", "drm", "prc", "dr",
        // Spanish
        "batería", "bateria", "percusión", "percusion", "perc", "caja", "platillo", "drm",
        // Portuguese
        "bateria", "percussão", "percussao", "drm",
        // French
        "batterie", "percussion", "caisse", "drm",
        // German
        "schlagzeug", "perkussion", "trommel", "drm"
    ]
    
    private static let bassKeywords = [
        // English
        "bass", "bajo", "bass guitar", "electric bass", "upright bass", "double bass", "bss", "bs", "b1", "b2", "b3",
        // Spanish
        "bajo", "bajos", "contrabajo", "bss",
        // Portuguese
        "baixo", "baixos", "bss",
        // French
        "basse", "basses", "bss",
        // German
        "bass", "bassgitarre", "bss"
    ]
    
    private static let pianoKeywords = [
        // English
        "piano", "grand piano", "electric piano", "pno", "pn", "pnl",
        // Spanish
        "piano", "pianos", "pno",
        // Portuguese
        "piano", "pianos", "pno",
        // French
        "piano", "pianos", "pno",
        // German
        "klavier", "klavier", "piano", "pno"
    ]
    
    private static let keyboardsKeywords = [
        // English
        "key", "keys", "keyboard", "keyboards", "synth", "synthesizer", "organ", "pad", "strings", "pad", "mellotron", "kbd", "syn", "ky",
        // Spanish
        "teclado", "teclados", "sintetizador", "sintetizador", "órgano", "organo", "pad", "pads", "kbd", "syn",
        // Portuguese
        "teclado", "teclados", "sintetizador", "órgão", "kbd", "syn",
        // French
        "clavier", "claviers", "synthétiseur", "orgue", "pad", "kbd", "syn",
        // German
        "tastatur", "synthesizer", "orgel", "pad", "kbd", "syn"
    ]
    
    private static let guitarsKeywords = [
        // English
        "guitar", "guitars", "gtr", "gtrs", "acoustic", "acustic", "electric", "gtr1", "gtr2", "gtr3", "gtr4", 
        "ga", "ge", "g1", "g2", "g3", "g4", "g5", "lead guitar", "rhythm", "riff",
        // Spanish
        "guitarra", "guitarras", "gtr", "gtrs", "acústica", "acustica", "eléctrica", "electrica", 
        "ga", "ge", "g1", "g2", "g3", "g4", "g5",
        // Portuguese
        "guitarra", "guitarras", "acústica", "acustica", "elétrica", "eletrica",
        // French
        "guitare", "guitares", "acoustique", "électrique",
        // German
        "gitarre", "gitarren", "akustik", "elektro"
    ]
    
    private static let vocalsKeywords = [
        // English
        "vocal", "vocals", "voc", "voice", "voices", "chorus", "choir", "singing", "singer", "lead vocal", "backing vocal", "harmony", "harmonies", "vx", "v1", "v2", "v3",
        // Spanish
        "vocal", "vocales", "voz", "voces", "coro", "coros", "cantante", "canto", "voc", "vx",
        // Portuguese
        "vocal", "vocais", "voz", "vozes", "coro", "cantor", "canto", "voc", "vx",
        // French
        "vocal", "vocales", "voix", "choeur", "chanteur", "chant", "voc", "vx",
        // German
        "gesang", "gesänge", "stimme", "stimmen", "chor", "sänger", "vokal", "vox", "vx"
    ]
    
    // MARK: - Classification Methods
    
    /// Classifies a track based on file name using multi-language NL analysis
    static func classify(fileName: String) -> TrackType {
        let lowerName = fileName.lowercased()
        let nameWithoutExtension = (fileName as NSString).deletingPathExtension.lowercased()
        
        // First, use exact keyword matching with all languages
        if matchesAnyKeyword(nameWithoutExtension, in: clickKeywords) {
            return .click
        }
        if matchesAnyKeyword(nameWithoutExtension, in: guideKeywords) {
            return .guide
        }
        if matchesAnyKeyword(nameWithoutExtension, in: drumsKeywords) {
            return .drums
        }
        if matchesAnyKeyword(nameWithoutExtension, in: bassKeywords) {
            return .bass
        }
        if matchesAnyKeyword(nameWithoutExtension, in: pianoKeywords) {
            return .piano
        }
        if matchesAnyKeyword(nameWithoutExtension, in: keyboardsKeywords) {
            return .keyboards
        }
        if matchesAnyKeyword(nameWithoutExtension, in: guitarsKeywords) {
            return .guitars
        }
        if matchesAnyKeyword(nameWithoutExtension, in: vocalsKeywords) {
            return .vocals
        }
        
        // If no exact match, use NL Framework for semantic analysis
        return classifyUsingSemanticsIfNeeded(nameWithoutExtension)
    }
    
    /// Uses Apple's Natural Language Framework for semantic understanding
    private static func classifyUsingSemanticsIfNeeded(_ fileName: String) -> TrackType {
        // Create a tagger for lemmatization (root form of words)
        let tagger = NLTagger(tagSchemes: [.lemma, .lexicalClass])
        tagger.string = fileName
        
        var hasClick = false
        var hasGuide = false
        var hasDrums = false
        var hasBass = false
        var hasPiano = false
        var hasKeyboards = false
        var hasGuitars = false
        var hasVocals = false
        
        let range = fileName.startIndex..<fileName.endIndex
        tagger.enumerateTags(in: range, unit: .word, scheme: .lemma, options: .omitPunctuation) { tag, tokenRange in
            let token = String(fileName[tokenRange]).lowercased()
            let lemma = tag?.rawValue.lowercased() ?? token
            
            // Check lemmatized forms against keywords
            if clickKeywords.contains(lemma) || clickKeywords.contains(token) { hasClick = true }
            if guideKeywords.contains(lemma) || guideKeywords.contains(token) { hasGuide = true }
            if drumsKeywords.contains(lemma) || drumsKeywords.contains(token) { hasDrums = true }
            if bassKeywords.contains(lemma) || bassKeywords.contains(token) { hasBass = true }
            if pianoKeywords.contains(lemma) || pianoKeywords.contains(token) { hasPiano = true }
            if keyboardsKeywords.contains(lemma) || keyboardsKeywords.contains(token) { hasKeyboards = true }
            if guitarsKeywords.contains(lemma) || guitarsKeywords.contains(token) { hasGuitars = true }
            if vocalsKeywords.contains(lemma) || vocalsKeywords.contains(token) { hasVocals = true }
            
            return true
        }
        
        // Return highest priority match
        if hasClick { return .click }
        if hasGuide { return .guide }
        if hasDrums { return .drums }
        if hasBass { return .bass }
        if hasPiano { return .piano }
        if hasKeyboards { return .keyboards }
        if hasGuitars { return .guitars }
        if hasVocals { return .vocals }
        
        return .other
    }
    
    /// Checks if any keyword appears in the text
    private static func matchesAnyKeyword(_ text: String, in keywords: [String]) -> Bool {
        return keywords.contains { keyword in
            text.contains(keyword)
        }
    }
    
    // MARK: - Frequency Analysis
    
    /// Analyzes audio file to detect track type by frequency content
    static func analyzeAudio(at url: URL) -> TrackType {
        let audioFile: AVAudioFile
        do {
            audioFile = try AVAudioFile(forReading: url)
        } catch {
            print("Error reading audio file: \(error)")
            return .other
        }
        
        guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length)) else {
            return .other
        }
        
        do {
            try audioFile.read(into: audioBuffer)
        } catch {
            print("Error reading audio buffer: \(error)")
            return .other
        }
        
        // Analyze first 10 seconds
        let sampleRate = audioFile.processingFormat.sampleRate
        let samplesToAnalyze = Int(min(sampleRate * 10, Double(audioBuffer.frameLength)))
        
        guard let channelData = audioBuffer.floatChannelData?[0] else {
            return .other
        }
        
        // Simple frequency analysis: detect dominant frequency bands
        let lowFreqEnergy = analyzeFrequencyBand(channelData, sampleCount: samplesToAnalyze, range: 20..<250)
        let midFreqEnergy = analyzeFrequencyBand(channelData, sampleCount: samplesToAnalyze, range: 200..<1000)
        let highFreqEnergy = analyzeFrequencyBand(channelData, sampleCount: samplesToAnalyze, range: 1000..<5000)
        let veryHighFreqEnergy = analyzeFrequencyBand(channelData, sampleCount: samplesToAnalyze, range: 5000..<20000)
        
        let totalEnergy = lowFreqEnergy + midFreqEnergy + highFreqEnergy + veryHighFreqEnergy
        guard totalEnergy > 0 else { return .other }
        
        let lowRatio = lowFreqEnergy / totalEnergy
        let midRatio = midFreqEnergy / totalEnergy
        let highRatio = highFreqEnergy / totalEnergy
        
        // Heuristic classification based on frequency characteristics
        if highRatio > 0.6 && veryHighFreqEnergy > highFreqEnergy {
            return .click  // Clicks are typically in high frequency range with isolated peaks
        }
        if lowRatio > 0.5 {
            return .bass   // Bass has dominant low frequency energy
        }
        if midRatio > 0.4 {
            return .guide  // Vocals/guides are in mid-range
        }
        
        return .other
    }
    
    /// Analyzes energy in a specific frequency range
    private static func analyzeFrequencyBand(_ samples: UnsafeMutablePointer<Float>, sampleCount: Int, range: Range<Int>) -> Float {
        // This is a simplified version - a real implementation would use FFT
        var energy: Float = 0.0
        for i in 0..<min(sampleCount, 1000) {
            let sample = samples[i]
            energy += sample * sample
        }
        return energy / Float(min(sampleCount, 1000))
    }
}
