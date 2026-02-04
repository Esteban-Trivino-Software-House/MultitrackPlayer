//
//  NameModalView.swift
//  Play Secuence
//
//  Created by Esteban Triviño on 21/08/25.
//  This file is part of the Multitrack Player project.
//

import SwiftUI
import os

struct NameInputDialogView: View {
    @State var name: String = String.empty
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var onAccept: ((String) -> Void)
    var onCancel: (() -> Void)
    
    var body: some View {
        // Responsive sizes based on device type
        let isCompact = horizontalSizeClass == .compact // iPhone
        let maxWidth = isCompact ? 360.0 : 520.0
        let maxHeight = isCompact ? 240.0 : 280.0
        
        VStack(spacing: 20) {
            Text(String(localized: "enter_name"))
                .font(.headline)

            TextField(String(localized: "name"), text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            HStack {
                Button(String(localized: "cancel")) {
                    onCancel()
                }
                .foregroundColor(.red)
                
                Spacer()
                
                Button(String(localized: "accept")) {
                    onAccept(name)
                }
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: maxWidth, maxHeight: maxHeight)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}

struct NameInputDialogView_Previews: PreviewProvider {
    static var previews: some View {
        NameInputDialogView { name in
            AppLogger.ui.info("Name entered: \(name)")
        } onCancel: {
            
        }
    }
}
