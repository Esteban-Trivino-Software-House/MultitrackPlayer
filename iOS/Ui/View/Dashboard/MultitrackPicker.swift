//
//  MultitrackPicker.swift
//  Play Secuence
//
//  Created by Esteban Triviño on 21/08/25.
//

import SwiftUI

struct MultitrackPicker: View {
    @State private var selectedMultitrackIndex: UUID
    var multitracks: [Multitrack]
    var onChange: (UUID) -> Void
    
    init(selectedMultitrackIndex: UUID,
         multitracks: [Multitrack],
         onChange: @escaping (UUID) -> Void
    ) {
        self.selectedMultitrackIndex = selectedMultitrackIndex
        self.multitracks = multitracks
        self.onChange = onChange
    }
    
    var body: some View {
        VStack {
            Picker("", selection: $selectedMultitrackIndex) {
                ForEach(multitracks) { multitrack in
                    Text(multitrack.name).tag(multitrack.id)
                }
            }
            .pickerStyle(.menu)
        }
    }
}

struct MultitrackPicker_Previews: PreviewProvider {
    static var previews: some View {
        let id = UUID()
        MultitrackPicker(
            selectedMultitrackIndex: id,
            multitracks: [.init(id: id, name: "Multitrack 1")],
            onChange: { _ in
            }
        )
    }
}
