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
