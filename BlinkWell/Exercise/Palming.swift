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

struct EyePalmingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var remainingTime: TimeInterval = 30
    @State private var isAnimating = false
    @State private var showHeatWaves = false
    @State private var currentPhase: ExercisePhase = .rubbing
    @State private var handPosition: CGSize = .zero
    @State private var handOpacity: Double = 1.0
    
    enum ExercisePhase {
        case rubbing
        case covering
        
        var instruction: String {
            switch self {
            case .rubbing:
                return "Rub your palms together"
            case .covering:
                return "Cover your eyes with palms for twenty to thirty seconds"
            }
        }
    }
    
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
                            .foregroundColor(.accentBlue)
                        
                        Text("Remaining Time")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.accentBlue.opacity(0.1))
                    .cornerRadius(20)
                    
                    ZStack {
                        if currentPhase == .rubbing {
                            HStack(spacing: -20) {
                                Image(systemName: "hand.raised.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100)
                                    .foregroundColor(.orange)
                                    .rotationEffect(.degrees(isAnimating ? -10 : 10))
                                    .offset(x: isAnimating ? -5 : 5)
                                
                                Image(systemName: "hand.raised.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100)
                                    .foregroundColor(.orange)
                                    .rotationEffect(.degrees(isAnimating ? 10 : -10))
                                    .offset(x: isAnimating ? 5 : -5)
                            }
                            .overlay {
                                if showHeatWaves {
                                    ForEach(0..<3) { index in
                                        Circle()
                                            .stroke(Color.orange.opacity(0.5), lineWidth: 2)
                                            .frame(width: 40 + CGFloat(index * 20))
                                            .scaleEffect(isAnimating ? 1.5 : 1)
                                            .opacity(isAnimating ? 0 : 1)
                                    }
                                }
                            }
                        } else {
                            ZStack {
                                Image("placeovereyes")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 250, height: 250)
                                
                                
                                .offset(y: isAnimating ? -3 : 0)
                                .animation(
                                    .easeInOut(duration: 2)
                                    .repeatForever(autoreverses: true),
                                    value: isAnimating
                                )
                                
                                ZStack {
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                gradient: Gradient(colors: [
                                                    .orange.opacity(0.3),
                                                    .clear
                                                ]),
                                                center: .center,
                                                startRadius: 0,
                                                endRadius: 70
                                            )
                                        )
                                        .frame(width: 140, height: 140)
                                        .offset(y: -45)
                                    
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                gradient: Gradient(colors: [
                                                    .orange.opacity(0.1),
                                                    .clear
                                                ]),
                                                center: .center,
                                                startRadius: 30,
                                                endRadius: 90
                                            )
                                        )
                                        .frame(width: 180, height: 180)
                                        .offset(y: -45)
                                }
                                .opacity(isAnimating ? 0.8 : 0.4)
                                .animation(
                                    .easeInOut(duration: 1.5)
                                    .repeatForever(autoreverses: true),
                                    value: isAnimating
                                )
                            }
                        }
                    }
                    .frame(height: 250)
                    .animation(.easeInOut(duration: 0.5), value: currentPhase)
                    
                    Text(currentPhase.instruction)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.accentBlue)
                        .multilineTextAlignment(.center)
                        .padding()
                        .animation(.easeInOut, value: currentPhase)
                    
                    Spacer()
                    
                    // Stop Button
                    Button(action: { stopExercise() }) {
                        Label("End Exercise", systemImage: "xmark.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.red.gradient)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
                .padding(24)
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
        showHeatWaves = true
        withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
            isAnimating = true
        }
        speakInstruction(currentPhase.instruction)
    }
    
    private func updateExercise() {
        if remainingTime > 0 {
            remainingTime -= 1
            if remainingTime == 15 {
                withAnimation {
                    currentPhase = .covering
                    showHeatWaves = false
                }
                speakInstruction(currentPhase.instruction)
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
        synthesizer.stopSpeaking(at: .immediate)
        dismiss()
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct ExerciseView: View {
    @ObservedObject var viewModel: EyeTrackingViewModel
    @State private var targetPosition = CGPoint.zero
    @State private var isAnimating = false
    let synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        ExerciseContentView(
            viewModel: viewModel,
            targetPosition: $targetPosition,
            isAnimating: $isAnimating,
            synthesizer: synthesizer
        )
        .overlay {
            if viewModel.showEyeStrainWarning {
                EyeStrainWarningOverlay(viewModel: viewModel)
            }
        }
    }
    
}
    
struct WarningView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "eye.trianglebadge.exclamationmark")
                .foregroundColor(.red)
            
            Text("Do not press eyes while keeping palm on eyes and face")
                .font(.subheadline)
                .foregroundColor(.red)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
}
    
struct PalmingGuideView: View {
    @State private var showExercise = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                CardView(icon: "info.circle.fill", title: "Instructions") {
                    VStack(alignment: .leading, spacing: 8) {
                        InstructionRow(number: 1, text: "Cover your closed eyes with your palms after rubbing them.")
                        InstructionRow(number: 2, text: "Palm daily.")
                        InstructionRow(number: 3, text: "Make it a life-long habit.")
                        
                        WarningView()
                    }
                }
                
                CardView(icon: "hand.raised.fill", title: "How to Palm") {
                    HStack(alignment:.center, spacing: 20) {
                        VStack(spacing: 8) {
                            Image("rubbing")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                            Text("Step 1")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            Text("Rub your palms")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 8) {
                            Image("placeovereyes")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                            Text("Step 2")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            Text("Cover your eyes")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                VStack(alignment: .leading, spacing: 8){
                    CardView(icon: "checkmark.circle.fill", iconColor: .green, title: "Benefits") {
                        VStack(alignment: .leading, spacing: 8) {
                            BenefitRow(text: "Calms the mind")
                            BenefitRow(text: "Reduces anxiety")
                            BenefitRow(text: "Relaxes eyestrain")
                            BenefitRow(text: "Improves vision")
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Palming")
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
            EyePalmingView()
        }
    }
}
    

