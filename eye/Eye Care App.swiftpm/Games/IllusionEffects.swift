//
//  File.swift
//  Eye Care App
//
//  Created by Akhlak iSDP on 10/02/25.
//


import SwiftUI

struct IllusionEffectsView: View {
    @State private var currentIllusion = 0
    @State private var isAnimating = false
    
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
        VStack(spacing: 20) {
            Text(illusionTitles[currentIllusion])
                .font(.title.bold())
                .padding(.top, 20)
            
            ZStack {
                switch currentIllusion {
                case 0:
                    RotatingCirclesIllusion(isAnimating: isAnimating)
                case 1:
                    ColorContrastIllusion(isAnimating: isAnimating)
                case 2:
                    MovingLinesIllusion(isAnimating: isAnimating)
                case 3:
                    SpiralEffectIllusion(isAnimating: isAnimating)
                case 4:
                    PatternShiftIllusion(isAnimating: isAnimating)
                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 400)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(.horizontal, 20)
            
            Text(illusionDescriptions[currentIllusion])
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
            
            HStack(spacing: 30) {
                Button(action: previousIllusion) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .clipShape(Circle())
                }
                .disabled(currentIllusion == 0)
                
                Button(action: nextIllusion) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .clipShape(Circle())
                }
                .disabled(currentIllusion == illusionTitles.count - 1)
            }
            .padding(.vertical, 10)
            
            Toggle("Animate", isOn: $isAnimating)
                .padding()
                .frame(maxWidth: 300)
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.bottom, 20)
        }
        .navigationTitle("Optical Illusions")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            isAnimating = true
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

// MARK: - Illusion Views
struct RotatingCirclesIllusion: View {
    let isAnimating: Bool
    @State private var rotation = 0.0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.red)
                .frame(width: 10, height: 10)
            
            ForEach(0..<8) { index in
                Circle()
                    .stroke(Color.blue, lineWidth: 3)
                    .frame(width: 100, height: 100)
                    .offset(x: 80)
                    .rotationEffect(.degrees(Double(index) * 45))
                    .rotationEffect(.degrees(isAnimating ? rotation : 0))
            }
        }
        .onChange(of: isAnimating) { newValue in
            withAnimation(newValue ?
                .linear(duration: 8).repeatForever(autoreverses: false) :
                .default) {
                rotation = newValue ? 360 : 0
            }
        }
    }
}

struct ColorContrastIllusion: View {
    let isAnimating: Bool
    @State private var colorPhase = 0.0
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack(spacing: 2) {
                ForEach(0..<8) { row in
                    HStack(spacing: 2) {
                        ForEach(0..<8) { col in
                            Rectangle()
                                .fill(
                                    Color(
                                        hue: ((Double(row + col) / 16.0) + (isAnimating ? colorPhase : 0))
                                            .truncatingRemainder(dividingBy: 1.0),
                                        saturation: 1.0,
                                        brightness: 0.8
                                    )
                                )
                                .frame(width: 40, height: 40)
                                .animation(
                                    .linear(duration: 0.5),
                                    value: isAnimating
                                )
                        }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .onChange(of: isAnimating) { newValue in
            withAnimation(newValue ?
                .linear(duration: 8).repeatForever(autoreverses: false) :
                .default) {
                colorPhase = newValue ? 1.0 : 0.0
            }
        }
    }
}

struct MovingLinesIllusion: View {
    let isAnimating: Bool
    @State private var offset: CGFloat = 0
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            HStack(spacing: 0) {
                ForEach(0..<30) { index in
                    Rectangle()
                        .fill(index % 2 == 0 ? Color.white : Color.black)
                        .frame(width: 15)
                        .offset(x: isAnimating ? offset : 0)
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
        .onChange(of: isAnimating) { newValue in
            withAnimation(newValue ?
                .linear(duration: 1.5).repeatForever(autoreverses: false) :
                .default) {
                offset = newValue ? 15 : 0
            }
        }
    }
}

struct SpiralEffectIllusion: View {
    let isAnimating: Bool
    @State private var rotation = 0.0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 8, height: 8)
            
            ForEach(0..<36) { index in
                Rectangle()
                    .fill(Color.blue.opacity(0.8))
                    .frame(width: 200, height: 2)
                    .offset(x: 100)
                    .rotationEffect(.degrees(Double(index) * 10))
                    .scaleEffect(CGFloat(index) / 36.0)
                    .rotationEffect(.degrees(isAnimating ? rotation : 0))
            }
        }
        .onChange(of: isAnimating) { newValue in
            withAnimation(newValue ?
                .linear(duration: 6).repeatForever(autoreverses: false) :
                .default) {
                rotation = newValue ? 360 : 0
            }
        }
    }
}

struct PatternShiftIllusion: View {
    let isAnimating: Bool
    @State private var offset: CGFloat = 0
    
    var body: some View {
        ZStack {
            ForEach(0..<8) { row in
                ForEach(0..<8) { col in
                    Circle()
                        .fill(Color.blue.opacity(0.8))
                        .frame(width: 30, height: 30)
                        .offset(x: CGFloat(col) * 40 - 140 + (isAnimating && row % 2 == 0 ? offset : 0),
                               y: CGFloat(row) * 40 - 140)
                }
            }
        }
        .onChange(of: isAnimating) { newValue in
            withAnimation(newValue ?
                .linear(duration: 1.5).repeatForever(autoreverses: true) :
                .default) {
                offset = newValue ? 40 : 0
            }
        }
    }
}
