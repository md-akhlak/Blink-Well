//
//  DataModals.swift
//  Eye Care App
//
//  Created by Akhlak iSDP on 22/02/25.
//

import Foundation
import SwiftUI


// MARK: - Data Models
struct SymptomLog: Identifiable {
    let id = UUID()
    let date: Date
    let symptomType: String
    let intensity: Int
    let notes: String
    let trigger: String?
}

struct RelaxationExercise: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let duration: TimeInterval
}

struct EducationalContent: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let iconName: String
    let category: Category
    let keyPoints: [String]
    let tips: [String]
    let learnMore: String
    
    enum Category: String {
        case basics = "Basics"
        case prevention = "Prevention"
        case exercises = "Exercises"
        case lifestyle = "Lifestyle"
    }
}

struct ExerciseSession: Identifiable {
    let id = UUID()
    let date: Date
    let duration: TimeInterval
    let blinkCount: Int
    let twitchCount: Int
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}


struct EducationContent: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let iconName: String
    let category: Category
    let keyPoints: [String]
    let tips: [String]
    let learnMore: String
    
    enum Category: String {
        case basics = "Basics"
        case prevention = "Prevention"
        case exercises = "Exercises"
        case lifestyle = "Lifestyle"
    }
}
