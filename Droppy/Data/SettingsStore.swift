//
//  Settings.swift
//  Droppy
//
//  Created by Victor Johnson on 5/14/26.
//

import CoreGraphics
import Foundation
import Observation

@MainActor
@Observable
class SettingsStore {
    private let userDefaults = UserDefaults.standard
    
    private enum Setting {
        static let panelLocation = "panelLocation"
        static let customPanelFrame = "customPanelFrame"
        static let storageLocation = "storageLocation"
    }
    
    init() {
        initPanelLocation()
        initStorageLocation()
    }
    
    // MARK: - Panel Location
    
    var panelLocation: PanelLocation = .topRight {
        didSet {
            userDefaults.set(panelLocation.rawValue, forKey: Setting.panelLocation)
        }
    }
    
    func initPanelLocation() {
        if let panelLocation = userDefaults.string(forKey: Setting.panelLocation) {
            self.panelLocation = PanelLocation(rawValue: panelLocation) ?? .topRight
        }
        if let str = userDefaults.string(forKey: Setting.customPanelFrame) {
            let rect = NSRectFromString(str)
            self.panelX = rect.origin.x
            self.panelY = rect.origin.y
            self.panelWidth = rect.size.width
            self.panelHeight = rect.size.height
        }
    }
    
    var panelWidth: Double = 320 { didSet { saveFrame() } }
    var panelHeight: Double = 400 { didSet { saveFrame() } }
    var panelX: Double = 0 { didSet { saveFrame() } }
    var panelY: Double = 0 { didSet { saveFrame() } }

    var customPanelFrame: CGRect {
        CGRect(x: panelX, y: panelY, width: panelWidth, height: panelHeight)
    }
    
    private func saveFrame() {
        userDefaults.set(NSStringFromRect(customPanelFrame), forKey: Setting.customPanelFrame)
    }

    // MARK: - Storage Location
    
    private static let defaultStorageLocation = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appendingPathComponent("Droppy")
    var storageLocation: URL = SettingsStore.defaultStorageLocation {
        didSet {
            userDefaults.set(storageLocation, forKey: Setting.storageLocation)
        }
    }
    
    func initStorageLocation() {
        if let storageLocation = userDefaults.url(forKey: Setting.storageLocation) {
            self.storageLocation = storageLocation
        }
        
        // Create the directory if it doesn't exist
        try? FileManager.default.createDirectory(at: self.storageLocation, withIntermediateDirectories: true)
    }

    // MARK: - Helpers

    func debug() {
        print(panelLocation)
        print(customPanelFrame)
        print(storageLocation)
    }
}
