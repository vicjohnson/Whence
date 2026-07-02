//
//  NodeRow.swift
//  Whence
//
//  Created by Victor Johnson on 5/10/26.
//

import AppKit
import SwiftUI

struct NodeRow: View {
    let node: Node

    var body: some View {
        HStack(spacing: 8) {
            Text(node.key)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 20)
            Text(node.name)
            Spacer()
            if let value = node.value {
                Text(value)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Button {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(value, forType: .string)
                    Toaster.shared.addToast("Copied!")
                } label: {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.borderless)
                .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NodeRow(node: Node(key: "k", name: "Example", content: .snippet(value: "some example content")))
}
