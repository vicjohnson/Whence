//
//  PanelView.swift
//  Whence

import SwiftUI

struct PanelView: View {
    let store: NodeStore
    let dismiss: () -> Void
    let paste: (String) -> Void
    var isPreview: Bool = false

    @State private var stack: [Node] = []
    @FocusState private var focused: Bool

    private var current: [Node] {
        stack.last?.children ?? store.root
    }

    var body: some View {
        VStack(spacing: 0) {
            Breadcrumbs(stack: $stack)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            
            Divider()

            if current.isEmpty {
                Text("No items")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(current) { node in
                            PanelRow(node: node)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .contentShape(Rectangle())
                                .onTapGesture { if !isPreview { activate(node) } }
                            Divider()
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
        .ignoresSafeArea()
        .focusable()
        .focused($focused)
        .focusEffectDisabled()
        .onKeyPress(phases: .down) { press in
            guard !isPreview else { return .ignored }
            return handleKey(press)
        }
        .onAppear { focused = true }
    }

    private func handleKey(_ press: KeyPress) -> KeyPress.Result {
        if press.key == .escape {
            if stack.isEmpty {
                dismiss()
            } else {
                goBack()
            }
            return .handled
        }

        let char = String(press.characters)
        if let match = current.first(where: { $0.key == char }) {
            activate(match)
            return .handled
        }

        return .ignored
    }

    private func activate(_ node: Node) {
        switch node.content {
        case .folder(_):
            stack.append(node)
        case .snippet(let value):
            paste(value)
        }
    }

    private func goBack() {
        stack.removeLast()
    }
}

#Preview {
    let store = NodeStore(settings: SettingsStore(), preview: true)
    return PanelView(store: store, dismiss: {}, paste: { _ in })
}
