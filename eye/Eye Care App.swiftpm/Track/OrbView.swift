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
            PatternGuideView(pattern: pattern)
                .stroke(Color.yellow.opacity(0.2), lineWidth: 2)
                .frame(width: 250, height: 250)
            
            ZStack {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Color.yellow.opacity(0.2 - Double(i) * 0.05))
                        .frame(width: 60 + CGFloat(i * 15),
                               height: 60 + CGFloat(i * 15))
                        .blur(radius: CGFloat(i * 3))
                }
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.yellow, .white],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 40)
                    .shadow(color: .black.opacity(0.7), radius: 10)
            }
            .offset(x: targetPosition.x * 100, y: targetPosition.y * 100)
        }
    }
}

