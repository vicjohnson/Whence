//
//  NodeStore.swift
//  Whence
//

import Foundation

@Observable
final class NodeStore {
    let settings: SettingsStore
    var root: [Node] = []
    
    private var fileUrl: URL {
        settings.storageLocation.appendingPathComponent(Constants.settingsFileName)
    }

    init(settings: SettingsStore, preview: Bool = false) {
        self.settings = settings
        
        if preview {
            loadSampleData()
        } else {
            load()
        }
    }

    private func loadSampleData() {
        root = [
            Node(key: "d", name: "Development", content: .folder(children: [
                Node(key: "l", name: "Localhost URL", content: .snippet(value: "http://localhost:3000")),
                Node(key: "g", name: "Git email", content: .snippet(value: "vic@example.com")),
            ])),
            Node(key: "p", name: "Personal", content: .folder(children: [
                Node(key: "e", name: "Email", content: .snippet(value: "vic@example.com")),
            ])),
            Node(key: "h", name: "Hello World", content: .snippet(value: "Hello World")),
        ]
        save()
    }

    // MARK: - Mutations

    func addFolder(key: String, name: String, to parentID: UUID? = nil) {
        let node = Node(key: key, name: name, content: .folder(children: []))
        insert(node, into: parentID)
        save()
    }

    func addSnippet(key: String, name: String, value: String, to parentID: UUID? = nil) {
        let node = Node(key: key, name: name, content: .snippet(value: value))
        insert(node, into: parentID)
        save()
    }

    func delete(_ id: UUID) {
        root = remove(id, from: root)
        save()
    }

    func update(id: UUID, key: String, name: String, value: String?) {
        root = updateNode(id: id, key: key, name: name, value: value, in: root)
        save()
    }

    // MARK: - Lookup

    func node(id: UUID) -> Node? {
        find(id, in: root)
    }

    func isDuplicateKey(_ key: String, in parentID: UUID?, excludingID: UUID? = nil) -> Bool {
        let siblings = parentID.flatMap { find($0, in: root)?.children } ?? root
        return siblings.contains { $0.key == key && $0.id != excludingID }
    }

    // MARK: - Persistence

    private func save() {
        do {
            let data = try JSONEncoder().encode(root)
            try data.write(to: fileUrl, options: .atomic)
        } catch {
            print("Failed to save nodes: \(error)")
        }
    }

    func load() {
        guard let data = try? Data(contentsOf: fileUrl) else { return }
        if let decoded = try? JSONDecoder().decode([Node].self, from: data) {
            root = decoded
        }
    }

    // MARK: - Tree helpers

    private func insert(_ node: Node, into parentID: UUID?) {
        if let parentID {
            root = insertInto(parentID, in: root, node: node)
        } else {
            root.append(node)
        }
    }

    private func insertInto(_ parentID: UUID, in nodes: [Node], node: Node) -> [Node] {
        nodes.map { n in
            if n.id == parentID, case .folder(var children) = n.content {
                children.append(node)
                return Node(id: n.id, key: n.key, name: n.name, content: .folder(children: children))
            } else if case .folder(let children) = n.content {
                return Node(id: n.id, key: n.key, name: n.name, content: .folder(children: insertInto(parentID, in: children, node: node)))
            }
            return n
        }
    }

    private func remove(_ id: UUID, from nodes: [Node]) -> [Node] {
        nodes.compactMap { n in
            if n.id == id { return nil }
            if case .folder(let children) = n.content {
                return Node(id: n.id, key: n.key, name: n.name, content: .folder(children: remove(id, from: children)))
            }
            return n
        }
    }

    private func updateNode(id: UUID, key: String, name: String, value: String?, in nodes: [Node]) -> [Node] {
        nodes.map { n in
            if n.id == id {
                let content: Node.Content
                if case .folder(let children) = n.content {
                    content = .folder(children: children)
                } else {
                    content = .snippet(value: value ?? "")
                }
                return Node(id: n.id, key: key, name: name, content: content)
            } else if case .folder(let children) = n.content {
                return Node(id: n.id, key: n.key, name: n.name, content: .folder(children: updateNode(id: id, key: key, name: name, value: value, in: children)))
            }
            return n
        }
    }

    private func find(_ id: UUID, in nodes: [Node]) -> Node? {
        for node in nodes {
            if node.id == id { return node }
            if let children = node.children, let found = find(id, in: children) { return found }
        }
        return nil
    }
}
