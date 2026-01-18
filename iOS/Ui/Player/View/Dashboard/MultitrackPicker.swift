//
//  MultitrackPicker.swift
//  Play Secuence
//
//  Created by Esteban Triviño on 21/08/25.
//

import SwiftUI

struct MultitrackPicker: View {
    @State var selectedMultitrackIndex: UUID
    var multitracks: [Multitrack]
    var onChange: (UUID) -> Void
    
    var body: some View {
        VStack {
            Picker("", selection: $selectedMultitrackIndex) {
                ForEach(multitracks) { multitrack in
                    Text(multitrack.name).tag(multitrack.id)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: selectedMultitrackIndex) { oldValue, newValue in
                onChange(newValue)
            }
        }
    }
}

struct MultitrackPicker_Previews: PreviewProvider {
    struct MyPreview: View {
        @State var id: UUID = UUID()
        var body: some View {
            MultitrackPicker(
                selectedMultitrackIndex: id,
                multitracks: [.init(id: id, name: "Multitrack 1")],
                onChange: { _ in
                }
            )
        }
    }
    static var previews: some View {
        MyPreview()
    }
}
