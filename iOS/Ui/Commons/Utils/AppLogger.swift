// AppLogger.swift
// Centralized logger using Apple's Logger API

import Foundation
import os

struct AppLogger {
    static let general = Logger(subsystem: Bundle.main.bundleIdentifier ?? "MultitrackPlayer", category: "general")
    static let coreData = Logger(subsystem: Bundle.main.bundleIdentifier ?? "MultitrackPlayer", category: "coredata")
    static let ui = Logger(subsystem: Bundle.main.bundleIdentifier ?? "MultitrackPlayer", category: "ui")
}
