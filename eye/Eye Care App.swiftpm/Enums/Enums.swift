//
//  File.swift
//  Eye Care App
//
//  Created by Akhlak iSDP on 22/02/25.
//

import Foundation
import SwiftUI



enum GazePattern: String, CaseIterable, Identifiable {
    case square = "Square"
    case triangle = "Triangle"
    case diamond = "Diamond"
    
    var id: String { rawValue }
    
    var name: String { rawValue }
    
    var systemImage: String {
        switch self {
        case .square: return "square"
        case .triangle: return "triangle"
        case .diamond: return "diamond"
        }
    }
    
    var points: [CGPoint] {
        switch self {
        case .square:
            return [
                CGPoint(x: -0.7, y: -0.7),
                CGPoint(x: 0.7, y: -0.7),
                CGPoint(x: 0.7, y: 0.7),
                CGPoint(x: -0.7, y: 0.7),
                CGPoint(x: -0.7, y: -0.7)
            ]
        case .triangle:
            return [
                CGPoint(x: 0, y: -0.7),
                CGPoint(x: 0.7, y: 0.6),
                CGPoint(x: -0.7, y: 0.6),
                CGPoint(x: 0, y: -0.7)
            ]
        case .diamond:
            return [
                CGPoint(x: 0, y: -0.7),
                CGPoint(x: 0.7, y: 0),
                CGPoint(x: 0, y: 0.7),
                CGPoint(x: -0.7, y: 0),
                CGPoint(x: 0, y: -0.7)
            ]
        }
    }
}

