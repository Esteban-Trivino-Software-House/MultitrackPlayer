//
//  PitchSelector.swift
//  Play Secuence (iOS)
//
//  Created by Esteban Rafael Trivino Guerra on 6/02/26.
//  Pitch control component with semitone adjustment
//

import SwiftUI

struct PitchSelector: View {
    @Binding var pitch: Float
    
    var pitchLabel: String {
        let semitones = Int(pitch)
        if semitones == 0 {
            return "0 st"
        } else if semitones > 0 {
            return "+\(semitones) st"
        } else {
            return "\(semitones) st"
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(String(localized: "pitch"))
                .font(.system(size: 11))
                .foregroundColor(.gray)
            
            HStack(spacing: 8) {
                Text("♭")
                    .font(.system(size: 14))
                
                Slider(value: $pitch, in: -12...12, step: 1)
                    .frame(maxWidth: .infinity)
                
                Text("♯")
                    .font(.system(size: 14))
            }
            
            Text(pitchLabel)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.blue)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}

struct PitchSelector_Previews: PreviewProvider {
    static var previews: some View {
        PitchSelector(pitch: .constant(0))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
