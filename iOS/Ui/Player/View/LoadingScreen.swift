//
//  LoadingScreen.swift
//  Play Secuence
//
//  Created by Esteban Triviño on 21/08/25.
//

import SwiftUI


public struct LoadingScreen: View {
    public var body: some View {
        VStack {
            Spacer()
            ProgressView("Loading...")
                .progressViewStyle(CircularProgressViewStyle())
            Spacer()
        }
        .background(.white)
    }
}

struct LoadingScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoadingScreen()
    }
}
