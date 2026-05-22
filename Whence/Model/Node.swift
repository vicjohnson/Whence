//
//  PasteNode.swift
//  Whence
//

import Foundation

struct Node: Identifiable, Codable {
    var id: UUID
    var key: String
    var name: String
    var content: Content

    enum Content: Codable {
        case folder(children: [Node])
        case snippet(value: String)
    }

    init(id: UUID = UUID(), key: String, name: String, content: Content) {
        self.id = id
        self.key = key
        self.name = name
        self.content = content
    }

    var isFolder: Bool {
        if case .folder = content { return true }
        return false
    }

    var children: [Node]? {
        if case .folder(let children) = content { return children }
        return nil
    }

    var value: String? {
        if case .snippet(let value) = content { return value }
        return nil
    }
}
