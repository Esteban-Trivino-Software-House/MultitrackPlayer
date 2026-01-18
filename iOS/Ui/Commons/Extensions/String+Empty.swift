// String+Empty.swift
// Extension to safely handle the empty string and avoid direct use of ""

import Foundation

extension String {
    /// Represents an empty string safely for localization and general use.
    static let empty: String = ""
}

// Uso sugerido:
// String.empty en vez de ""
