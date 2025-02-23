//
//  File.swift
//  Eye Care App
//
//  Created by Akhlak iSDP on 10/02/25.
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
    @State private var patternProgress: Double = 0
    
    private let animationSpeed: Double = 0.0010
    
    var body: some View {
            ScrollView(showsIndicators: false){
                GeometryReader { geometry in
                    VStack(spacing: 20) {
                        Text(timeString(from: viewModel.remainingTime))
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .monospacedDigit()
                        
                        HStack(spacing: 20) {
                            VStack {
                                HStack {
                                    Image(systemName: "eye")
                                        .foregroundColor(.accentBlue)
                                    Text("\(viewModel.exerciseBlinkCount)")
                                        .font(.system(size: 24, weight: .bold))
                                }
                                Text("Blinks")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.accentBlue.opacity(0.1))
                            .cornerRadius(12)
                            
                            VStack {
                                HStack {
                                    Image(systemName: "eye.trianglebadge.exclamationmark")
                                        .foregroundColor(.orange)
                                    Text("\(viewModel.exerciseTwitchCount)")
                                        .font(.system(size: 24, weight: .bold))
                                }
                                Text("Twitches")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            ForEach(GazePattern.allCases) { pattern in
                                PatternButton(pattern: pattern, isSelected: currentPattern == pattern) {
                                    currentPattern = pattern
                                    restartAnimation()
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        ZStack {
                            PatternGuideView(pattern: currentPattern)
                                .stroke(Color.accentBlue.opacity(0.2), lineWidth: 2)
                                .frame(width: min(geometry.size.width - 40, 300), height: min(geometry.size.width - 40, 300))
                            
                            TimelineView(.animation(minimumInterval: 0.001, paused: !isAnimating)) { timeline in
                                
                                Circle()
                                    .fill(RadialGradient(
                                        gradient: Gradient(colors: [.white, .accentBlue]),
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 15
                                    ))
                                    .frame(width: 30, height: 30)
                                    .shadow(color: .accentBlue.opacity(0.5), radius: 10)
                                    .position(calculateOrbPosition(in: CGSize(
                                        width: min(geometry.size.width - 40, 300),
                                        height: min(geometry.size.width - 40, 300)
                                    )))
                                    .onChange(of: timeline.date) { _ in
                                        if isAnimating {
                                            withAnimation(.linear(duration: 0.05)) {
                                                patternProgress += animationSpeed
                                                if patternProgress >= 1.0 {
                                                    patternProgress = 0
                                                }
                                            }
                                        }
                                    }
                            }
                        }
                        .frame(height: min(geometry.size.width - 40, 300))
                        .background(Color.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        
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
            isAnimating = true
            provideInitialGuidance()
        }
        .onDisappear {
            isAnimating = false
        }
    }
    
    private func restartAnimation() {
        patternProgress = 0
        isAnimating = true
    }
    
    private func stopExercise() {
        isAnimating = false
        synthesizer.stopSpeaking(at: .immediate)
        viewModel.stopExercise()
        dismiss()
    }
    
    private func calculateOrbPosition(in size: CGSize) -> CGPoint {
        let points = currentPattern.points
        let totalPoints = points.count
        let wrappedProgress = patternProgress.truncatingRemainder(dividingBy: 1.0)
        let progressIndex = wrappedProgress * Double(totalPoints - 1)
        let currentIndex = Int(floor(progressIndex))
        let nextIndex = (currentIndex + 1) % totalPoints
        let segmentProgress = progressIndex - Double(currentIndex)
        
        let currentPoint = points[currentIndex]
        let nextPoint = points[nextIndex]
        
        let x = currentPoint.x + (nextPoint.x - currentPoint.x) * CGFloat(segmentProgress)
        let y = currentPoint.y + (nextPoint.y - currentPoint.y) * CGFloat(segmentProgress)
        
        return CGPoint(
            x: size.width * (x + 1) / 2,
            y: size.height * (y + 1) / 2
        )
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

struct SessionCard: View {
    let session: ExerciseSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(formatDate(session.date))
                    .font(.headline)
                    .foregroundColor(Color.accentBlue)
                Spacer()
                Text(formatDuration(session.duration))
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 20) {
                StatItem(
                    icon: "eye",
                    count: session.blinkCount,
                    label: "Blinks",
                    color: .accentBlue
                )
                
                StatItem(
                    icon: "eye.trianglebadge.exclamationmark.fill",
                    count: session.twitchCount,
                    label: "Twitches",
                    color: .accentBlue.opacity(0.8)
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(
                    color: Color.accentBlue.opacity(0.08),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.accentBlue.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct StatItem: View {
    let icon: String
    let count: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text("\(count)")
                    .font(.system(.body, design: .rounded))
                    .bold()
                    .foregroundColor(color)
            }
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}
