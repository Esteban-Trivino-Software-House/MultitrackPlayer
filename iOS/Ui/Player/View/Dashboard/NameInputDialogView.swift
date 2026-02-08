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
    @State var showEmptyNameAlert: Bool = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var suggestedName: String?
    var onAccept: ((String) -> Void)
    var onCancel: (() -> Void)
    
    private let maxNameLength = 50
    
    // Check if name is valid (not empty and not just whitespace)
    private var isNameValid: Bool {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        return !trimmed.isEmpty && trimmed.count <= maxNameLength
    }
    
    // Check if name reached max length
    private var reachedMaxLength: Bool {
        name.count == maxNameLength
    }
    
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
                    .onChange(of: name) { oldValue, newValue in
                        // Limit to 50 characters
                        if newValue.count > maxNameLength {
                            name = String(newValue.prefix(maxNameLength))
                        }
                    }
                    .onAppear {
                        // Set initial value only once on appear
                        if name.isEmpty && !initialName.isEmpty {
                            name = initialName
                        }
                    }
                
                // Character counter
                HStack(spacing: 4) {
                    Spacer()
                    Text("\(name.count)/\(maxNameLength)")
                        .font(.caption2)
                        .foregroundColor(reachedMaxLength ? .red : .secondary)
                }
                .padding(.horizontal)
                
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
                
                // Show error message if name is empty
                if name.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.caption2)
                        Text("Required field")
                            .font(.caption2)
                    }
                    .foregroundColor(.red)
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
                    // Validate before accepting
                    if isNameValid {
                        onAccept(name.trimmingCharacters(in: .whitespaces))
                    } else {
                        showEmptyNameAlert = true
                    }
                }
                .foregroundColor(.blue)
                .disabled(!isNameValid)
                .opacity(isNameValid ? 1.0 : 0.5)
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: maxWidth, maxHeight: maxHeight)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .alert("Invalid Name", isPresented: $showEmptyNameAlert) {
            Button("OK") { }
        } message: {
            Text("Please enter a name with at least 1 character.")
        }
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
