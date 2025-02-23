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

struct BlinkingGuideView: View {
    @State private var showExercise = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                CardView(icon: "eye.fill", title: "Instructions") {
                    VStack(alignment: .leading, spacing: 8) {
                        InstructionRow(number: 1, text: "Blink naturally for 20 seconds")
                        InstructionRow(number: 3, text: "Perform quick blinks for 20 seconds")
                        InstructionRow(number: 3, text: "Do slow, complete blinks for 20 seconds")
                    }
                }
                
                CardView(icon: "eye", title: "How to Blink") {
                    HStack(alignment: .center, spacing: 20) {
                        
                        VStack(spacing: 8) {
                            Image(systemName: "eye")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 60)
                            Text("Step 1")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            Text("Natural blinks")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 8) {
                            Image(systemName: "eye.slash")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 60)
                            Text("Step 2")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            Text("Complete closure")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                CardView(icon: "checkmark.circle.fill", iconColor: .green, title: "Benefits") {
                    VStack(alignment: .leading, spacing: 8) {
                        BenefitRow(text: "Reduces digital eye strain")
                        BenefitRow(text: "Maintains eye moisture")
                        BenefitRow(text: "Prevents dry eyes")
                        BenefitRow(text: "Improves focus")
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Blinking")
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
            EyeBlinkingView()
        }
    }
}

struct EyeBlinkingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var remainingTime: TimeInterval = 60
    @State private var currentPhase: BlinkPhase = .natural
    @State private var eyesOpen = true
    @State private var isExerciseActive = true
    
    enum BlinkPhase: String {
        case natural = "Natural Blinks"
        case quick = "Quick Blinks"
        case slow = "Slow Blinks"
        
        var instruction: String {
            switch self {
            case .natural: return "Open and close your eyes naturally"
            case .quick: return "Quick blinks - Open and close rapidly"
            case .slow: return "Slow blinks - Hold eyes closed for 2 seconds"
            }
        }
        
        var duration: Double {
            switch self {
            case .natural: return 3.0
            case .quick: return 1.0
            case .slow: return 4.0
            }
        }
    }
    
    let synthesizer = AVSpeechSynthesizer()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                VStack(spacing: 24) {
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
                    
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: geometry.size.width * 0.8)
                        
                        HStack(spacing: geometry.size.width * 0.15) {
                            EyeShape(isOpen: eyesOpen)
                                .frame(width: geometry.size.width * 0.2)
                            EyeShape(isOpen: eyesOpen)
                                .frame(width: geometry.size.width * 0.2)
                        }
                    }
                    
                    .frame(height: geometry.size.height * 0.4)
                    VStack(spacing: 12) {
                        Text(currentPhase.rawValue)
                            .font(.title2.bold())
                            .foregroundColor(.blue)
                        
                        Text(eyesOpen ? "Open your eyes" : "Close your eyes")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .animation(nil, value: eyesOpen)
                        
                        Text(currentPhase.instruction)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(16)
                    
                    Spacer()
                    
                    Button(action: stopExercise) {
                        Label("End Exercise", systemImage: "xmark.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(16)
                    }
                }
                .padding(24)
            }
        }
        .onAppear(perform: startExercise)
        .onReceive(timer) { _ in
            if isExerciseActive {
                updateExercise()
            }
        }
        .onDisappear {
            cleanupExercise()
        }
    }
    
    private func startExercise() {
        isExerciseActive = true
        speakInstruction("Starting eye exercise. Keep your head still and follow the instructions.")
        startBlinkSequence()
    }
    
    private func startBlinkSequence() {
        guard isExerciseActive else { return }
        
        switch currentPhase {
        case .natural:
            withAnimation(.easeInOut(duration: 0.5)) {
                eyesOpen.toggle()
            }
            if isExerciseActive {
                speakInstruction(eyesOpen ? "Open your eyes" : "Close your eyes")
            }
            if isExerciseActive {
                DispatchQueue.main.asyncAfter(deadline: .now() + currentPhase.duration) {
                    if isExerciseActive {
                        startBlinkSequence()
                    }
                }
            }
        case .quick:
            withAnimation(.easeInOut(duration: 0.3)) {
                eyesOpen.toggle()
            }
            if isExerciseActive {
                speakInstruction(eyesOpen ? "Open" : "Close")
            }
            if isExerciseActive {
                DispatchQueue.main.asyncAfter(deadline: .now() + currentPhase.duration) {
                    if isExerciseActive {
                        startBlinkSequence()
                    }
                }
            }
        case .slow:
            withAnimation(.easeInOut(duration: 0.5)) {
                eyesOpen.toggle()
            }
            if isExerciseActive {
                speakInstruction(eyesOpen ? "Slowly open your eyes" : "Slowly close and hold")
            }
            if isExerciseActive {
                DispatchQueue.main.asyncAfter(deadline: .now() + currentPhase.duration) {
                    if isExerciseActive {
                        startBlinkSequence()
                    }
                }
            }
        }
    }
    
    private func updateExercise() {
        guard isExerciseActive else { return }
        
        if remainingTime > 0 {
            remainingTime -= 1
            
            if remainingTime == 40 {
                currentPhase = .quick
                if isExerciseActive {
                    speakInstruction("Now we'll do quick blinks")
                }
            } else if remainingTime == 20 {
                currentPhase = .slow
                if isExerciseActive {
                    speakInstruction("Now we'll do slow blinks")
                }
            } else if remainingTime == 0 {
                completeExercise()
            }
        }
    }
    
    private func stopExercise() {
        cleanupExercise()
        
        let utterance = AVSpeechUtterance(string: "Exercise stopped")
        utterance.rate = 0.5
        utterance.volume = 0.8
        synthesizer.speak(utterance)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            dismiss()
        }
    }
    
    private func completeExercise() {
        cleanupExercise()
        
        let utterance = AVSpeechUtterance(string: "Exercise complete. Good job!")
        utterance.rate = 0.5
        utterance.volume = 0.8
        synthesizer.speak(utterance)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            dismiss()
        }
    }
    
    private func cleanupExercise() {
        isExerciseActive = false
        synthesizer.stopSpeaking(at: .immediate)
        
        withAnimation(.easeInOut(duration: 0.3)) {
            eyesOpen = true
        }
    }
    
    private func speakInstruction(_ text: String) {
        guard isExerciseActive else { return }
        
        let utterance = AVSpeechUtterance(string: text)
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

struct EyeShape: View {
    let isOpen: Bool
    
    var body: some View {
        ZStack {
            if isOpen {
                ZStack {
                    Capsule()
                        .fill(Color.white)
                        .frame(width: 20, height: 30)
                        .shadow(color: .black.opacity(0.1), radius: 2, y: 2)
                    
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 20, height: 20)
                    
                    Circle()
                        .fill(Color.black)
                        .frame(width: 10, height: 10)
                }
            } else {
                Capsule()
                    .fill(Color.white)
                    .frame(height: 2)
                    .shadow(color: .black.opacity(0.1), radius: 2, y: 2)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isOpen)
    }
}
