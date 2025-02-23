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

struct EyeGame: Identifiable {
    let id = UUID()
    let title: String
    let image: String // Name of the image asset
    let description: String
    let destination: AnyView
}

@MainActor
class EyeGamesViewModel: ObservableObject {
    let games: [EyeGame] = [
        EyeGame(
            title: "The Odd Color",
            image: "oddcolor",
            description: "Find the different colored square",
            destination: AnyView(OddColorGameView())
        ),
        EyeGame(
            title: "Brick Breaker Ball",
            image: "brickbreaker",
            description: "Break the bricks with the ball",
            destination: AnyView(BrickBreakerGameView())
        ),
        EyeGame(
            title: "Illusion Effects & Fun",
            image: "illusioneffect",
            description: "Experience various optical illusions",
            destination: AnyView(IllusionEffectsView())
        )
    ]
}

struct EyeGamesView: View {
    @StateObject private var viewModel = EyeGamesViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(viewModel.games) { game in
                        NavigationLink(destination: game.destination) {
                            GameCard(game: game)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Eye Games")
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct GameCard: View {
    let game: EyeGame
    
    var body: some View {
        HStack(spacing: 15) {
            Image(game.image)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(game.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(game.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "play.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

//class EducationViewModel: ObservableObject {
//    @Published var selectedCategory: EducationContent.Category = .basics
//    
//    let educationalContent: [EducationContent] = [
//        // BASICS
//        EducationContent(
//            title: "Understanding Eye Strain",
//            description: "Digital eye strain, also known as computer vision syndrome, occurs when your eyes become tired from intense use of digital devices. Common causes include prolonged screen time, poor lighting, glare, and improper viewing distances.",
//            iconName: "eye.circle",
//            category: .basics,
//            keyPoints: [
//                "Eye strain affects 50% of computer users",
//                "Symptoms can develop after 2+ hours of screen time",
//                "Both children and adults are susceptible",
//                "Can be temporary but may indicate underlying issues",
//                "Often accompanied by poor posture and neck strain"
//            ],
//            tips: [
//                "Adjust screen brightness to match room lighting",
//                "Use the 20-20-20 rule regularly",
//                "Maintain proper posture while working",
//                "Keep screens at arm's length",
//                "Use artificial tears if needed"
//            ],
//            learnMore: "Eye strain, or asthenopia, is a common condition that occurs when your eyes become tired from intense use. According to the American Optometric Association, the average American worker spends seven hours a day on the computer either in the office or working from home. The rise of digital devices has led to an increase in reported cases of digital eye strain, with studies showing that 90% of digital device users experience some form of eye strain symptoms."
//        ),
//        
//        EducationContent(
//            title: "Common Symptoms",
//            description: "Key symptoms include: dry or watery eyes, blurred or double vision, headache, neck and shoulder pain, increased sensitivity to light, difficulty concentrating, and feeling that you cannot keep your eyes open.",
//            iconName: "exclamationmark.circle",
//            category: .basics,
//            keyPoints: [
//                "Symptoms may develop gradually",
//                "Can affect both eyes equally",
//                "May worsen throughout the day",
//                "Can impact work productivity",
//                "Often reversible with proper care"
//            ],
//            tips: [
//                "Document when symptoms occur",
//                "Take regular screen breaks",
//                "Adjust workspace ergonomics",
//                "Consider computer glasses",
//                "Stay hydrated throughout the day"
//            ],
//            learnMore: "Digital eye strain symptoms can vary from person to person but typically include a combination of eye discomfort and vision problems. The Vision Council reports that nearly 65% of Americans experience symptoms of digital eye strain. These symptoms are part of Computer Vision Syndrome (CVS), recognized by the American Optometric Association as a group of eye and vision-related problems resulting from prolonged digital device use."
//        ),
//        
//        // PREVENTION
//        EducationContent(
//            title: "Proper Screen Setup",
//            description: "Optimize your screen position and settings to minimize eye strain. The right setup can significantly reduce visual fatigue and discomfort.",
//            iconName: "display",
//            category: .prevention,
//            keyPoints: [
//                "Screen should be 20-28 inches from eyes",
//                "Top of screen at or slightly below eye level",
//                "Screen tilt of 10-20 degrees",
//                "Anti-glare filters can help reduce reflection",
//                "Regular screen cleaning improves clarity"
//            ],
//            tips: [
//                "Adjust screen brightness to match room lighting",
//                "Enable night mode in low-light conditions",
//                "Use larger text sizes when possible",
//                "Position screen perpendicular to windows",
//                "Consider using blue light filters"
//            ],
//            learnMore: "Screen ergonomics play a crucial role in preventing digital eye strain. Research shows that improper screen positioning can increase eye strain by up to 40%. The optimal viewing distance (20-28 inches) allows your eyes to maintain proper focus while reducing exposure to blue light and glare. Studies indicate that having the screen slightly below eye level reduces dry eye symptoms as it encourages a slightly downward gaze, which naturally allows for more frequent blinking."
//        ),
//        
//        EducationContent(
//            title: "Workspace Lighting",
//            description: "Proper lighting in your workspace is essential for reducing eye strain. Balance ambient lighting with screen brightness and minimize glare from windows and overhead lights.",
//            iconName: "lightbulb",
//            category: .prevention,
//            keyPoints: [
//                "Room lighting should match screen brightness",
//                "Avoid working in darkness",
//                "Reduce glare from windows and lights",
//                "Use indirect lighting when possible",
//                "Consider task lighting for documents"
//            ],
//            tips: [
//                "Position desk perpendicular to windows",
//                "Use adjustable window shades",
//                "Install desk lamps with adjustable arms",
//                "Choose matte surfaces for desk",
//                "Maintain consistent lighting throughout day"
//            ],
//            learnMore: "Proper lighting is fundamental to eye health in digital environments. The American Optometric Association recommends that ambient lighting should be approximately half as bright as your screen. Studies show that poor lighting conditions can increase eye strain symptoms by up to 91%. Task lighting should be positioned to illuminate documents without creating screen reflections. The use of indirect lighting can reduce glare by up to 50% compared to direct overhead lighting."
//        ),
//        
//        // EXERCISES
//        EducationContent(
//            title: "Focus Shifting",
//            description: "Practice shifting focus between near and far objects to strengthen eye muscles and improve focusing ability.",
//            iconName: "arrow.left.and.right",
//            category: .exercises,
//            keyPoints: [
//                "Improves accommodation flexibility",
//                "Strengthens focusing muscles",
//                "Reduces eye fatigue",
//                "Helps maintain natural focusing ability",
//                "Can be done anywhere, anytime"
//            ],
//            tips: [
//                "Hold thumb at arm's length",
//                "Focus alternately on thumb and distant object",
//                "Hold each focus for 2-3 seconds",
//                "Practice for 2-3 minutes at a time",
//                "Repeat 3-4 times daily"
//            ],
//            learnMore: "Focus shifting exercises, also known as near-far focusing, help maintain the flexibility of the ciliary muscles in your eyes. These muscles are responsible for changing the shape of your eye's lens to focus on objects at different distances. Research indicates that regular practice of focus shifting can improve accommodation speed by up to 33% and reduce symptoms of digital eye strain. This exercise is particularly beneficial for people who spend long hours focusing on screens at a fixed distance."
//        ),
//        
//        EducationContent(
//            title: "Figure Eight",
//            description: "Trace an imaginary figure eight pattern with your eyes to improve eye muscle coordination and flexibility.",
//            iconName: "infinity",
//            category: .exercises,
//            keyPoints: [
//                "Exercises all eye movement muscles",
//                "Improves eye tracking ability",
//                "Enhances peripheral vision",
//                "Reduces muscle tension",
//                "Promotes smooth eye movements"
//            ],
//            tips: [
//                "Start with larger movements",
//                "Gradually decrease pattern size",
//                "Alternate directions every 30 seconds",
//                "Keep head still during exercise",
//                "Practice for 1-2 minutes at a time"
//            ],
//            learnMore: "The figure eight exercise engages all six extraocular muscles that control eye movement. These muscles work together to perform smooth pursuit movements, which are essential for activities like reading and tracking moving objects. Studies have shown that regular practice of smooth pursuit exercises can improve reading speed by up to 15% and reduce eye muscle fatigue. The figure eight pattern is particularly effective because it combines horizontal, vertical, and diagonal movements in a flowing pattern."
//        ),
//        
//        // LIFESTYLE
//        EducationContent(
//            title: "Sleep Hygiene",
//            description: "Good sleep habits are crucial for eye health and overall vision maintenance. Quality sleep allows your eyes to rest and repair.",
//            iconName: "bed.double",
//            category: .lifestyle,
//            keyPoints: [
//                "Eyes need 7-9 hours of rest",
//                "Blue light affects sleep quality",
//                "REM sleep aids eye moisture",
//                "Poor sleep increases strain risk",
//                "Sleep position affects eye pressure"
//            ],
//            tips: [
//                "Avoid screens 1 hour before bed",
//                "Use blue light filters in evening",
//                "Sleep with head slightly elevated",
//                "Maintain regular sleep schedule",
//                "Use artificial tears before bed if needed"
//            ],
//            learnMore: "Sleep plays a vital role in eye health and function. During sleep, your eyes clear out irritants and replenish their supply of natural lubricants. Research shows that lack of sleep can increase eye strain symptoms by up to 200%. The National Sleep Foundation reports that exposure to blue light from screens before bedtime can delay the release of melatonin by up to 3 hours, disrupting natural sleep patterns. Studies also indicate that sleeping with your head slightly elevated can help reduce overnight eye pressure and morning puffiness."
//        ),
//        
//        EducationContent(
//            title: "Regular Eye Exams",
//            description: "Regular comprehensive eye examinations are essential for maintaining eye health and detecting potential problems early.",
//            iconName: "calendar.badge.clock",
//            category: .lifestyle,
//            keyPoints: [
//                "Adults need exams every 1-2 years",
//                "Digital workers may need more frequent checks",
//                "Can detect early vision problems",
//                "Prescription changes are common",
//                "Important for preventive care"
//            ],
//            tips: [
//                "Schedule regular check-ups",
//                "Update prescriptions promptly",
//                "Discuss digital habits with doctor",
//                "Keep record of eye symptoms",
//                "Follow doctor's recommendations"
//            ],
//            learnMore: "According to the American Academy of Ophthalmology, regular eye exams are crucial for maintaining vision health. Adults aged 18-60 should have a comprehensive eye exam every two years, while those over 61 should have annual exams. People with high digital device usage may need more frequent check-ups. Studies show that up to 71% of digital device users have uncorrected vision problems that contribute to eye strain. Regular exams can detect conditions like myopia progression, which has increased by 66% since the widespread adoption of digital devices."
//        )
//    ]
//    
//    func filteredContent() -> [EducationContent] {
//        educationalContent.filter { $0.category == selectedCategory }
//    }
//}
//
//struct EducationView: View {
//    @StateObject private var viewModel = EducationViewModel()
//    
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 0) {
//                // Category Picker
//                Picker("Category", selection: $viewModel.selectedCategory) {
//                    Text("Basics").tag(EducationContent.Category.basics)
//                    Text("Prevention").tag(EducationContent.Category.prevention)
//                    Text("Exercises").tag(EducationContent.Category.exercises)
//                    Text("Lifestyle").tag(EducationContent.Category.lifestyle)
//                }
//                .pickerStyle(.segmented)
//                .padding()
//                
//                ScrollView {
//                    LazyVGrid(
//                        columns: [
//                            GridItem(.flexible(), spacing: 16),
//                            GridItem(.flexible(), spacing: 16)
//                        ],
//                        spacing: 16
//                    ) {
//                        ForEach(viewModel.filteredContent()) { content in
//                            EducationCard(content: content)
//                        }
//                    }
//                    .padding()
//                }
//            }
//            .navigationTitle("Learn")
//            .background(Color(.systemGroupedBackground))
//        }
//    }
//}
//
//struct EducationCard: View {
//    let content: EducationContent
//    
//    var body: some View {
//        NavigationLink(destination: EducationDetailView(content: content)) {
//            VStack(alignment: .leading, spacing: 12) {
//                // Icon
//                Image(systemName: content.iconName)
//                    .font(.system(size: 24))
//                    .foregroundColor(.blue)
//                    .frame(width: 40, height: 40)
//                    .background(Color.blue.opacity(0.1))
//                    .clipShape(RoundedRectangle(cornerRadius: 10))
//                
//                // Title
//                Text(content.title)
//                    .font(.headline)
//                    .foregroundColor(.primary)
//                    .lineLimit(2)
//                
//                // Description
//                Text(content.description)
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                    .lineLimit(3)
//                
//                Spacer()
//            }
//            .frame(height: 180)
//            .padding()
//            .background(Color(.systemBackground))
//            .clipShape(RoundedRectangle(cornerRadius: 16))
//            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
//        }
//    }
//}
//
//struct EducationDetailView: View {
//    let content: EducationContent
//    
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 20) {
//                // Header
//                HStack {
//                    Image(systemName: content.iconName)
//                        .font(.system(size: 32))
//                        .foregroundColor(.blue)
//                        .frame(width: 60, height: 60)
//                        .background(Color.blue.opacity(0.1))
//                        .clipShape(RoundedRectangle(cornerRadius: 15))
//                    
//                    VStack(alignment: .leading) {
//                        Text(content.category.rawValue)
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                        
//                        Text(content.title)
//                            .font(.title2)
//                            .bold()
//                    }
//                }
//                .padding(.bottom)
//                
//                // Overview
//                DetailSection(title: "Overview", content: content.description)
//                
//                // Key Points
//                VStack(alignment: .leading, spacing: 12) {
//                    Text("Key Points")
//                        .font(.headline)
//                        .foregroundColor(.primary)
//                    
//                    VStack(alignment: .leading, spacing: 8) {
//                        ForEach(content.keyPoints, id: \.self) { point in
//                            HStack(alignment: .top) {
//                                Image(systemName: "checkmark.circle.fill")
//                                    .foregroundColor(.green)
//                                Text(point)
//                            }
//                        }
//                    }
//                }
//                .padding()
//                .background(Color(.systemBackground))
//                .clipShape(RoundedRectangle(cornerRadius: 12))
//                
//                // Tips
//                VStack(alignment: .leading, spacing: 12) {
//                    Text("Tips")
//                        .font(.headline)
//                        .foregroundColor(.primary)
//                    
//                    VStack(alignment: .leading, spacing: 8) {
//                        ForEach(content.tips, id: \.self) { tip in
//                            HStack(alignment: .top) {
//                                Image(systemName: "lightbulb.fill")
//                                    .foregroundColor(.yellow)
//                                Text(tip)
//                            }
//                        }
//                    }
//                }
//                .padding()
//                .background(Color(.systemBackground))
//                .clipShape(RoundedRectangle(cornerRadius: 12))
//                
//                // Learn More
//                DetailSection(title: "Learn More", content: content.learnMore)
//            }
//            .padding()
//        }
//        .navigationBarTitleDisplayMode(.inline)
//        .background(Color(.systemGroupedBackground))
//    }
//}
//
//struct DetailSection: View {
//    let title: String
//    let content: String
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text(title)
//                .font(.headline)
//                .foregroundColor(.primary)
//            
//            Text(content)
//                .font(.body)
//                .foregroundColor(.secondary)
//        }
//        .padding()
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(Color(.systemBackground))
//        .clipShape(RoundedRectangle(cornerRadius: 12))
//    }
//}
