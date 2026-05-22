//
//  PanelController.swift
//  Whence
//

import AppKit
import SwiftUI

final class PanelController {
    private var panel: NSPanel?
    private let store: NodeStore
    private let settings: SettingsStore
    private var previousApp: NSRunningApplication?
    private var statusItem: NSStatusItem?
    private var isPreviewMode = false

    init(store: NodeStore, settings: SettingsStore) {
        self.store = store
        self.settings = settings
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
            statusItem?.button?.image = NSImage(systemSymbolName: "list.clipboard", accessibilityDescription: "Whence")
            statusItem?.button?.action = #selector(statusItemClicked)
            statusItem?.button?.target = self
        }
    }

    @objc private func statusItemClicked() {
        show()
    }

    func showPreview(onFrameChanged: @escaping (CGRect) -> Void) {
        isPreviewMode = true
        if panel == nil { panel = makePanel() }
        resetContent()
        panel?.setFrame(settings.customPanelFrame, display: true)
        panel?.orderFront(nil)

        for notification in [NSWindow.didMoveNotification, NSWindow.didResizeNotification] {
            NotificationCenter.default.addObserver(
                forName: notification,
                object: panel,
                queue: .main
            ) { [weak self] _ in
                guard let panel = self?.panel else { return }
                onFrameChanged(panel.frame)
            }
        }
    }

    func updatePreviewFrame() {
        guard isPreviewMode, let panel else { return }
        if settings.panelLocation == .custom {
            panel.setFrame(settings.customPanelFrame, display: true)
        } else {
            positionPanel()
        }
    }

    func hidePreview() {
        guard isPreviewMode else { return }
        isPreviewMode = false
        NotificationCenter.default.removeObserver(self, name: NSWindow.didMoveNotification, object: panel)
        NotificationCenter.default.removeObserver(self, name: NSWindow.didResizeNotification, object: panel)
        panel?.orderOut(nil)
    }

    func show() {
        if isPreviewMode { hidePreview() }
        let frontmost = NSWorkspace.shared.frontmostApplication
        if frontmost?.bundleIdentifier != Bundle.main.bundleIdentifier {
            previousApp = frontmost
        }
        if panel == nil {
            panel = makePanel()
        }
        resetContent()
        positionPanel()
        panel?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        // Close on click outside
        NotificationCenter.default.addObserver(
            forName: NSWindow.didResignKeyNotification,
            object: panel,
            queue: .main
        ) { [weak self] _ in
            self?.hide()
        }
    }

    func hide() {
        NotificationCenter.default.removeObserver(self, name: NSWindow.didResignKeyNotification, object: panel)
        panel?.orderOut(nil)
        previousApp?.activate()
    }

    func pasteAndHide(value: String) {
        let savedItems = NSPasteboard.general.pasteboardItems?.map { item -> NSPasteboardItem in
            let copy = NSPasteboardItem()
            for type in item.types {
                if let data = item.data(forType: type) {
                    copy.setData(data, forType: type)
                }
            }
            return copy
        }

        panel?.orderOut(nil)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(value, forType: .string)
        previousApp?.activate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.simulatePaste()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NSPasteboard.general.clearContents()
                if let items = savedItems {
                    NSPasteboard.general.writeObjects(items)
                }
            }
        }
    }

    private func positionPanel() {
        guard let panel, let screen = NSScreen.main else { return }

        let size = NSSize(width: settings.panelWidth, height: settings.panelHeight)
        panel.setContentSize(size)

        let defaultMargin: CGFloat = 16
        var origin: NSPoint = NSPoint(x: defaultMargin, y: defaultMargin)

        switch settings.panelLocation {
        case .topLeft:
            origin = NSPoint(x: defaultMargin, y: screen.visibleFrame.maxY - panel.frame.height - defaultMargin)
        case .topRight:
            origin = NSPoint(x: screen.visibleFrame.maxX - panel.frame.width - defaultMargin,
                             y: screen.visibleFrame.maxY - panel.frame.height - defaultMargin)
        case .bottomLeft:
            origin = NSPoint(x: defaultMargin, y: defaultMargin)
        case .bottomRight:
            origin = NSPoint(x: screen.visibleFrame.maxX - panel.frame.width - defaultMargin, y: defaultMargin)
        case .custom:
            origin = NSPoint(x: settings.panelX, y: settings.panelY)
        }
        
        panel.setFrameOrigin(origin)
    }

    private func resetContent() {
        panel?.contentView = makeContentView()
    }

    private func makeContentView() -> NSView {
        NSHostingView(rootView:
            PanelView(
                store: store,
                dismiss: { [weak self] in self?.hide() },
                paste: { [weak self] value in self?.pasteAndHide(value: value) },
                isPreview: isPreviewMode
            )
        )
    }

    private func makePanel() -> NSPanel {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 400),
            styleMask: [.titled, .resizable, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.isMovableByWindowBackground = true
        panel.title = ""
        panel.titlebarAppearsTransparent = true
        panel.standardWindowButton(.closeButton)?.isHidden = true
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true
        panel.contentView = makeContentView()
        return panel
    }
    
    private func simulatePaste() {
        let source = CGEventSource(stateID: .hidSystemState)
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        keyDown?.flags = .maskCommand
        keyUp?.flags = .maskCommand
        keyDown?.post(tap: .cgAnnotatedSessionEventTap)
        keyUp?.post(tap: .cgAnnotatedSessionEventTap)
    }
}
