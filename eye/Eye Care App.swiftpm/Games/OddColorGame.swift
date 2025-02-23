import SwiftUI

struct OddColorGameView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var colors: [[Color]] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var gridSize = 4
    @State private var oddPosition: (Int, Int) = (0, 0)
    @State private var showGameOver = false
    
    func generateColors() {
        // Generate base color
        let baseColor = Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
        
        // Create slightly different color
        let oddColor = baseColor.opacity(0.8)
        
        // Generate random position for odd color
        oddPosition = (
            Int.random(in: 0..<gridSize),
            Int.random(in: 0..<gridSize)
        )
        
        // Initialize empty grid
        var newColors: [[Color]] = []
        
        // Fill grid row by row
        for row in 0..<gridSize {
            var newRow: [Color] = []
            for col in 0..<gridSize {
                if row == oddPosition.0 && col == oddPosition.1 {
                    newRow.append(oddColor)
                } else {
                    newRow.append(baseColor)
                }
            }
            newColors.append(newRow)
        }
        
        colors = newColors
    }
    
    var body: some View {
        VStack {
            // Header with Score, Lives, and Stop Button
            HStack {
                // Lives
                HStack {
                    ForEach(0..<3) { index in
                        Image(systemName: index < lives ? "heart.fill" : "heart")
                            .foregroundColor(.red)
                    }
                }
                
                Spacer()
                
                // Score
                Text("Score: \(score)")
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                // Stop Button
                Button(action: {
                    showGameOver = true
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                }
            }
            .padding()
            
            // Game Grid
            VStack(spacing: 5) {
                ForEach(0..<gridSize, id: \.self) { row in
                    HStack(spacing: 5) {
                        ForEach(0..<gridSize, id: \.self) { col in
                            colors[safe: row]?[safe: col]
                                .map { color in
                                    color
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(8)
                                        .onTapGesture {
                                            handleTap(row: row, col: col)
                                        }
                                }
                        }
                    }
                }
            }
            .padding()
            
            // Instructions
            Text("Find the slightly different colored square")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding()
        }
        .alert("Game Over", isPresented: $showGameOver) {
            Button("Try Again") {
                resetGame()
            }
            Button("Quit") {
                dismiss()
            }
        } message: {
            Text("Final Score: \(score)")
        }
        .onAppear {
            resetGame()
        }
        .navigationTitle("The Odd Color")
    }
    
    private func handleTap(row: Int, col: Int) {
        if row == oddPosition.0 && col == oddPosition.1 {
            // Correct selection
            score += 1
            generateColors()
        } else {
            // Wrong selection
            lives -= 1
            if lives <= 0 {
                showGameOver = true
            }
        }
    }
    
    private func resetGame() {
        score = 0
        lives = 3
        generateColors()
        showGameOver = false
    }
}

// Safe array access extension
extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
} 