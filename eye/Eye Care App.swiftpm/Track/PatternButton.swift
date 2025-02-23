//
//  File.swift
//  Eye Care App
//
//  Created by Akhlak iSDP on 10/02/25.
//


import Foundation
import SwiftUI


struct PatternButton: View {
    let pattern: GazePattern
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: pattern.systemImage)
                    .font(.title2)
                Text(pattern.name)
                    .font(.caption)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .foregroundColor(isSelected ? .blue : .primary)
    }
}

