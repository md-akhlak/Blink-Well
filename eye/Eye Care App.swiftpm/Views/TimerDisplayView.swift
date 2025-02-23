//
//  File.swift
//  Eye Care App
//
//  Created by Akhlak iSDP on 10/02/25.
//

import Foundation
import SwiftUI

struct TimerDisplayView: View {
    let remainingTime: TimeInterval
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock")
                .foregroundStyle(.blue)
            
            Text(timeString(from: remainingTime))
                .monospacedDigit()
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

