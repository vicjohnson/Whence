//
//  PanelLocation.swift
//  Whence
//
//  Created by Victor Johnson on 5/14/26.
//

import Foundation

enum PanelLocation : String, CaseIterable, Identifiable {
    case topLeft = "Top left"
    case topRight = "Top right"
    case bottomLeft = "Bottom left"
    case bottomRight = "Bottom right"
    case custom = "Custom"
    
    var id: Self { self }
}
