//
//  SequenceControlsScreen.swift
//  Play Secuence (iOS)
//
//  Created by Esteban Rafael Trivino Guerra on 8/09/22.
//

import SwiftUI

struct SequenceControlsScreen: View {
    @ObservedObject var viewModel: DashboardViewModel
    @State private var draggingId: UUID?
    @State private var draggedOverIndex: Int?
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(Array(viewModel.trackControllers.enumerated()), id: \.element.id) { index, controller in
                    TrackItemView(
                        controller: controller,
                        index: index,
                        draggingId: $draggingId,
                        draggedOverIndex: $draggedOverIndex,
                        viewModel: viewModel,
                        onDrop: { sourceIndex in
                            if sourceIndex != index {
                                let destination = index > sourceIndex ? index + 1 : index
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    viewModel.moveTrack(from: IndexSet(integer: sourceIndex), to: destination)
                                }
                            }
                            draggingId = nil
                            draggedOverIndex = nil
                        }
                    )
                    
                    Spacer()
                }
            }
            .frame(minHeight: 100, maxHeight: .infinity)
        }
    }
}

struct TrackItemView: View {
    let controller: TrackControlViewModel
    let index: Int
    @Binding var draggingId: UUID?
    @Binding var draggedOverIndex: Int?
    let viewModel: DashboardViewModel
    let onDrop: (Int) -> Void
    @State private var isTargeted = false
    
    var isDragging: Bool {
        draggingId == controller.id
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            // Highlight cuando es un target válido
            if isTargeted && !isDragging {
                VStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.green)
                        .frame(width: 4)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.green.opacity(0.15))
            }
            
            VStack(spacing: 0) {
                // Drag Handle - zona donde se puede arrastrar
                VStack(spacing: 3) {
                    ForEach(0..<3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 28, height: 2.5)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .contentShape(Rectangle())
                .onDrag {
                    draggingId = controller.id
                    draggedOverIndex = nil
                    return NSItemProvider(object: controller.id.uuidString as NSString)
                } preview: {
                    TrackControl(viewModel: controller)
                }
                
                // Track Control - no se puede arrastrar desde aquí
                TrackControl(viewModel: controller)
            }
        }
        .frame(maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.2), value: draggedOverIndex)
        .dropDestination(for: String.self) { items, location in
            guard let droppedId = items.first,
                  let droppedUUID = UUID(uuidString: droppedId),
                  let sourceIndex = viewModel.trackControllers.firstIndex(where: { $0.id == droppedUUID }) else {
                isTargeted = false
                return false
            }
            
            onDrop(sourceIndex)
            isTargeted = false
            return true
        } isTargeted: { targeted in
            isTargeted = targeted && !isDragging
            if targeted && !isDragging {
                draggedOverIndex = index
            }
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
