//
//  Multitrack.swift
//  Play Secuence (iOS)
//
//  Created by Esteban Rafael Trivino Guerra on 9/09/22.
//

import Foundation
import CoreData

struct Multitrack: Identifiable {
    private(set) var id: UUID
    var name: String
    var tracks: [Track] = []
}

extension Multitrack {
    func mapToMultitrackDao(context: NSManagedObjectContext) -> MultitrackDao {
        let multitrackDao = MultitrackDao(context: context)
        multitrackDao.id = self.id
        multitrackDao.name = self.name
        multitrackDao.userId = SessionManager.shared.user?.id ?? ""
        return multitrackDao
    }
}

extension MultitrackDao {
    func mapToMultitrack() -> Multitrack {
        Multitrack(id: self.id ?? UUID(), name: self.name!)
    }
}
