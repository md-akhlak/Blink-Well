//
//  File.swift
//  Eye Care App
//
//  Created by Akhlak iSDP on 22/02/25.
//

import Foundation
import SwiftUI

struct PatternGuideView: Shape {
    let pattern: GazePattern
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let points = pattern.points
        let size = rect.size
        
        guard !points.isEmpty else { return path }
        
        // Convert normalized coordinates to view coordinates
        let viewPoints = points.map { point in
            CGPoint(
                x: size.width * (point.x + 1) / 2,
                y: size.height * (point.y + 1) / 2
            )
        }
        
        path.move(to: viewPoints[0])
        for point in viewPoints.dropFirst() {
            path.addLine(to: point)
        }
        
        return path
    }
}
