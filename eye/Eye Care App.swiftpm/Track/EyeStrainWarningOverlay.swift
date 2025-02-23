//
//  File.swift
//  Eye Care App
//
//  Created by Akhlak iSDP on 10/02/25.
//

import Foundation
import SwiftUI


struct EyeStrainWarningOverlay: View {
    @ObservedObject var viewModel: EyeTrackingViewModel
    
    var body: some View {
        VStack {
            VStack(spacing: 12) {
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.dismissEyeStrainWarning()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.gray)
                    }
                    .padding(.bottom, 8)
                }
                
                Image(systemName: "eye.trianglebadge.exclamationmark")
                    .font(.largeTitle)
                    .foregroundStyle(.orange)
                
                Text("Eye Strain Detected")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                Text("Take a short break and blink naturally")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 10)
            )
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.3))
        .animation(.easeInOut, value: true)
    }
}

