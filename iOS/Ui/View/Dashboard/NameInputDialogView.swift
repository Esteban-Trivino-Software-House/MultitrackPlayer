//
//  NameModalView.swift
//  Play Secuence
//
//  Created by Esteban Triviño on 21/08/25.
//

import SwiftUI

struct NameInputDialogView: View {
    @State var name: String = ""
    var onAccept: ((String) -> Void)
    var onCancel: (() -> Void)
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Enter the multitrack's name")
                .font(.headline)

            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            HStack {
                Button("Cancel") {
                    onCancel()
                }
                .foregroundColor(.red)
                
                Spacer()
                
                Button("Accept") {
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
