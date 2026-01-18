// String+Empty.swift
// Extensión para manejar el empty string de forma segura y evitar el uso directo de ""

import Foundation

extension String {
    /// Representa un string vacío de forma segura para localización y uso general.
    static let empty: String = ""
}

// Uso sugerido:
// String.empty en vez de ""
