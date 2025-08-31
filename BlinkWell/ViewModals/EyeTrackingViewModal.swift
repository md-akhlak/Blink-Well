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


class EyeTrackingViewModel: NSObject, ObservableObject, ARSessionDelegate {
    
    @Published var screenTime: TimeInterval = 0
    @Published var selectedDuration: TimeInterval = 30
    @Published var blinkLogs: [SymptomLog] = []
    @Published var twitchLogs: [SymptomLog] = []
    @Published var showEyeStrainWarning = false
    @Published var currentBlinkRate: Double = 0.0
    @Published var currentTwitchRate: Double = 0.0
    @Published var dailyBlinkCount = 0
    @Published var dailyTwitchCount = 0
    @Published var exerciseBlinkCount = 0
    @Published var exerciseTwitchCount = 0
    @Published var exerciseSessions: [ExerciseSession] = []
    @Published var blinkCount = 0
    @Published var eyebrowTwitchCount = 0
    @Published var isTracking = false
    @Published var exerciseDuration: TimeInterval = 30
    @Published var remainingTime: TimeInterval = 0
    @Published var isExerciseActive = false
    @Published var stressLevel: Int = 0
    @Published var eyeStrainDetected = false
    
    private var lastBlinkTimestamp: Date?
    private var lastTwitchTimestamp: Date?
    private var blinkThresholdReached = false
    private var twitchThresholdReached = false
    
    

    private var blinkRateTimer: Timer?
    private var recentBlinks: [Date] = []
    private var recentTwitches: [Date] = []
    private let rateWindowDuration: TimeInterval = 60
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
        exerciseBlinkCount = 0
        exerciseTwitchCount = 0
        eyeStrainDetected = false
        
        guard ARFaceTrackingConfiguration.isSupported else {
            print("Face tracking is not supported on this device.")
            return
        }
        
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        
        arSession?.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        isTracking = true
        isExerciseActive = true
        exerciseDuration = selectedDuration
        remainingTime = exerciseDuration
        
        print("Starting Exercise - State: isExerciseActive = \(isExerciseActive)")
        
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
        
        let newSession = ExerciseSession(
            date: Date(),
            duration: exerciseDuration - remainingTime,
            blinkCount: exerciseBlinkCount,
            twitchCount: exerciseTwitchCount
        )
        
        exerciseSessions.insert(newSession, at: 0)
        analyzeResults()
        
        exerciseBlinkCount = 0
        exerciseTwitchCount = 0
        eyeStrainDetected = false
        remainingTime = exerciseDuration
    }
    
    private func analyzeResults() {
        if blinkCount > 10 {
            logSymptom(
                type: "Blink",
                intensity: Int((Double(blinkCount) / exerciseDuration) * 100),
                trigger: "Exercise Session"
            )
        }
        
        if eyebrowTwitchCount > 5 {
            logSymptom(
                type: "Twitch",
                intensity: Int((Double(eyebrowTwitchCount) / exerciseDuration) * 100),
                trigger: "Exercise Session"
            )
        }
        
        if eyeStrainDetected {
            logSymptom(
                type: "Eye Strain",
                intensity: 75,
                trigger: "Exercise Session"
            )
        }
    }
    
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
        
        blinkLogs = Array(blinkLogs.prefix(10))
        twitchLogs = Array(twitchLogs.prefix(10))
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let faceAnchor = anchor as? ARFaceAnchor {
                processFaceAnchor(faceAnchor)
            }
        }
    }
    
    private func processFaceAnchor(_ faceAnchor: ARFaceAnchor) {
        let blendShapes = faceAnchor.blendShapes
        let now = Date()
        
        recentBlinks = recentBlinks.filter { now.timeIntervalSince($0) <= rateWindowDuration }
        recentTwitches = recentTwitches.filter { now.timeIntervalSince($0) <= rateWindowDuration }
        
        if let leftEyeBlink = blendShapes[.eyeBlinkLeft]?.floatValue,
           let rightEyeBlink = blendShapes[.eyeBlinkRight]?.floatValue {
            let blinkThreshold: Float = 0.5
            
            if leftEyeBlink > blinkThreshold && rightEyeBlink > blinkThreshold {
                if !blinkThresholdReached {
                    blinkThresholdReached = true
                    if let lastBlink = lastBlinkTimestamp {
                        let timeSinceLastBlink = now.timeIntervalSince(lastBlink)
                        if timeSinceLastBlink > 0.5 {
                            dailyBlinkCount += 1
                            if isExerciseActive {
                                exerciseBlinkCount += 1
                            }
                            lastBlinkTimestamp = now
                            recentBlinks.append(now)
                            currentBlinkRate = Double(recentBlinks.count)
                            logSymptom(type: "Blink", intensity: Int((leftEyeBlink + rightEyeBlink) * 50))
                        }
                    } else {
                        dailyBlinkCount += 1
                        if isExerciseActive {
                            exerciseBlinkCount += 1
                        }
                        lastBlinkTimestamp = now
                        recentBlinks.append(now)
                        currentBlinkRate = Double(recentBlinks.count)
                        logSymptom(type: "Blink", intensity: Int((leftEyeBlink + rightEyeBlink) * 50))
                    }
                }
            } else {
                blinkThresholdReached = false
            }
        }
        
        if let browInnerUp = blendShapes[.browInnerUp]?.floatValue,
           let browOuterUpLeft = blendShapes[.browOuterUpLeft]?.floatValue,
           let browOuterUpRight = blendShapes[.browOuterUpRight]?.floatValue {
            
            let twitchThreshold: Float = 0.4
            let combinedBrowMovement = (browInnerUp + browOuterUpLeft + browOuterUpRight) / 3.0
            
            if combinedBrowMovement > twitchThreshold {
                if !twitchThresholdReached {
                    twitchThresholdReached = true
                    if let lastTwitch = lastTwitchTimestamp {
                        let timeSinceLastTwitch = now.timeIntervalSince(lastTwitch)
                        if timeSinceLastTwitch > 0.8 {
                            dailyTwitchCount += 1
                            if isExerciseActive {
                                exerciseTwitchCount += 1
                            }
                            lastTwitchTimestamp = now
                            recentTwitches.append(now)
                            currentTwitchRate = Double(recentTwitches.count)
                            logSymptom(type: "Twitch", intensity: Int(combinedBrowMovement * 100))
                        }
                    } else {
                        dailyTwitchCount += 1
                        if isExerciseActive {
                            exerciseTwitchCount += 1
                        }
                        lastTwitchTimestamp = now
                        recentTwitches.append(now)
                        currentTwitchRate = Double(recentTwitches.count)
                        logSymptom(type: "Twitch", intensity: Int(combinedBrowMovement * 100))
                    }
                }
            } else {
                twitchThresholdReached = false
            }
        }
        
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
