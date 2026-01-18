// FirebaseAnalyticsManager.swift
// Centralizes the handling of Firebase Analytics events

import Foundation
import FirebaseAnalytics

final class FirebaseAnalyticsManager {
    static let shared = FirebaseAnalyticsManager()
    private init() {}

    func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
    }

    func logAuthEvent(
        _ status: String,
        method: String,
        userEmail: String? = nil,
        userId: String? = nil,
        isAnonymous: Bool? = nil,
        error: Error? = nil
    ) {
        var params: [String: Any] = [
            "status": status,
            "method": method
        ]
        if let email = userEmail {
            params["user_email"] = email
        }
        if let userId = userId {
            params["user_id"] = userId
        }
        if let isAnonymous = isAnonymous {
            params["is_anonymous"] = isAnonymous
        }
        if let error = error {
            params["error_description"] = error.localizedDescription
        }
        logEvent("auth_event", parameters: params)
    }
}
