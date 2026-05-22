//
//  NodeRow.swift
//  Whence
//
//  Created by Victor Johnson on 5/10/26.
//

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
            }
        }
    }
}
