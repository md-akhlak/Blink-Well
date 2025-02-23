//
//  File.swift
//  Eye Care App
//
//  Created by Akhlak iSDP on 22/02/25.
//

import Foundation
import SwiftUI
import AVFoundation
import ARKit

struct ExerciseContentView: View {
    @ObservedObject var viewModel: EyeTrackingViewModel
    @Binding var targetPosition: CGPoint
    @Binding var isAnimating: Bool
    let synthesizer: AVSpeechSynthesizer
    @Environment(\.dismiss) private var dismiss
    @State private var currentPattern: GazePattern = .square
    @State private var animationTimer: Timer?
    @State private var patternProgress: Double = 0
    
    private let animationSpeed: Double = 0.0005
    
    var body: some View {
            ScrollView(showsIndicators: false){
                GeometryReader { geometry in
                    VStack(spacing: 20) {
                        // Timer Display
                        Text(timeString(from: viewModel.remainingTime))
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .monospacedDigit()
                        
                        // Pattern Selection
                        HStack(spacing: 12) {
                            ForEach(GazePattern.allCases) { pattern in
                                PatternButton(pattern: pattern, isSelected: currentPattern == pattern) {
                                    currentPattern = pattern
                                    restartAnimation()
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Exercise Area
                        ZStack {
                            // Pattern Guide
                            PatternGuideView(pattern: currentPattern)
                                .stroke(Color.blue.opacity(0.2), lineWidth: 2)
                                .frame(width: min(geometry.size.width - 40, 300), height: min(geometry.size.width - 40, 300))
                            
                            // Moving Orb
                            Circle()
                                .fill(RadialGradient(
                                    gradient: Gradient(colors: [.white, .blue]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 20
                                ))
                                .frame(width: 25, height: 25)
                                .shadow(color: .blue.opacity(0.5), radius: 10)
                                .position(calculateOrbPosition(in: CGSize(
                                    width: min(geometry.size.width - 40, 300),
                                    height: min(geometry.size.width - 40, 300)
                                )))
                        }
                        .frame(height: min(geometry.size.width - 40, 300))
                        .background(Color.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                        // Stop Button
                        Button(action: stopExercise) {
                            Label("Stop Exercise", systemImage: "xmark.circle.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                }
                
        }
        .onAppear {
            startAnimation()
            provideInitialGuidance()
        }
        .onDisappear {
            stopAnimation()
        }
    }
    
    private func startAnimation() {
            animationTimer?.invalidate()
            animationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
                Task { @MainActor in
                    withAnimation(.linear(duration: 0.016)) {
                        self.patternProgress += animationSpeed
                        if self.patternProgress >= 1.0 {
                            self.patternProgress = 0
                        }
                    }
                }
            }
        }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func restartAnimation() {
        patternProgress = 0
        startAnimation()
    }
    
    private func calculateOrbPosition(in size: CGSize) -> CGPoint {
        let points = currentPattern.points
        let totalPoints = points.count
        
        let progressIndex = patternProgress * Double(totalPoints - 1)
        let currentIndex = Int(floor(progressIndex))
        let nextIndex = min(currentIndex + 1, totalPoints - 1)
        let interpolation = progressIndex - Double(currentIndex)
        
        let currentPoint = points[currentIndex]
        let nextPoint = points[nextIndex]
        
        let x = currentPoint.x + (nextPoint.x - currentPoint.x) * CGFloat(interpolation)
        let y = currentPoint.y + (nextPoint.y - currentPoint.y) * CGFloat(interpolation)
        
        // Convert normalized coordinates (-1 to 1) to view coordinates
        return CGPoint(
            x: size.width * (x + 1) / 2,
            y: size.height * (y + 1) / 2
        )
    }
    
    private func stopExercise() {
        // Stop animations and audio
        stopAnimation()
        synthesizer.stopSpeaking(at: .immediate)
        
        // Save the exercise session
        viewModel.stopExercise()
        
        // Dismiss the exercise view
        dismiss()
    }
    
    private func provideInitialGuidance() {
        let utterance = AVSpeechUtterance(string: "Eye tracking exercise. Follow the glowing orb with your eyes only.")
        utterance.rate = 0.5
        utterance.volume = 0.8
        synthesizer.speak(utterance)
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
