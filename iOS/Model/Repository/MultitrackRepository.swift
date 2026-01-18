//
//  MultitrackRepository.swift
//  Play Secuence (iOS)
//
//  Created by Esteban Rafael Trivino Guerra on 27/02/23.
//

import Foundation

protocol MultitrackRepository {
    func saveMultitrack(_ multitrack: Multitrack)
    func loadMultitracks() -> Dictionary<UUID, Multitrack>
    func loadMultitrack(id: UUID) -> Multitrack
    func deleteMultitrack(_ multitrackId: UUID)
    func updateMultitrackName(multitrackId: UUID, newName: String)
}
