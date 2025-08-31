//
//  File.swift
//  Eye Care App
//
//  Created by Akhlak iSDP on 10/02/25.
//


import SwiftUI

struct IllusionEffectsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentIllusion = 0
    
    let illusionTitles = [
        "Rotating Circles",
        "Color Contrast",
        "Moving Lines",
        "Spiral Effect",
        "Pattern Shift"
    ]
    
    let illusionDescriptions = [
        "Focus on the center and observe the rotating motion.",
        "Notice how colors appear to change based on their surroundings.",
        "Keep your eyes fixed and see the lines move.",
        "Look at the center and experience the spiral effect.",
        "Watch the patterns shift as you focus."
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with illusion title
            Text(illusionTitles[currentIllusion])
                .font(.title2.bold())
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
            
            // Main illusion container
            ZStack {
                switch currentIllusion {
                case 0: RotatingCirclesIllusion(isAnimating: true)
                case 1: ColorContrastIllusion(isAnimating: true)
                case 2: MovingLinesIllusion(isAnimating: true)
                case 3: SpiralEffectIllusion(isAnimating: true)
                case 4: PatternShiftIllusion(isAnimating: true)
                default: EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 400)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 8)
            )
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            
            // Description and controls
            VStack(spacing: 24) {
                Text(illusionDescriptions[currentIllusion])
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                
                // Navigation controls
                HStack(spacing: 40) {
                    NavigationButton(
                        icon: "chevron.left",
                        action: previousIllusion,
                        isDisabled: currentIllusion == 0
                    )
                    
                    NavigationButton(
                        icon: "chevron.right",
                        action: nextIllusion,
                        isDisabled: currentIllusion == illusionTitles.count - 1
                    )
                }
            }
            .padding(.bottom, 32)
            
            Spacer()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray)
                        .font(.title3)
                }
            }
        }
    }
    
    private func previousIllusion() {
        withAnimation {
            currentIllusion = (currentIllusion - 1 + illusionTitles.count) % illusionTitles.count
        }
    }
    
    private func nextIllusion() {
        withAnimation {
            currentIllusion = (currentIllusion + 1) % illusionTitles.count
        }
    }
}

// Helper view for navigation buttons
private struct NavigationButton: View {
    let icon: String
    let action: () -> Void
    let isDisabled: Bool
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isDisabled ? .gray : .accentColor)
                .padding(16)
                .background(
                    Circle()
                        .fill(Color.accentColor.opacity(0.1))
                )
        }
        .disabled(isDisabled)
    }
}

// MARK: - Illusion Views
struct RotatingCirclesIllusion: View {
    let isAnimating: Bool
    @State private var rotation = 0.0
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            Circle()
                .fill(Color.red)
                .frame(width: 10, height: 10)
            
            ForEach(0..<8) { index in
                Circle()
                    .stroke(Color.accentBlue, lineWidth: 3)
                    .frame(width: 100, height: 100)
                    .offset(x: 80)
                    .rotationEffect(.degrees(Double(index) * 45))
                    .rotationEffect(.degrees(rotation))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

struct ColorContrastIllusion: View {
    let isAnimating: Bool
    @State private var colorPhase = 0.0
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 2) {
                ForEach(0..<8) { row in
                    HStack(spacing: 2) {
                        ForEach(0..<8) { col in
                            Rectangle()
                                .fill(
                                    Color(
                                        hue: ((Double(row + col) / 16.0) + colorPhase)
                                            .truncatingRemainder(dividingBy: 1.0),
                                        saturation: 1.0,
                                        brightness: 0.8
                                    )
                                )
                                .frame(width: 40, height: 40)
                        }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                colorPhase = 1.0
            }
        }
    }
}

struct MovingLinesIllusion: View {
    let isAnimating: Bool
    @State private var offset: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            HStack(spacing: 0) {
                ForEach(0..<30) { index in
                    Rectangle()
                        .fill(index % 2 == 0 ? Color.white : Color.black)
                        .frame(width: 15)
                        .offset(x: offset)
                }
            }
            .frame(maxHeight: .infinity)
            .mask(
                Circle()
                    .fill(Color.white)
                    .frame(width: 300, height: 300)
                    .blur(radius: 1)
            )
            
            Circle()
                .fill(Color.red)
                .frame(width: 6, height: 6)
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                offset = 15
            }
        }
    }
}

struct SpiralEffectIllusion: View {
    let isAnimating: Bool
    @State private var rotation = 0.0
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            Circle()
                .fill(Color.white)
                .frame(width: 8, height: 8)
            
            ForEach(0..<36) { index in
                Rectangle()
                    .fill(Color.accentBlue.opacity(0.8))
                    .frame(width: 200, height: 2)
                    .offset(x: 100)
                    .rotationEffect(.degrees(Double(index) * 10))
                    .scaleEffect(CGFloat(index) / 36.0)
                    .rotationEffect(.degrees(rotation))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

struct PatternShiftIllusion: View {
    let isAnimating: Bool
    @State private var offset: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            ForEach(0..<8) { row in
                ForEach(0..<8) { col in
                    Circle()
                        .fill(Color.accentBlue.opacity(0.8))
                        .frame(width: 30, height: 30)
                        .offset(x: CGFloat(col) * 40 - 160 + (row % 2 == 0 ? offset : 0),
                               y: CGFloat(row) * 40 - 140)
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: true)) {
                offset = 40
            }
        }
    }
}
