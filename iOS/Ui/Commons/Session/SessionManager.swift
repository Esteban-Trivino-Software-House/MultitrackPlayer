//
//  SessionManager.swift
//  Play Secuence
//
//  Created by Esteban Triviño on 2/09/25.
//

final class SessionManager {
    
    private(set) var user: PSUser?
    
    public static let shared = SessionManager()
    
    private init() {}
    
    func setSession(user: PSUser) {
        self.user = user
    }
    
    func clearSession() {
        user = nil
    }
}
