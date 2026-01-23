//
//  SequenceControlsScreen.swift
//  Play Secuence (iOS)
//
//  Created by Esteban Rafael Trivino Guerra on 8/09/22.
//

import SwiftUI

struct SequenceControlsScreen: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(viewModel.trackControllers) { controller in
                    TrackControl(viewModel: controller)
                        .draggable(controller.id.uuidString)
                        .dropDestination(for: String.self) { items, location in
                            guard let droppedId = items.first,
                                  let droppedUUID = UUID(uuidString: droppedId),
                                  let sourceIndex = viewModel.trackControllers.firstIndex(where: { $0.id == droppedUUID }),
                                  let destinationIndex = viewModel.trackControllers.firstIndex(where: { $0.id == controller.id }) else {
                                return false
                            }
                            
                            if sourceIndex != destinationIndex {
                                viewModel.moveTrack(from: IndexSet(integer: sourceIndex), to: destinationIndex > sourceIndex ? destinationIndex + 1 : destinationIndex)
                            }
                            return true
                        }
                    Spacer()
                }
            }
            .frame(minHeight: 50, maxHeight: 200)
        }
    }
}

struct Faders_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = DashboardViewModel(multitrackRepository: MultitrackLocalRepository(dataManager: .init()),
                                           loginViewModel: LoginViewModel(authService: AuthenticationService()))
    viewModel.appendTrackController(using: Track(id: UUID(), name: "Click", relativePath: String.empty, config: .init(pan: 0, volume: 0.5, isMuted: false), order: 0))
    viewModel.appendTrackController(using: Track(id: UUID(), name: "Sequence", relativePath: String.empty, config: .init(pan: 0, volume: 0.5, isMuted: false), order: 1))
    viewModel.appendTrackController(using: Track(id: UUID(), name: "Keys", relativePath: String.empty, config: .init(pan: 0, volume: 0.5, isMuted: false), order: 2))
        return SequenceControlsScreen(viewModel: viewModel)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
