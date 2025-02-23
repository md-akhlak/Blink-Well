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



struct FocusShiftingGuideView: View {
    @State private var showExercise = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Instructions Section
                CardView(icon: "info.circle.fill", title: "Instructions") {
                    VStack(alignment: .leading, spacing: 12) {
                        InstructionRow(number: 1, text: "Sit in a comfortable position with good posture")
                        InstructionRow(number: 2, text: "Keep your head still and move only your eyes")
                        InstructionRow(number: 3, text: "Focus on near and far targets alternately")
                        InstructionRow(number: 4, text: "Blink naturally between transitions")
                    }
                }
                
                // Illustration Section
                CardView(icon: "arrow.left.and.right", title: "Exercise Pattern") {
                    VStack(spacing: 20) {
                        Image("focusing") // Add focusing pattern image to assets
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .padding()
                        
                        Text("Shift focus between near and far targets")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                // Benefits Section
                CardView(icon: "checkmark.circle.fill", iconColor: .green, title: "Benefits") {
                    VStack(alignment: .leading, spacing: 8) {
                        BenefitRow(text: "Improves focusing ability")
                        BenefitRow(text: "Strengthens eye muscles")
                        BenefitRow(text: "Reduces eye strain")
                        BenefitRow(text: "Enhances depth perception")
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Focus Shifting")
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
            FocusShiftingView()
        }
    }
}


// New Focus Shifting Exercise View
struct FocusShiftingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var remainingTime: TimeInterval = 120
    @State private var currentFocus = "near"
    @State private var isAnimating = false
    
    let synthesizer = AVSpeechSynthesizer()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // AR View
            ARFocusView(currentFocus: $currentFocus)
            
            VStack {
                // Timer Display
                VStack(spacing: 8) {
                    Text(timeString(from: remainingTime))
                        .font(.system(size: 60, weight: .bold))
                        .monospacedDigit()
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2)
                    
                    Text("Remaining Time")
                        .font(.title3)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
                
                // Instructions
                VStack(spacing: 16) {
                    Text(currentFocus == "near" ? "Focus on Near Ball (Green)" : "Focus on Far Ball (Yellow)")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2)
                    
                    VStack(spacing: 8) {
                        Text("Keep your head still")
                            .font(.headline)
                        Text("Move only your eyes between targets")
                            .font(.subheadline)
                    }
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
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
                        .background(.ultraThinMaterial)
                }
                .padding(.bottom, 30)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            startExercise()
        }
        .onReceive(timer) { _ in
            if isAnimating {
                updateExercise()
            }
        }
    }
    
    private func startExercise() {
        isAnimating = true
        speakInstruction("Begin focus shifting exercise. Focus on the green near ball.")
        startFocusAnimation()
    }
    
    private func startFocusAnimation() {
        guard isAnimating else { return }
        
        withAnimation(.easeInOut(duration: 0.5)) {
            currentFocus = "near"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            guard isAnimating else { return }
            withAnimation(.easeInOut(duration: 0.5)) {
                currentFocus = "far"
            }
            if isAnimating {
                speakInstruction("Focus on the yellow far ball")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                guard isAnimating else { return }
                startFocusAnimation()
            }
        }
    }
    
    private func updateExercise() {
        if remainingTime > 0 {
            remainingTime -= 1
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

struct ARFocusView: UIViewRepresentable {
    @Binding var currentFocus: String
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        arView.delegate = context.coordinator
        arView.session.delegate = context.coordinator
        
        // Configure AR session
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        arView.session.run(configuration)
        
        // Add focus balls
        setupFocusBalls(in: arView)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // Update ball appearances based on current focus
        if let nearBall = uiView.scene.rootNode.childNode(withName: "nearBall", recursively: true),
           let farBall = uiView.scene.rootNode.childNode(withName: "farBall", recursively: true) {
            
            let nearColor = UIColor.green
            let farColor = UIColor.yellow
            let unfocusedColor = UIColor.gray
            
            nearBall.geometry?.firstMaterial?.diffuse.contents = currentFocus == "near" ? nearColor : unfocusedColor
            farBall.geometry?.firstMaterial?.diffuse.contents = currentFocus == "far" ? farColor : unfocusedColor
            
            // Add glow effect to focused ball
            if currentFocus == "near" {
                addGlowEffect(to: nearBall, color: .green)
                removeGlowEffect(from: farBall)
            } else {
                addGlowEffect(to: farBall, color: .yellow)
                removeGlowEffect(from: nearBall)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func setupFocusBalls(in arView: ARSCNView) {
        // Create near ball
        let nearBall = SCNNode(geometry: SCNSphere(radius: 0.05))
        nearBall.name = "nearBall"
        nearBall.position = SCNVector3(0, 0, -0.5) // 0.5 meters away
        nearBall.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        
        // Create far ball
        let farBall = SCNNode(geometry: SCNSphere(radius: 0.15))
        farBall.name = "farBall"
        farBall.position = SCNVector3(0, 0, -10) // 10 meters away
        farBall.geometry?.firstMaterial?.diffuse.contents = UIColor.gray
        
        // Add balls to scene
        arView.scene.rootNode.addChildNode(nearBall)
        arView.scene.rootNode.addChildNode(farBall)
    }
    
    private func addGlowEffect(to node: SCNNode, color: UIColor) {
        let glow = SCNMaterial()
        glow.emission.contents = color
        glow.emission.intensity = 1.0
        node.geometry?.materials.append(glow)
    }
    
    private func removeGlowEffect(from node: SCNNode) {
        if node.geometry?.materials.count ?? 0 > 1 {
            node.geometry?.materials.removeLast()
        }
    }
    
    class Coordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate {
        var parent: ARFocusView
        
        init(_ parent: ARFocusView) {
            self.parent = parent
        }
        
        func session(_ session: ARSession, didFailWithError error: Error) {
            // Handle session errors
            print("AR Session failed: \(error.localizedDescription)")
        }
        
        func sessionWasInterrupted(_ session: ARSession) {
            // Handle session interruption
            print("AR Session was interrupted")
        }
        
        func sessionInterruptionEnded(_ session: ARSession) {
            // Handle interruption end
            print("AR Session interruption ended")
        }
    }
}
