//
//  ContentView.swift
//  Whence
//

import SwiftUI

struct ContentView: View {
    @Environment(NodeStore.self) private var store
    private var toaster = Toaster.shared
    
    @State private var selectedID: UUID?
    @State private var formMode: EditNodeView.Mode?

    private var addTargetParentID: UUID? {
        guard let id = selectedID, let node = store.node(id: id) else { return nil }
        return node.isFolder ? node.id : store.parentID(of: id)
    }

    var body: some View {
        List(store.root, id: \.id, children: \.children, selection: $selectedID) { node in
            NodeRow(node: node)
                .padding(4)
                .contextMenu {
                    if node.isFolder {
                        Button("Add to \(node.name)") {
                        formMode = .add(parentID: node.id)
                    }
                    Divider()
                    }
                    Button("Edit") {
                        formMode = .edit(node: node)
                    }
                    Button("Delete", role: .destructive) {
                        store.delete(node.id)
                    }
                }
        }
        .overlay(alignment: .top) {
            VStack() {
                ForEach(toaster.toasts) { toast in
                    Toast(toast: toast)
                        .transition(.asymmetric(
                            insertion: .move(edge: .top),
                            removal: .move(edge: .top)
                        ))
                }
            }
        }
        .toolbar {
            Button(action: {
                formMode = .add(parentID: addTargetParentID)
            }) {
                Label("Add", systemImage: "plus")
            }
        }
        .sheet(item: $formMode) { mode in
            EditNodeView(mode: mode) {
                formMode = nil
            }
        }
        .onKeyPress(.return) {
            guard let id = selectedID, let node = store.node(id: id) else { return .ignored }
            formMode = .edit(node: node)
            return .handled
        }
        .onDeleteCommand {
            guard let id = selectedID else { return }
            store.delete(id)
            selectedID = nil
        }
        .onCopyCommand {
            guard let id = selectedID,
                  let value = store.node(id: id)?.value else {
                return []
            }
            
            Toaster.shared.addToast("Copied!")
            return [NSItemProvider(object: value as NSString)]
        }
        .frame(minWidth: 400, minHeight: 300)
        .navigationTitle("Whence")
        .focusedValue(\.addNodeAction, { formMode = .add(parentID: addTargetParentID) })
        .overlay {
            if store.root.isEmpty {
                VStack {
                    Text("No items")
                    Button("Add a snippet") {
                        formMode = .add(parentID: nil)
                    }
                }
            }
        }
        #if DEBUG
        .overlay(alignment: .bottom) {
            GeometryReader { geo in
                Text("\(Int(geo.size.width)) × \(Int(geo.size.height))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 4)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
        #endif // DEBUG
    }
}

#Preview("ContentView") {
    let store = NodeStore(settings: SettingsStore())
    return ContentView()
        .environment(store)
}

#Preview("Empty") {
    let store = NodeStore(settings: SettingsStore(), preview: true)
    store.root = []
    
    return ContentView()
        .environment(store)
}
