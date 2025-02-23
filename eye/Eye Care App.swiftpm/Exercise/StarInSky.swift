//
//  File.swift
//  Eye Care App
//
//  Created by Akhlak iSDP on 22/02/25.
//

import Foundation
import SwiftUI
import ARKit
import AVFoundation


struct StarInSkyGuideView: View {
    @State private var showExercise = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Instructions Section
                CardView(icon: "info.circle.fill", title: "Instructions") {
                    VStack(alignment: .leading, spacing: 12) {
                        InstructionRow(number: 1, text: "Find a comfortable position near a window")
                        InstructionRow(number: 2, text: "Look at a distant star or point in the sky")
                        InstructionRow(number: 3, text: "Keep your head still and maintain focus")
                        InstructionRow(number: 4, text: "Blink naturally when needed")
                    }
                }
                
                // Illustration Section
                CardView(icon: "moon.stars", title: "Exercise Pattern") {
                    VStack(spacing: 20) {
                        Image("star") // Star exercise image from assets
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .padding()
                        
                        Text("Focus on a distant point to relax eye muscles")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                // Benefits Section
                CardView(icon: "checkmark.circle.fill", iconColor: .green, title: "Benefits") {
                    VStack(alignment: .leading, spacing: 8) {
                        BenefitRow(text: "Improves distance vision")
                        BenefitRow(text: "Relaxes eye muscles")
                        BenefitRow(text: "Reduces myopia progression")
                        BenefitRow(text: "Enhances night vision adaptation")
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Star in Sky")
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
            StarInSkyView()
        }
    }
}

struct StarInSkyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var remainingTime: TimeInterval = 30 // 2 minutes exercise
    @State private var starOpacity: Double = 0.0
    @State private var starScale: CGFloat = 1.0
    @State private var isAnimating = false
    @State private var currentPhase = "Focus on the star"
    
    let synthesizer = AVSpeechSynthesizer()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Night sky background
                Color.black.ignoresSafeArea()
                
                // Stars background
                ForEach(0..<50) { index in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 2, height: 2)
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .opacity(0.3)
                }
                
                VStack(spacing: 30) {
                    // Timer Display
                    VStack(spacing: 8) {
                        Text(timeString(from: remainingTime))
                            .font(.system(size: 60, weight: .bold))
                            .monospacedDigit()
                            .foregroundColor(.white)
                        
                        Text("Remaining Time")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    // Exercise Area
                    ZStack {
                        // Main focus star
                        Image(systemName: "star.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.yellow)
                            .opacity(starOpacity)
                            .scaleEffect(starScale)
                            .shadow(color: .yellow.opacity(0.5), radius: 10)
                        
                        // Glow effect
                        ForEach(0..<3) { i in
                            Image(systemName: "star.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40 + CGFloat(i * 10), height: 40 + CGFloat(i * 10))
                                .foregroundColor(.yellow)
                                .opacity(starOpacity * 0.3 / Double(i + 1))
                                .scaleEffect(starScale)
                                .blur(radius: CGFloat(i * 2))
                        }
                    }
                    .frame(height: 280)
                    
                    // Current Phase
                    Text(currentPhase)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Instructions
                    VStack(spacing: 8) {
                        Text("Keep your gaze steady")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Blink naturally when needed")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Stop Button
                    Button(action: { stopExercise() }) {
                        Label("End Exercise", systemImage: "xmark.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(16)
                            .padding(.horizontal)
                    }
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
    }
    
    private func startExercise() {
        isAnimating = true
        startStarAnimation()
        speakInstruction("Focus on the distant star. Keep your head still and maintain steady gaze.")
    }
    
    private func startStarAnimation() {
        guard isAnimating else { return }
        
        // Fade in
        withAnimation(.easeIn(duration: 2)) {
            starOpacity = 1.0
            starScale = 1.2
        }
        
        // Subtle pulsing animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            guard isAnimating else { return }
            withAnimation(.easeInOut(duration: 3).repeatForever()) {
                starScale = 1.0
            }
        }
    }
    
    private func updateExercise() {
        if remainingTime > 0 {
            remainingTime -= 1
            
            // Update instructions periodically
            if remainingTime.truncatingRemainder(dividingBy: 30) == 0 {
                speakInstruction("Keep focusing on the star. Blink if needed.")
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



