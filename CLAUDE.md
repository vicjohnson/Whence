# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Building

Open `Whence.xcodeproj` in Xcode. There are no CLI build or test commands — build with Cmd+B, run with Cmd+R. External dependencies (`KeyboardShortcuts`, `Sparkle`) are Swift packages resolved automatically by Xcode.

## Architecture

Whence is a macOS snippet launcher. The user presses a global hotkey, a floating panel appears, and they navigate a key-driven tree of text snippets. Selecting a snippet copies it to the clipboard and simulates Cmd+V in the previously active app.

### Data model

`Node` (`Model/Node.swift`) is a recursive value type with two cases:
- `.folder(children: [Node])` — navigable group
- `.snippet(value: String)` — pasteable text

`NodeStore` (`Data/NodeStore.swift`) is `@Observable` and holds the root `[Node]` array. All tree mutations (insert, update, delete) are recursive value-type operations that rebuild the tree and immediately persist to JSON. The storage location is user-configurable via `SettingsStore.storageLocation` (defaults to `~/Library/Application Support/Whence/nodes.json`). `NodeStore` takes a `SettingsStore` at init and is passed via SwiftUI environment to the settings window.

### Settings

`SettingsStore` (`Data/SettingsStore.swift`) is `@Observable @MainActor` and persists all user preferences to `UserDefaults`:
- `panelLocation` — one of the `PanelLocation` cases or `.custom`
- `panelWidth/Height/X/Y` — panel size and position (used when location is `.custom`)
- `storageLocation` — directory URL for `nodes.json`

### Two UI contexts

**Settings window** (`App/`) — a standard SwiftUI `WindowGroup` for managing the snippet tree. `ContentView` renders the tree in a `List`; `EditNodeView` is a sheet for adding/editing nodes; `NodeRow` is the list row component.

**Floating panel** (`Panel/`) — an `NSPanel` managed by `PanelController`. It's keyboard-driven: pressing a node's key activates it (drill into folders or paste snippets). `PanelView` holds a `@State var stack: [Node]` representing the folder navigation history. `Breadcrumbs` renders the nav trail. `PanelRow` is the panel's row component.

### App entry point

`WhenceApp` owns `NodeStore`, `SettingsStore`, and `PanelController` as `@State` properties. The same `SettingsStore` instance is passed to both `NodeStore` and `PanelController` — using separate instances is a common mistake that causes settings changes to not reflect in the panel. It registers the `KeyboardShortcuts.onKeyUp` handler in `init`, capturing `PanelController` by reference. The global shortcut name (`openPanel`) is defined in `Model/Constants.swift`.

`PanelController` handles the full panel lifecycle: creating the `NSStatusItem` menu bar icon (deferred to `DispatchQueue.main.async` to avoid a crash on macOS 15 where the window server connection isn't ready at init time), capturing the frontmost app before showing, positioning the panel, and on paste — writing to `NSPasteboard` then simulating Cmd+V via `CGEvent` after a short delay to let the previous app reactivate. It also manages a preview mode used by the settings page to show the panel's position/size while editing.

### Releasing

See `RELEASING.md`. Sparkle is used for auto-updates, distributed via GitHub Releases. The appcast is hosted on GitHub Pages at `docs/appcast.xml`. Run `./release.sh vX.X.X` to zip, generate the appcast, and fix download URLs.
