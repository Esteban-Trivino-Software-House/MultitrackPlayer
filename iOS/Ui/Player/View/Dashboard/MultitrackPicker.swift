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
    
    // Find current selected multitrack name
    private var selectedMultitrackName: String {
        multitracks.first(where: { $0.id == selectedMultitrackIndex })?.name ?? "Select"
    }
    
    var body: some View {
        Menu {
            ForEach(multitracks) { multitrack in
                Button(action: {
                    selectedMultitrackIndex = multitrack.id
                    onChange(multitrack.id)
                }) {
                    HStack {
                        Text(multitrack.name)
                        if multitrack.id == selectedMultitrackIndex {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack {
                Text(selectedMultitrackName)
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(6)
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
