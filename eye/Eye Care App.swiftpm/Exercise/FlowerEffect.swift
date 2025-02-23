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


struct FlowerEffectGuideView: View {
    @State private var showExercise = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                CardView(icon: "info.circle.fill", title: "Instructions") {
                    VStack(alignment: .leading, spacing: 12) {
                        InstructionRow(number: 1, text: "Sit comfortably and maintain good posture")
                        InstructionRow(number: 2, text: "Focus on the center of the expanding flower pattern")
                        InstructionRow(number: 3, text: "Breathe deeply and blink naturally")
                        InstructionRow(number: 4, text: "Stop if you feel any discomfort")
                    }
                }
                
                CardView(icon: "sparkles", title: "Exercise Pattern") {
                    VStack(spacing: 20) {
                        Image("flower")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .padding()
                        
                        Text("Watch as the pattern expands and contracts")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                CardView(icon: "checkmark.circle.fill", iconColor: .green, title: "Benefits") {
                    VStack(alignment: .leading, spacing: 8) {
                        BenefitRow(text: "Improves focus flexibility")
                        BenefitRow(text: "Enhances visual perception")
                        BenefitRow(text: "Reduces eye fatigue")
                        BenefitRow(text: "Promotes relaxation")
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Flower Effect")
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
            FlowerEffectView()
        }
    }
}

struct FlowerEffectView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var remainingTime: TimeInterval = 60
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0.0
    @State private var opacity: Double = 1.0
    @State private var isAnimating = false
    @State private var currentPhase = "Expanding"
    
    let synthesizer = AVSpeechSynthesizer()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
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
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [.blue.opacity(0.2), .clear]),
                                    center: .center,
                                    startRadius: 50,
                                    endRadius: 150
                                )
                            )
                            .frame(width: 300, height: 300)
                            .scaleEffect(scale)
                            .opacity(opacity)
                        
                        ForEach(0..<8) { index in
                            PetalShape()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.blue, .purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 100, height: 40)
                                .rotationEffect(.degrees(Double(index) * 45 + rotation))
                                .opacity(opacity)
                        }
                        .scaleEffect(scale)
                        
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [.white, .blue]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 15
                                )
                            )
                            .frame(width: 30, height: 30)
                            .shadow(color: .blue.opacity(0.5), radius: 5)
                    }
                    .frame(height: 300)
                    
                    Text(currentPhase)
                        .font(.title2.bold())
                        .foregroundColor(.blue)
                    
                    Spacer()

                    VStack(spacing: 8) {
                        Text("Focus on the center point")
                            .font(.headline)
                        Text("Breathe deeply as the pattern changes")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .safeAreaInset(edge: .bottom) {
                    Button(action: { stopExercise() }) {
                        Label("End Exercise", systemImage: "xmark.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(16)
                            .padding(.horizontal)
                            .background(.ultraThinMaterial)
                    }
                }
            }
        }
        .onAppear {
            startExercise()
        }
        .onReceive(timer) { _ in
            updateExercise()
        }
    }
    
    private func startExercise() {
        isAnimating = true
        startAnimation()
        speakInstruction("Focus on the center of the flower pattern. Breathe deeply as it changes.")
    }
    
    private func startAnimation() {
        guard isAnimating else { return }
        
        withAnimation(.easeInOut(duration: 4)) {
            scale = 1.5
            rotation = 45
            opacity = 0.7
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            guard isAnimating else { return }
            withAnimation(.easeInOut(duration: 4)) {
                scale = 1.0
                rotation = 0
                opacity = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                if isAnimating {
                    startAnimation()
                }
            }
        }
    }
    
    private func updateExercise() {
        if remainingTime > 0 {
            remainingTime -= 1
            currentPhase = scale > 1.2 ? "Expanding" : "Contracting"
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

struct PetalShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY),
            control: CGPoint(x: rect.maxX, y: 0)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        path.addQuadCurve(
            to: CGPoint(x: 0, y: rect.midY),
            control: CGPoint(x: 0, y: rect.maxY)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: 0),
            control: CGPoint(x: 0, y: 0)
        )
        
        return path
    }
}
