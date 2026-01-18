//
//  SystemInfo.swift
//  Play Secuence
//
//  Created by Esteban Triviño on 2/09/25.
//

import Foundation

struct SystemInfo {
    static let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    static let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
}
