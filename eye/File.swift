import Foundation
import SwiftUI

struct OrbView: View {
    let targetPosition: CGPoint
    let pattern: GazePattern
    
    private var initialPosition: CGPoint {
        let center: CGFloat = 100
        let radius: CGFloat = 80
        
        switch pattern {
        case .horizontal:
            return CGPoint(x: 0, y: center) // Start from left
        case .vertical:
            return CGPoint(x: center, y: 0) // Start from top
        case .diagonal:
            return CGPoint(x: 0, y: 0) // Start from top-left
        case .circular:
            return CGPoint(x: center + radius, y: center) // Start from rightmost point
        }
    }
    
    private func constrainToPattern(_ point: CGPoint) -> CGPoint {
        switch pattern {
        case .horizontal:
            // Constrain to horizontal line at center Y
            return CGPoint(x: max(0, min(point.x, 200)), y: 100)
        case .vertical:
            // Constrain to vertical line at center X
            return CGPoint(x: 100, y: max(0, min(point.y, 200)))
        case .diagonal:
            // Project point onto diagonal line
            let distance = (point.x + point.y) / 2
            let constrainedDistance = max(0, min(distance, 200))
            return CGPoint(x: constrainedDistance, y: constrainedDistance)
        case .circular:
            // Project point onto circle
            let center = CGPoint(x: 100, y: 100)
            let radius: CGFloat = 80
            let dx = point.x - center.x
            let dy = point.y - center.y
            let angle = atan2(dy, dx)
            return CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
        }
    }
    
    var body: some View {
        ZStack {
            // Pattern Guide
            PatternGuideView(pattern: pattern)
                .stroke(Color.blue.opacity(0.2), lineWidth: 2)
                .frame(width: 200, height: 200)
            
            // Animated Orb with enhanced glow
            ZStack {
                // Enhanced outer glow
                ForEach(0..<4) { i in
                    Circle()
                        .fill(Color.blue.opacity(0.3 - Double(i) * 0.05))
                        .frame(width: 50 + CGFloat(i * 12),
                               height: 50 + CGFloat(i * 12))
                        .blur(radius: CGFloat(i * 2))
                }
                
                // Core orb
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [.black, .yellow ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 20
                        )
                    )
                    .frame(width: 30, height: 30)
                    .shadow(color: .blue.opacity(0.6), radius: 8)
            }
            .position(targetPosition == .zero ? initialPosition : constrainToPattern(targetPosition))
        }
    }
}

// Add this enum if not already defined elsewhere
enum GazePattern {
    case horizontal
    case vertical
    case diagonal
    case circular
} 