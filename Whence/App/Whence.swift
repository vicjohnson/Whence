//
//  Whence.swift
//  Whence
//

import SwiftUI
import KeyboardShortcuts
import Sparkle

@main
struct Whence: App {
    private let updaterController = SPUStandardUpdaterController(
        startingUpdater: true,
        updaterDelegate: nil,
        userDriverDelegate: nil
    )
    
    @State private var settings: SettingsStore
    @State private var store: NodeStore
    @State private var panelController: PanelController

    init() {
        let settings = SettingsStore()
        let store = NodeStore(settings: settings)
        let controller = PanelController(store: store, settings: settings)
        
        _settings = State(initialValue: settings)
        _store = State(initialValue: store)
        _panelController = State(initialValue: controller)
        
        KeyboardShortcuts.onKeyUp(for: .openPanel) { [controller] in
            controller.show()
        }
        
        #if DEBUG
        settings.debug()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
        .defaultPosition(.topTrailing)
        .defaultSize(width: 400, height: 1400)
        .onChange(of: settings.storageLocation) {
            store.load()
        }

        Settings {
            SettingsPage(panelController: panelController, checkForUpdates: {
                updaterController.checkForUpdates(nil)
            })
            .environment(store)
            .environment(settings)
        }
        .defaultSize(width: 600, height: 500)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(after: .appInfo) {
                Button("Check for Updates") {
                    updaterController.checkForUpdates(nil)
                }
            }
        }
    }
}
