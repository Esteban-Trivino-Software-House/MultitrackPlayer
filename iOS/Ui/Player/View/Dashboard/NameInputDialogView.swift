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
    var onAccept: ((String) -> Void)
    var onCancel: (() -> Void)
    
    var body: some View {
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
                    // Here you can validate or save the name
                    onAccept(name)
                }
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
        }
        .padding()
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
