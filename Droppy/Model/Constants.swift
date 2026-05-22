//
//  Constants.swift
//  Droppy
//

import AppKit
import Foundation
import KeyboardShortcuts

enum Constants {
    static let settingsFileName = "nodes.json"
}

extension KeyboardShortcuts.Name {
    static let openPanel = Self("openPanel", default: .init(.v, modifiers: [.command, .shift]))
}
