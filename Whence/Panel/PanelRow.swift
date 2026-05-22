//
//  PanelRow.swift
//  Whence
//
//  Created by Victor Johnson on 5/10/26.
//

import SwiftUI

struct PanelRow: View {
    let node: Node

    var body: some View {
        HStack(spacing: 12) {
            Text(node.key)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 20)
            
            Text(node.name)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if node.isFolder {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            } else {
                Text(node.value ?? "")
                    .foregroundStyle(.secondary)
            }
        }
//        .padding(.horizontal, 12)
//        .padding(.vertical, 8)
    }
}

#Preview {
    let node = Node(key: "e", name: "Example", content: .folder(children: []))
    PanelRow(node: node)
}
