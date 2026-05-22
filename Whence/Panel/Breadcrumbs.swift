//
//  Breadcrumbs.swift
//  Whence
//
//  Created by Victor Johnson on 5/10/26.
//

import SwiftUI

struct Breadcrumbs : View {
    @Binding var stack: [Node]
    
    var body: some View {
        HStack(spacing: 4) {
            Button("Home") { stack.removeAll() }
                .buttonStyle(.plain)
                .foregroundStyle(stack.isEmpty ? .primary : .secondary)
            
            ForEach(stack.indices, id: \.self) { i in
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                Button(stack[i].name) { stack.removeSubrange((i + 1)...) }
                    .buttonStyle(.plain)
                    .foregroundStyle(i == stack.indices.last ? .primary : .secondary)
            }
            
            Spacer()
        }
    }
}
