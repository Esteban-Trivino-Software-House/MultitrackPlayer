//
//  PanSelector.swift
//  Play Secuence (iOS)
//
//  Created by Esteban Rafael Trivino Guerra on 9/09/22.
//

import SwiftUI

struct PanSelector: View {
    @Binding var selectedPan: TrackControlViewModel.PanOptions
        var body: some View {
            VStack {
                Picker(String(localized: "pan_options"), selection: $selectedPan) {
                    Text(String(localized: "left")).tag(TrackControlViewModel.PanOptions.left)
                    Text(String(localized: "center")).tag(TrackControlViewModel.PanOptions.center)
                    Text(String(localized: "right")).tag(TrackControlViewModel.PanOptions.right)
                }
                .pickerStyle(.menu )
            }
        }
}

struct PanSelector_Previews: PreviewProvider {
    static var previews: some View {
        PanSelector(selectedPan: .constant(TrackControlViewModel.PanOptions.center))
    }
}
