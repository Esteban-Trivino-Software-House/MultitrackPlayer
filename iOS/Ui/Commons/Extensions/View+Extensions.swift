//
//  ConditionalModifier.swift
//  Play Secuence
//
//  Created by Esteban Triviño on 2/09/25.
//


import SwiftUI

struct ConditionalModifier: ViewModifier {
    let isVisible: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if isVisible {
            content
        } else {
            EmptyView()
        }
    }
}

extension View {
    func isVisible(_ visible: Bool) -> some View {
        self.modifier(ConditionalModifier(isVisible: visible))
    }
}
