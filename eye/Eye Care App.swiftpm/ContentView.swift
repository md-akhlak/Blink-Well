//
//  File.swift
//  Blinking Disorder
//
//  Created by Akhlak iSDP on 18/02/25.
//

import Foundation
import UIKit
import SwiftUI
@preconcurrency import ARKit
@preconcurrency import AVFoundation


// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var viewModel = EyeTrackingViewModel()
    @State private var selectedDuration: TimeInterval = 30
    @State private var showingSplash = true
    
    var body: some View {
        ZStack {
            if showingSplash {
                SplashScreenView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation(.easeOut(duration: 0.5)) {
                                showingSplash = false
                            }
                        }
                    }
            } else {
                ZStack {
                    if viewModel.isExerciseActive {
                        ExerciseView(viewModel: viewModel)
                            .transition(.move(edge: .bottom))
                            .zIndex(1)
                            .navigationBarHidden(true)
                    }
                    
                    MainTabView(viewModel: viewModel, selectedDuration: $selectedDuration)
                        .opacity(viewModel.isExerciseActive ? 0 : 1)
                }
            }
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @ObservedObject var viewModel: EyeTrackingViewModel
    @Binding var selectedDuration: TimeInterval
    
    var body: some View {
        TabView {
            TrackingTab(viewModel: viewModel, selectedDuration: $selectedDuration)
                .tabItem {
                    Label("Track", systemImage: "eye")
                }
            
            ExerciseTabView()
                .tabItem {
                    Label("Exercise", systemImage: "heart")
                }
            
            EyeGamesView()
                .tabItem {
                    Label("Games", systemImage: "gamecontroller")
                }
        }
        .tint(.blue)
    }
}

// MARK: - Tracking Tab
struct TrackingTab: View {
    @ObservedObject var viewModel: EyeTrackingViewModel
    @Binding var selectedDuration: TimeInterval
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    StatisticsSection(viewModel: viewModel)
                    DurationSection(selectedDuration: $selectedDuration, viewModel: viewModel)
                    StartExerciseButton(viewModel: viewModel)
                    SessionHistorySection(viewModel: viewModel)
                }
                .padding(.vertical)
            }
            .navigationTitle("Eye Health")
        }
    }
}

// MARK: - Statistics Section
struct StatisticsSection: View {
    @ObservedObject var viewModel: EyeTrackingViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Today's Stats")
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                StatisticCard(
                    title: "Blinks",
                    value: viewModel.dailyBlinkCount,
                    icon: "eye.fill",
                    color: .blue
                )
                
                StatisticCard(
                    title: "Twitches",
                    value: viewModel.dailyTwitchCount,
                    icon: "exclamationmark.triangle.fill",
                    color: .orange
                )
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Duration Section
struct DurationSection: View {
    @Binding var selectedDuration: TimeInterval
    @ObservedObject var viewModel: EyeTrackingViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Select Duration")
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                ForEach([30.0, 60.0, 120.0], id: \.self) { duration in
                    TimeCard(
                        duration: duration,
                        isSelected: selectedDuration == duration
                    )
                    .onTapGesture {
                        selectedDuration = duration
                        viewModel.selectedDuration = duration
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Start Exercise Button
struct StartExerciseButton: View {
    @ObservedObject var viewModel: EyeTrackingViewModel
    
    var body: some View {
        Button(action: { viewModel.startExercise() }) {
            HStack {
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                Text("Start Exercise")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(colors: [.blue, .blue.opacity(0.8)],
                             startPoint: .leading,
                             endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal)
    }
}

// MARK: - Session History Section
struct SessionHistorySection: View {
    @ObservedObject var viewModel: EyeTrackingViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Recent Sessions")
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if viewModel.exerciseSessions.isEmpty {
                EmptySessionView()
            } else {
                SessionListView(sessions: viewModel.exerciseSessions.prefix(5))
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Empty Session View
struct EmptySessionView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("No sessions yet")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("Complete your first exercise to see history")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Session List View
struct SessionListView: View {
    let sessions: ArraySlice<ExerciseSession>
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(Array(sessions), id: \.id) { session in
                SessionRow(session: session)
            }
        }
    }
}

// MARK: - Session Row
struct SessionRow: View {
    let session: ExerciseSession
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Text("Duration: \(Int(session.duration))s")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(session.blinkCount) blinks")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                
                Text("\(session.twitchCount) twitches")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct ExerciseItem: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    let description: String
}

struct ExerciseTabView: View {
    let exercises = [
        ExerciseItem(
            name: "Palming",
            imageName: "palming",
            description: "Cover eyes with warm palms"
        ),
        ExerciseItem(
            name: "Blinking",
            imageName: "blinking",
            description: "Blinking exercise"
        ),
        ExerciseItem(
            name: "Eye Moves",
            imageName: "eyemoves",
            description: "Move eyes in different directions"
        ),
        ExerciseItem(
            name: "Zig-Zag",
            imageName: "zigzag",
            description: "Follow zig-zag pattern"
        ),
        ExerciseItem(
            name: "Flower Effect",
            imageName: "flower",
            description: "Focus on expanding pattern"
        ),
        ExerciseItem(
            name: "Focusing",
            imageName: "focusing",
            description: "Focus shifting exercise"
        ),
        ExerciseItem(
            name: "Star in Sky",
            imageName: "star",
            description: "Focus on distant point"
        ),
        ExerciseItem(
            name: "Eye Massage",
            imageName: "eyemassage",
            description: "Gentle eye area massage"
        )
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(exercises) { exercise in
                        NavigationLink(destination: getExerciseView(for: exercise.name)) {
                            ExerciseCardView(exercise: exercise)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Eye Exercises")
            .background(Color(.systemGroupedBackground))
        }
    }
    
    private func getExerciseView(for exerciseName: String) -> some View {
        Group {
            switch exerciseName {
            case "Palming":
                PalmingGuideView()
            case "Blinking":
                BlinkingGuideView()
            case "Eye Massage":
                EyeMassageGuideView()
            case "Focusing":
                FocusShiftingGuideView()
            case "Eye Moves":
                EyeRollingGuideView()
            case "Zig-Zag":
                ZigZagGuideView()
            case "Flower Effect":
                FlowerEffectGuideView()
            case "Star in Sky":
                StarInSkyGuideView()
            default:
                Text("Exercise coming soon")
            }
        }
    }
}

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 200/255, green: 250/255, blue: 200/255),
                    Color(red: 144/255, green: 190/255, blue: 200/255)

                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    Image(systemName: "eye.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        
                    
                    Text("Blink Care")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Text("Your Eye Wellness Companion")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.vertical)
            }
        }
    }
}


