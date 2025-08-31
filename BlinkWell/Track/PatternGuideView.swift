//
//  File.swift
//  Eye Care App
//
//  Created by Akhlak iSDP on 10/02/25.
//


import Foundation
import SwiftUI

struct PatternGuideView: Shape {
    let pattern: GazePattern
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let points = pattern.points
        
        guard !points.isEmpty else { return path }
        
        let viewPoints = points.map { point in
            CGPoint(
            )
        }
        
        path.move(to: viewPoints[0])
        for point in viewPoints.dropFirst() {
            path.addLine(to: point)
        }
        
        return path
    }
}

