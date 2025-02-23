//
//  File.swift
//  Eye Care App
//
//  Created by Akhlak iSDP on 22/02/25.
//

import Foundation
import SwiftUI


struct OrbView: View {
    let targetPosition: CGPoint
    let pattern: GazePattern
    
    var body: some View {
        ZStack {
            // Pattern Guide
            PatternGuideView(pattern: pattern)
                .stroke(Color.blue.opacity(0.2), lineWidth: 2)
                .frame(width: 200, height: 200)
            
            // Animated Orb
            ZStack {
                // Outer glow
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Color.blue.opacity(0.2 - Double(i) * 0.05))
                        .frame(width: 60 + CGFloat(i * 15),
                               height: 60 + CGFloat(i * 15))
                        .blur(radius: CGFloat(i * 3))
                }
                
                // Core orb
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.yellow, .white],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 45, height: 45)
                    .shadow(color: .blue.opacity(0.5), radius: 10)
            }
            .offset(x: targetPosition.x * 100, y: targetPosition.y * 100)
        }
    }
}
