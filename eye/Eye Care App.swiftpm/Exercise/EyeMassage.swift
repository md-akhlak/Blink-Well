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

struct EyeMassageGuideView: View {
    @State private var showExercise = false
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    CardView(icon: "info.circle.fill", title: "Instructions") {
                        VStack(alignment: .leading, spacing: 12) {
                            InstructionRow(number: 1, text: "Wash your hands thoroughly before starting")
                            InstructionRow(number: 2, text: "Use gentle, circular motions with your fingertips")
                            InstructionRow(number: 3, text: "Apply light pressure - avoid pressing too hard")
                            InstructionRow(number: 4, text: "Follow the guided massage positions")
                        }
                    }
                    CardView(icon: "eyebrow", title: "Massage Pattern") {
                        VStack(spacing: 20) {
                            Image("eyemassage")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 120)
                                .padding()
                            
                            Text("Massage in gentle circular motions")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    CardView(icon: "checkmark.circle.fill", iconColor: .green, title: "Benefits") {
                        VStack(alignment: .leading, spacing: 8) {
                            BenefitRow(text: "Relieves eye strain and tension")
                            BenefitRow(text: "Improves blood circulation")
                            BenefitRow(text: "Reduces eye fatigue")
                            BenefitRow(text: "Helps relax eye muscles")
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Eye Massage")
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
                EyeMassageView()
            }
        }
    }
}

struct EyeMassageView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var remainingTime: TimeInterval = 53
    @State private var currentStep = 0
    @State private var handPosition = CGPoint(x: 0, y: 0)
    @State private var handRotation = 0.0
    @State private var isAnimating = false
    
    let synthesizer = AVSpeechSynthesizer()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let massageSteps = [
        ("Massage temples gently", CGPoint(x: -60, y: 0), 15.0),
        ("Massage above eyebrows", CGPoint(x: 0, y: -20), -15.0),
        ("Massage under eyes", CGPoint(x: 0, y: 20), 15.0),
        ("Massage bridge of nose", CGPoint(x: 0, y: 0), 0.0)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
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
                    .padding(.horizontal)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.accentBlue.opacity(0.1))
                            .frame(height: 300)
                        
                        ZStack {
                            Image("eyemassage")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 250, height: 250)
                            
                        }
                        .frame(height: 250)
                    }
                    .padding(.horizontal)
                    
                    HStack(spacing: 8) {
                        ForEach(0..<massageSteps.count) { index in
                            Circle()
                                .fill(currentStep == index ? Color.accentBlue : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: { stopExercise() }) {
                        Label("End Exercise", systemImage: "xmark.circle.fill")
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
        .navigationTitle("Eye Massage")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func startExercise() {
        isAnimating = true
        updateHandPosition()
        
        let utterance = AVSpeechUtterance(string: "Eye massage exercise")
        utterance.rate = 0.5
        utterance.volume = 0.8
        synthesizer.speak(utterance)
    }
    
    private func updateExercise() {
        if remainingTime > 0 {
            remainingTime -= 1
            if remainingTime.truncatingRemainder(dividingBy: 15) == 0 {
                currentStep = (currentStep + 1) % massageSteps.count
                updateHandPosition()
                
                let utterance = AVSpeechUtterance(string: massageSteps[currentStep].0)
                utterance.rate = 0.5
                utterance.volume = 0.8
                synthesizer.speak(utterance)
            }
            
        } else {
            stopExercise()
        }
    }
    
    private func updateHandPosition() {
        handPosition = massageSteps[currentStep].1
        handRotation = massageSteps[currentStep].2
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

