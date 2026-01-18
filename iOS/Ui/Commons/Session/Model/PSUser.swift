
//
//  PSUser.swift
//  Play Secuence
//
//  Created by Esteban Triviño on 2/09/25.
//  This file is part of the Multitrack Player project.
//

import Foundation

struct PSUser: Codable {
    let id: String?
    var name: String?
    var email: String?
    var isAnonymous: Bool
    
    init(id: String?,
         name: String? = nil,
         email: String? = nil,
         isAnonymous: Bool = false) {
        self.id = id
        self.name = name
        self.email = email
        self.isAnonymous = isAnonymous
    }
}
