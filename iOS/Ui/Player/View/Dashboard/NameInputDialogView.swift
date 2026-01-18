//
//  NameModalView.swift
//  Play Secuence
//
//  Created by Esteban Triviño on 21/08/25.
//

import SwiftUI

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
                    // Aquí puedes validar o guardar el nombre
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
            print(name)
        } onCancel: {
            
        }
    }
}
