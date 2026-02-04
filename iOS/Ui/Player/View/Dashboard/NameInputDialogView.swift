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
    var suggestedName: String?
    var onAccept: ((String) -> Void)
    var onCancel: (() -> Void)
    
    var body: some View {
        // Responsive sizes based on device type
        let isCompact = horizontalSizeClass == .compact // iPhone
        let maxWidth = isCompact ? 360.0 : 520.0
        let maxHeight = isCompact ? 240.0 : 280.0
        
        // Pre-fill with suggested name if available
        let initialName = suggestedName ?? String.empty
        
        VStack(spacing: 20) {
            Text(String(localized: "enter_name"))
                .font(.headline)
            
            // Text field with suggested name
            VStack(alignment: .leading, spacing: 4) {
                TextField(String(localized: "name"), text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .onAppear {
                        // Set initial value only once on appear
                        if name.isEmpty && !initialName.isEmpty {
                            name = initialName
                        }
                    }
                
                // Show AI Suggested badge if we used a suggestion
                if !initialName.isEmpty && name == initialName {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.caption2)
                        Text("AI Suggested")
                            .font(.caption2)
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                }
            }

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
        Group {
            // Preview without suggestion
            NameInputDialogView(suggestedName: nil) { name in
                AppLogger.ui.info("Name entered: \(name)")
            } onCancel: {
                
            }
            .previewDisplayName("No Suggestion")
            
            // Preview with suggestion
            NameInputDialogView(suggestedName: "Jazz Session 3") { name in
                AppLogger.ui.info("Name entered: \(name)")
            } onCancel: {
                
            }
            .previewDisplayName("With Suggestion")
        }
    }
}
