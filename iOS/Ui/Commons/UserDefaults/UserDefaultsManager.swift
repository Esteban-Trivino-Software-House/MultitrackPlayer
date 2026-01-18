
//
//  UserDefaultsManager.swift
//  Play Secuence
//
//  Created by Esteban Triviño on 2/09/25.
//  This file is part of the Multitrack Player project.
//


import Foundation
import SwiftUI

/// Manager centralizado para UserDefaults
final class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    /// Guardar valor simple (String, Int, Bool, Double, etc.)
    func set<T>(_ value: T, forKey key: String) {
        defaults.set(value, forKey: key)
    }
    
    /// Obtener valor simple con valor por defecto
    func get<T>(forKey key: String) -> T? {
        return defaults.object(forKey: key) as? T
    }
    
    /// Guardar un objeto que sea Codable
    func setObject<T: Codable>(_ object: T, forKey key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(object) {
            defaults.set(encoded, forKey: key)
        }
    }
    
    /// Leer un objeto Codable
    func getObject<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        if let data = defaults.data(forKey: key) {
            let decoder = JSONDecoder()
            return try? decoder.decode(type, from: data)
        }
        return nil
    }
    
    /// Eliminar un valor
    func remove(forKey key: String) {
        defaults.removeObject(forKey: key)
    }
}
