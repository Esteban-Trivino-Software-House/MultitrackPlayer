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
                Picker("What is your favorite color?", selection: $selectedPan) {
                    Text("Left").tag(TrackControlViewModel.PanOptions.left)
                    Text("Center").tag(TrackControlViewModel.PanOptions.center)
                    Text("Right").tag(TrackControlViewModel.PanOptions.right)
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
