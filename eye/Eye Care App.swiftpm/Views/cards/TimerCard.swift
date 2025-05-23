//
//  File.swift
//  Eye Care App
//
//  Created by Akhlak iSDP on 10/02/25.
//

import Foundation
import SwiftUI


struct TimeCard: View {
    let duration: TimeInterval
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(isSelected ? Color.accentBlue : Color.accentBlue.opacity(0.1))
                .frame(width: 56, height: 56)
                .overlay {
                    Image(systemName: getDurationIcon())
                        .font(.title2)
                        .foregroundStyle(isSelected ? .white : .accentBlue)
                }
            
            Text(getDurationTitle())
                .font(.headline)
                .foregroundStyle(isSelected ? .primary : .secondary)
            Text(formatDuration(duration))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: isSelected ? .accentBlue.opacity(0.3) : .black.opacity(0.05),
                       radius: isSelected ? 8 : 4,
                       x: 0,
                       y: isSelected ? 4 : 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.accentBlue : Color.clear, lineWidth: 2)
        )
        .animation(.spring(dampingFraction: 0.7), value: isSelected)
    }
    
    private func getDurationIcon() -> String {
        switch duration {
        case 30:
            return "bolt.fill"
        case 60:
            return "clock.fill"
        default:
            return "timer.circle.fill"
        }
    }
    
    private func getDurationTitle() -> String {
        switch duration {
        case 30:
            return "Quick"
        case 60:
            return "Regular"
        default:
            return "Extended"
        }
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        seconds == 30 ? "30 sec" : seconds == 60 ? "1 min" : "2 min"
    }
}

