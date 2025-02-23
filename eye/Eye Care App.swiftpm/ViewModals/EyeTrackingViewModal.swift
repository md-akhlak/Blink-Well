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


class EyeTrackingViewModel: NSObject, ObservableObject, ARSessionDelegate {
    @Published var exerciseSessions: [ExerciseSession] = []
    @Published var blinkCount = 0
    @Published var eyebrowTwitchCount = 0
    @Published var eyeStrainDetected = false
    @Published var isTracking = false
    @Published var exerciseDuration: TimeInterval = 30
    @Published var remainingTime: TimeInterval = 0
    @Published var isExerciseActive = false
    @Published var stressLevel: Int = 0
    @Published var screenTime: TimeInterval = 0
    @Published var selectedDuration: TimeInterval = 30  // Add this property
    
    // New logs properties
    @Published var blinkLogs: [SymptomLog] = []
    @Published var twitchLogs: [SymptomLog] = []
    
    // Add new properties
    @Published var showEyeStrainWarning = false
    private var lastBlinkTimestamp: Date?
    private var lastTwitchTimestamp: Date?
    private var blinkThresholdReached = false
    private var twitchThresholdReached = false
    
    private var arSession: ARSession?
    private var timer: Timer?
    
    override init() {
        super.init()
        setupARSession()
    }
    
    private func setupARSession() {
        arSession = ARSession()
        arSession?.delegate = self
    }
    
    func startExercise() {
        blinkCount = 0
        eyebrowTwitchCount = 0
        eyeStrainDetected = false
        
        guard ARFaceTrackingConfiguration.isSupported else {
            print("Face tracking is not supported on this device.")
            return
        }
        
        print("Starting Exercise - Before Configuration")
        
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        
        arSession?.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        print("Starting Exercise - Session Running")
        
        isTracking = true
        isExerciseActive = true
        exerciseDuration = selectedDuration
        remainingTime = exerciseDuration  // Use exerciseDuration instead of hardcoded value
        
        print("Starting Exercise - State: isExerciseActive = \(isExerciseActive)")
        
        // Start the timer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.remainingTime > 0 {
                self.remainingTime -= 1
            } else {
                self.stopExercise()
            }
        }
    }
    
    func stopExercise() {
        timer?.invalidate()
        timer = nil
        arSession?.pause()
        isTracking = false
        isExerciseActive = false
        
        // Save the session with pattern information
        let newSession = ExerciseSession(
            date: Date(),
            duration: exerciseDuration - remainingTime, // Actual duration spent
            blinkCount: blinkCount,
            twitchCount: eyebrowTwitchCount
        )
        
        // Add new session at the beginning of the array
        exerciseSessions.insert(newSession, at: 0)
        
        // Analyze results and log symptoms if needed
        analyzeResults()
        
        // Reset counters
        blinkCount = 0
        eyebrowTwitchCount = 0
        eyeStrainDetected = false
        remainingTime = exerciseDuration
    }
    
    private func analyzeResults() {
        // Log blinks if they exceed threshold
        if blinkCount > 10 {
            logSymptom(
                type: "Blink",
                intensity: Int((Double(blinkCount) / exerciseDuration) * 100),
                trigger: "Exercise Session"
            )
        }
        
        // Log twitches if they exceed threshold
        if eyebrowTwitchCount > 5 {
            logSymptom(
                type: "Twitch",
                intensity: Int((Double(eyebrowTwitchCount) / exerciseDuration) * 100),
                trigger: "Exercise Session"
            )
        }
        
        // Log eye strain if detected
        if eyeStrainDetected {
            logSymptom(
                type: "Eye Strain",
                intensity: 75, // High intensity since it was detected
                trigger: "Exercise Session"
            )
        }
    }
    
    // Symptom Logging Method
    func logSymptom(type: String, intensity: Int, trigger: String? = nil) {
        let log = SymptomLog(
            date: Date(),
            symptomType: type,
            intensity: intensity,
            notes: "",
            trigger: trigger
        )
        
        if type == "Blink" {
            blinkLogs.insert(log, at: 0)
        } else if type == "Twitch" {
            twitchLogs.insert(log, at: 0)
        }
        
        // Limit logs to last 10 entries
        blinkLogs = Array(blinkLogs.prefix(10))
        twitchLogs = Array(twitchLogs.prefix(10))
    }
    
    // ARSessionDelegate Methods
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let faceAnchor = anchor as? ARFaceAnchor {
                processFaceAnchor(faceAnchor)
            }
        }
    }
    
    private func processFaceAnchor(_ faceAnchor: ARFaceAnchor) {
        let blendShapes = faceAnchor.blendShapes
        
        // Enhanced blink detection
        if let leftEyeBlink = blendShapes[.eyeBlinkLeft]?.floatValue,
           let rightEyeBlink = blendShapes[.eyeBlinkRight]?.floatValue {
            let blinkThreshold: Float = 0.5
            let now = Date()
            
            if leftEyeBlink > blinkThreshold && rightEyeBlink > blinkThreshold {
                if !blinkThresholdReached {
                    blinkThresholdReached = true
                    if let lastBlink = lastBlinkTimestamp {
                        let timeSinceLastBlink = now.timeIntervalSince(lastBlink)
                        if timeSinceLastBlink > 0.5 { // Increased minimum time between blinks
                            blinkCount += 1
                            lastBlinkTimestamp = now
                            logSymptom(type: "Blink", intensity: Int((leftEyeBlink + rightEyeBlink) * 50))
                        }
                    } else {
                        blinkCount += 1
                        lastBlinkTimestamp = now
                        logSymptom(type: "Blink", intensity: Int((leftEyeBlink + rightEyeBlink) * 50))
                    }
                }
            } else {
                blinkThresholdReached = false
            }
        }
        
        // Enhanced twitch detection
        if let browInnerUp = blendShapes[.browInnerUp]?.floatValue,
           let browOuterUpLeft = blendShapes[.browOuterUpLeft]?.floatValue,
           let browOuterUpRight = blendShapes[.browOuterUpRight]?.floatValue {
            
            let twitchThreshold: Float = 0.4
            let now = Date()
            let combinedBrowMovement = (browInnerUp + browOuterUpLeft + browOuterUpRight) / 3.0
            
            if combinedBrowMovement > twitchThreshold {
                if !twitchThresholdReached {
                    twitchThresholdReached = true
                    if let lastTwitch = lastTwitchTimestamp {
                        let timeSinceLastTwitch = now.timeIntervalSince(lastTwitch)
                        if timeSinceLastTwitch > 0.8 { // Increased minimum time between twitches
                            eyebrowTwitchCount += 1
                            lastTwitchTimestamp = now
                            logSymptom(type: "Twitch", intensity: Int(combinedBrowMovement * 100))
                        }
                    } else {
                        eyebrowTwitchCount += 1
                        lastTwitchTimestamp = now
                        logSymptom(type: "Twitch", intensity: Int(combinedBrowMovement * 100))
                    }
                }
            } else {
                twitchThresholdReached = false
            }
        }
        
        // Enhanced eye strain detection
        if let eyeSqueezeLeft = blendShapes[.eyeSquintLeft]?.floatValue,
           let eyeSqueezeRight = blendShapes[.eyeSquintRight]?.floatValue {
            
            let strainThreshold: Float = 0.7
            let combinedEyeStrain = (eyeSqueezeLeft + eyeSqueezeRight) / 2.0
            
            if combinedEyeStrain > strainThreshold {
                eyeStrainDetected = true
                showEyeStrainWarning = true
            }
        }
    }
    
    func dismissEyeStrainWarning() {
        showEyeStrainWarning = false
        eyeStrainDetected = false
    }
}
