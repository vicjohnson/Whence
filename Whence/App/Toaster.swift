//
//  Toaster.swift
//  Whence
//
//  Created by Victor Johnson on 6/23/26.
//

import Foundation
import SwiftUI

struct Toast : View {
    var toast: ToastValue
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text(toast.value)
        }
        .padding(8)
        .background {
            Capsule()
                .fill(.regularMaterial)
        }
    }
}

struct ToastValue: Identifiable, Equatable {
    let id: UUID = UUID()
    let value: String
}

@Observable
class Toaster {
    static let shared = Toaster()
    
    var toasts: [ToastValue] = []
    
    func addToast(_ str: String) {
        let toast = ToastValue(value: str)
        withAnimation(.easeOut(duration: 0.2)) {
            toasts.append(toast)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if let idx = self.toasts.firstIndex(of: toast) {
                _ = withAnimation(.easeIn(duration: 0.2)) {
                    self.toasts.remove(at: idx)
                }
            }
        }
    }
}
