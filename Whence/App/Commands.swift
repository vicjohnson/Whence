//
//  Commands.swift
//  Whence
//

import SwiftUI

private struct AddNodeActionKey: FocusedValueKey {
    typealias Value = () -> Void
}

extension FocusedValues {
    var addNodeAction: (() -> Void)? {
        get { self[AddNodeActionKey.self] }
        set { self[AddNodeActionKey.self] = newValue }
    }
}

struct AddNodeCommands: Commands {
    @FocusedValue(\.addNodeAction) var addNodeAction

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New Node") {
                addNodeAction?()
            }
            .keyboardShortcut("n", modifiers: .command)
        }
    }
}
