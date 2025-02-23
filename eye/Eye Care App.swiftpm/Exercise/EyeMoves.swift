//
//  File.swift
//  Eye Care App
//
//  Created by Akhlak iSDP on 10/02/25.
//

import Foundation
import SwiftUI
import ARKit
import AVFoundation


enum RollingPattern {
    case circular
    case infinity
    
    var name: String {
        switch self {
        case .circular: return "Circular"
        case .infinity: return "Infinity"
        }
    }
}

struct EyeRollingGuideView: View {
    @State private var showExercise = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                CardView(icon: "info.circle.fill", title: "Instructions") {
                    VStack(alignment: .leading, spacing: 8) {
                        InstructionRow(number: 1, text: "Keep your head still throughout the exercise")
                        InstructionRow(number: 3, text: "Follow the moving dot only with your eyes")
                        InstructionRow(number: 3, text: "Blink naturally when needed")
                    }
                }
                CardView(icon: "eyes", title: "Exercise Patterns") {
                    VStack(spacing: 20) {
                        PatternRow(
                            title: "Circular",
                            description: "Smooth circular movement",
                            duration: "20 seconds"
                        )
                        
                        PatternRow(
                            title: "Figure Eight",
                            description: "Flowing infinity pattern",
                            duration: "20 seconds"
                        )
                    }
                }
                
                CardView(icon: "checkmark.circle.fill", iconColor: .green, title: "Benefits") {
                    VStack(alignment: .leading, spacing: 8) {
                        BenefitRow(text: "Strengthens eye muscles")
                        BenefitRow(text: "Improves eye coordination")
                        BenefitRow(text: "Reduces eye strain")
                        BenefitRow(text: "Enhances focus flexibility")
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Eye Moves")
        .navigationBarTitleDisplayMode(.large)
        .safeAreaInset(edge: .bottom) {
            Button(action: { showExercise = true }) {
                Text("Start Exercise")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentBlue)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    .background(.ultraThinMaterial)
            }
        }
        .fullScreenCover(isPresented: $showExercise) {
            EyeRollingView()
        }

    }
}

struct PatternRow: View {
    let title: String
    let description: String
    let duration: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(duration)
                .font(.caption)
                .padding(8)
                .background(Color.accentBlue.opacity(0.1))
                .clipShape(Capsule())
        }
    }
}

struct EyeRollingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var remainingTime: TimeInterval = 40
    @State private var currentDirection = "Clockwise"
    @State private var rotationAngle: Double = 0
    @State private var isExerciseActive = false
    @State private var currentPattern: RollingPattern = .circular
    @State private var patternPosition: CGPoint = .zero
    
    let synthesizer = AVSpeechSynthesizer()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let animationTimer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect() // ~60fps
    
    var body: some View {

            GeometryReader { geometry in
                ZStack {
                    Color(.systemBackground).ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        VStack(spacing: 8) {
                            Text(timeString(from: remainingTime))
                                .font(.system(size: 60, weight: .bold))
                                .monospacedDigit()
                                .foregroundColor(.blue)
                            
                            Text("Remaining Time")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.accentBlue.opacity(0.1))
                        .cornerRadius(20)
                        .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            Text(currentPattern.name)
                                .font(.title2.bold())
                                .foregroundColor(.accentBlue)
                            
                            Text(currentDirection)
                                .font(.title3)
                                .foregroundColor(.accentBlue.opacity(0.8))
                        }
                        
                        ZStack {
                            getGuidePath()
                                .stroke(Color.green.opacity(0.2), lineWidth: 2)
                                .frame(width: 200, height: 200)
                            
                            ZStack {
                                Circle()
                                    .fill(Color.green.opacity(0.1))
                                    .frame(width: 30, height: 30)
                                    .blur(radius: 2)
                                
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 20, height: 20)
                            }
                            .offset(x: patternPosition.x, y: patternPosition.y)
                        }
                        .frame(height: 300)
                        
                        Spacer()
                        
                        VStack(spacing: 16) {
                            VStack(spacing: 8) {
                                Text("Follow the green dot with your eyes")
                                    .font(.headline)
                                Text("Keep your head still")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.accentBlue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            Button(action: { stopExercise() }) {
                                HStack {
                                    Image(systemName: "stop.circle.fill")
                                    Text("Stop Exercise")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.red)
                                .cornerRadius(15)
                            }
                            
                            HStack(spacing: 8) {
                                ForEach(0..<3) { index in
                                    Circle()
                                        .fill(getCurrentPatternIndex() == index ? Color.accentBlue : Color.gray.opacity(0.3))
                                        .frame(width: 8, height: 8)
                                }
                            
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Eye Rolling")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        stopExercise()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.accentBlue)
                    }
                }
            }
        }
        .onAppear {
            startExercise()
        }
        .onReceive(timer) { _ in
            if isExerciseActive {
                updateExercise()
            }
        }
        .onReceive(animationTimer) { _ in
            if isExerciseActive {
                updateDotPosition()
            }
        }
    }
    
    private func startExercise() {
        isExerciseActive = true
        remainingTime = 40
        rotationAngle = 0
        currentPattern = .circular
        
        speakInstruction("Starting with circular pattern. Follow the green dot with your eyes.")
    }
    
    private func updateExercise() {
        if remainingTime > 0 {
            remainingTime -= 1
            if remainingTime == 20 {
                currentPattern = .infinity
                speakInstruction("Changing to infinity pattern")
            }
            
            if remainingTime == 30 || remainingTime == 10 {
                currentDirection = "Counterclockwise"
                speakInstruction("Change direction")
            }
        } else {
            stopExercise()
        }
    }
    
    
    
    private func speakInstruction(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.5
        utterance.volume = 0.8
        synthesizer.speak(utterance)
    }
    
    private func stopExercise() {
        isExerciseActive = false
        synthesizer.stopSpeaking(at: .immediate)
        dismiss()
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    
    private func updateDotPosition() {
        let t = rotationAngle * .pi / 180
        let radius: CGFloat = 100
        
        switch currentPattern {
        case .circular:
            patternPosition = CGPoint(
                x: cos(t) * radius,
                y: sin(t) * radius
            )
            
        case .infinity:
            let width: CGFloat = 200
            let _: CGFloat = 80
            let normalizedT = t.truncatingRemainder(dividingBy: 2 * .pi) / (2 * .pi)
            let a = width / 2
            let angle = normalizedT * 2 * .pi
            let denominator = 1 + sin(angle) * sin(angle)
            
            patternPosition = CGPoint(
                x: a * cos(angle) / denominator,
                y: a * sin(angle) * cos(angle) / denominator
            )
            
        }
        
        rotationAngle += currentDirection == "Clockwise" ? 2 : -2
    }

    private func lerp(start: CGFloat, end: CGFloat, t: CGFloat) -> CGFloat {
        return start + (end - start) * t
    }

    private func getGuidePath() -> Path {
        switch currentPattern {
        case .circular:
            return Path { path in
                
            }
        case .infinity:
            return Path { path in
                
            }
        }
    }
    
    private func getCurrentPatternIndex() -> Int {
        switch currentPattern {
        case .circular: return 0
        case .infinity: return 1
        }
    }
}
