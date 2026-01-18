//
//  Fader.swift
//  Play Secuence (iOS)
//
//  Created by Esteban Rafael Trivino Guerra on 8/09/22.
//

import SwiftUI

struct TrackControl: View {
    @ObservedObject var viewModel: TrackControlViewModel
    
    var body: some View {
        VStack(spacing: 0.0) {
            PanSelector(selectedPan: $viewModel.trackPan)
            Button(action: {
                self.viewModel.toogleMute()
            }, label: {
                Image(systemName: viewModel.mute ? "speaker.slash.fill" : "speaker.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
            })
            .padding([.top, .bottom], 5)
            Text(String(format: "%.0f", viewModel.trackVolume))
                .font(.system(size:12))
            GeometryReader { geo in
                HStack() {
                    Slider(value: $viewModel.trackVolume, in: 0...100)
                        .rotationEffect(.degrees(-90.0), anchor: .topLeading)
                        .frame(width: geo.size.height)
                        .offset(y: geo.size.height)
                }
            }
            .frame(width: 30)
            Text(viewModel.trackName)
                .font(.system(size:12))
        }
        .frame(minWidth: 50)
    }
}

struct Fader_Previews: PreviewProvider {
    static var previews: some View {
    TrackControl(viewModel: TrackControlViewModel(track: Track(id: UUID(), name: "Click", relativePath: String.empty, config: .init(pan: 0, volume: 0.5, isMuted: false))))
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
