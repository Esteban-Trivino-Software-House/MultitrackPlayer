//
//  PSUser.swift
//  Play Secuence
//
//  Created by Esteban Triviño on 2/09/25.
//

import Foundation

struct PSUser {
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
