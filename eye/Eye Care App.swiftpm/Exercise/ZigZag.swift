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


struct ZigZagGuideView: View {
    @State private var showExercise = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                CardView(icon: "info.circle.fill", title: "Instructions") {
                    VStack(alignment: .leading, spacing: 12) {
                        InstructionRow(number: 1, text: "Don't move your head while focusing on moving object.")
                        InstructionRow(number: 2, text: "Take off the glasses.")
                        InstructionRow(number: 3, text: "Do not stare, You must blink and breath during exercise.")
                        InstructionRow(number: 4, text: "Stop exercise if you are feeling strain and repeat again after sometime.")
                    }
                }
                CardView(icon: "zigzag", title: "Exercise Pattern") {
                    VStack(spacing: 20) {
                        Image("zigzag")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .padding()
                        
                        Text("Follow the moving dot with your eyes only")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                CardView(icon: "checkmark.circle.fill", iconColor: .green, title: "Benefits") {
                    VStack(alignment: .leading, spacing: 8) {
                        BenefitRow(text: "Improves eye movement control")
                        BenefitRow(text: "Strengthens eye muscles")
                        BenefitRow(text: "Enhances focus and concentration")
                        BenefitRow(text: "Reduces eye strain")
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Zig-Zag")
        .navigationBarTitleDisplayMode(.large)
        .safeAreaInset(edge: .bottom) {
            Button(action: { showExercise = true }) {
                Text("Start Exercise")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    .background(.ultraThinMaterial)
            }
        }
        .fullScreenCover(isPresented: $showExercise) {
            ZigZagExerciseView()
        }
    }
}


struct ZigZagExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var remainingTime: TimeInterval = 60
    @State private var dotPosition: CGPoint = .zero
    @State private var isAnimating = false
    @State private var currentDirection = "Left to Right"
    @State private var animationProgress: CGFloat = 0
    

    let synthesizer = AVSpeechSynthesizer()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let animationTimer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    let zigzagPoints: [CGPoint] = [
        CGPoint(x: 0, y: 0),
        CGPoint(x: 0.25, y: 1),
        CGPoint(x: 0.5, y: 0),
        CGPoint(x: 0.75, y: 1),
        CGPoint(x: 1, y: 0)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                VStack(spacing: 30) {
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
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    ZStack {
                        Path { path in
                            let width: CGFloat = geometry.size.width - 80.0
                            let height: CGFloat = 200.0
                            
                            path.move(to: CGPoint(x: CGFloat(40), y: height/2.0))
                            
                            for point in zigzagPoints {
                                let xPos: CGFloat = CGFloat(40) + (CGFloat(point.x) * width)
                                let yPos: CGFloat = (height/2.0) + (CGFloat(point.y) - 0.5) * (height/2.0)
                                path.addLine(to: CGPoint(x: xPos, y: yPos))
                            }
                        }
                        .stroke(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5]))
                        
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [.white, .blue]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 10
                                )
                            )
                            .frame(width: 20, height: 20)
                            .shadow(color: .blue.opacity(0.5), radius: 5)
                            .position(calculateDotPosition(in: geometry.size))
                    }
                    .frame(height: 200)
                    .padding()
                    
                    Text(currentDirection)
                        .font(.title3)
                        .foregroundColor(.blue)
                        .padding(.vertical)
                    
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Text("Keep your head still")
                            .font(.headline)
                        Text("Follow the blue dot with your eyes only")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Button(action: { stopExercise() }) {
                        Label("Stop Exercise", systemImage: "xmark.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.red)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            startExercise()
        }
        .onReceive(timer) { _ in
            updateExercise()
        }
        .onReceive(animationTimer) { _ in
            updateDotPosition()
        }
    }
    
    private func startExercise() {
        isAnimating = true
        animationProgress = 0
        speakInstruction("Follow the blue dot with your eyes. Keep your head still.")
    }
    
    private func updateDotPosition() {
        if isAnimating {
            let progressIncrement: CGFloat = 0.005
            if remainingTime > 30 {
                animationProgress += progressIncrement
                if animationProgress >= 1 {
                    animationProgress = 0
                }
            } else {
                animationProgress += progressIncrement
                if animationProgress >= 1 {
                    animationProgress = 0
                }
            }
        }
    }

    private func calculateDotPosition(in size: CGSize) -> CGPoint {
        let width: CGFloat = size.width - 80.0
        let height: CGFloat = 200.0
        
        let totalPoints: CGFloat = CGFloat(zigzagPoints.count - 1)
        let segmentProgress: CGFloat = animationProgress * totalPoints
        let currentIndex = Int(floor(segmentProgress))
        let nextIndex = min(currentIndex + 1, zigzagPoints.count - 1)
        let segmentT: CGFloat = segmentProgress - CGFloat(currentIndex)
        
        let currentPoint = zigzagPoints[currentIndex]
        let nextPoint = zigzagPoints[nextIndex]
        
        let xPos: CGFloat
        let yPos: CGFloat
        
        if remainingTime > 30 {
            xPos = CGFloat(40) + (lerp(
                start: CGFloat(currentPoint.x),
                end: CGFloat(nextPoint.x),
                t: segmentT
            ) * width)
        } else {
            xPos = CGFloat(40) + ((1 - lerp(
                start: CGFloat(currentPoint.x),
                end: CGFloat(nextPoint.x),
                t: segmentT
            )) * width)
        }
        
        yPos = (height/2.0) + (lerp(
            start: CGFloat(currentPoint.y),
            end: CGFloat(nextPoint.y),
            t: segmentT
        ) - 0.5) * (height/2.0)
        
        return CGPoint(x: xPos, y: yPos)
    }

    private func lerp(start: CGFloat, end: CGFloat, t: CGFloat) -> CGFloat {
        return start + ((end - start) * t)
    }
    
    private func updateExercise() {
        if remainingTime > 0 {
            remainingTime -= 1
            
            if remainingTime == 30 {
                currentDirection = "Right to Left"
                speakInstruction("Change direction: Right to Left")
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
        isAnimating = false
        synthesizer.stopSpeaking(at: .immediate)
        dismiss()
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
