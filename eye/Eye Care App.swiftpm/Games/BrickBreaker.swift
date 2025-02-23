import Foundation
import SwiftUI


@MainActor
struct BrickBreakerGameView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var ballPosition = CGPoint(x: 200, y: 400)
    @State private var ballVelocity = CGPoint(x: 0, y: 0)
    @State private var paddlePosition: CGFloat = 200
    @State private var isGameActive = false
    @State private var currentLevel = 1
    @State private var showGameOver = false
    @State private var timer: Timer?
    @State private var bricks: [[Brick]] = []
    
    let brickColors: [[Color]] = [
        [.red, .orange, .yellow, .green],
        [.blue, .purple, .pink, .indigo],
        [.cyan, .mint, .brown, .teal]
    ]
    
    struct Brick: Identifiable {
        let id = UUID()
        var isActive: Bool
        var color: Color
    }
    
    func setupLevel() {
        let rows = 4
        let cols = 6
        var newBricks: [[Brick]] = []
        
        for row in 0..<rows {
            var brickRow: [Brick] = []
            for col in 0..<cols {
                let colorIndex = (row + currentLevel - 1) % brickColors.count
                let color = brickColors[colorIndex][col % brickColors[colorIndex].count]
                brickRow.append(Brick(isActive: true, color: color))
            }
            newBricks.append(brickRow)
        }
        bricks = newBricks
        resetBall()
    }
    
    func resetBall() {
        let paddleY = UIScreen.main.bounds.height - 100
        ballPosition = CGPoint(
            x: paddlePosition,
            y: paddleY - 20
        )
        ballVelocity = .zero
        isGameActive = false
    }
    
    func startGame() {
        if !isGameActive {
            isGameActive = true
            ballVelocity = CGPoint(x: 7, y: -7)
            startTimer()
        }
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
            Task { @MainActor in
                self.updateGame()
            }
        }
    }
    
    func updateGame() {
        if isGameActive {
            let nextPosition = CGPoint(
                x: ballPosition.x + ballVelocity.x,
                y: ballPosition.y + ballVelocity.y
            )

            let ballRadius: CGFloat = 10
            
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            
            let paddleY = screenHeight - 100
            let paddleHeight: CGFloat = 20
            let paddleWidth: CGFloat = 100
            let paddleLeft = paddlePosition - paddleWidth/2
            let paddleRight = paddlePosition + paddleWidth/2
            let paddleTop = paddleY - paddleHeight/2
            let paddleBottom = paddleY + paddleHeight/2
            
            if nextPosition.x <= ballRadius || nextPosition.x >= screenWidth - ballRadius {
                ballVelocity.x *= -1
            }
            if nextPosition.y <= ballRadius {
                ballVelocity.y *= -1
            }
            
            if nextPosition.y + ballRadius >= paddleTop && 
               nextPosition.y - ballRadius <= paddleBottom &&
               nextPosition.x + ballRadius >= paddleLeft && 
               nextPosition.x - ballRadius <= paddleRight {
                
                let hitPoint = (nextPosition.x - paddlePosition) / (paddleWidth/2)
                let maxAngle: CGFloat = .pi / 3
                let angle = hitPoint * maxAngle
                
                let speed: CGFloat = 10.0
                ballVelocity.x = speed * sin(angle)
                ballVelocity.y = -speed * cos(angle)
                
                ballPosition.y = paddleTop - ballRadius
            } else if nextPosition.y > paddleBottom {
                gameOver()
                return
            }
            
            if isGameActive {
                ballPosition = nextPosition
                checkBrickCollisions()
            }
        }
    }
    
    func checkBrickCollisions() {
        let ballRadius: CGFloat = 10
        
        for row in 0..<bricks.count {
            for col in 0..<bricks[row].count {
                if bricks[row][col].isActive {
                    let brickX = CGFloat(col) * 60 + 30
                    let brickY = CGFloat(row) * 40 + 50
                    let brickWidth: CGFloat = 55
                    let brickHeight: CGFloat = 30
                    
                    let brickLeft = brickX - brickWidth / 2
                    let brickRight = brickX + brickWidth / 2
                    let brickTop = brickY - brickHeight / 2
                    let brickBottom = brickY + brickHeight / 2
                    
                    let ballLeft = ballPosition.x - ballRadius
                    let ballRight = ballPosition.x + ballRadius
                    let ballTop = ballPosition.y - ballRadius
                    let ballBottom = ballPosition.y + ballRadius
                    
                    if ballRight >= brickLeft && ballLeft <= brickRight &&
                       ballBottom >= brickTop && ballTop <= brickBottom {
                        
                        bricks[row][col].isActive = false
                        
                        let previousBallCenter = CGPoint(
                            x: ballPosition.x - ballVelocity.x,
                            y: ballPosition.y - ballVelocity.y
                        )
                        
                        if previousBallCenter.x < brickLeft || previousBallCenter.x > brickRight {
                            ballVelocity.x *= -1
                        } else {
                            ballVelocity.y *= -1
                        }
                        
                        if checkLevelComplete() {
                            nextLevel()
                        }
                        return
                    }
                }
            }
        }
    }
    
    func checkLevelComplete() -> Bool {
        return bricks.allSatisfy { row in
            row.allSatisfy { !$0.isActive }
        }
    }
    
    func nextLevel() {
        if currentLevel < 3 {
            currentLevel += 1
            setupLevel()
        } else {
            gameOver()
        }
    }
    
    func gameOver() {
        isGameActive = false
        timer?.invalidate()
        timer = nil
        showGameOver = true
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                ForEach(0..<bricks.count, id: \.self) { row in
                    ForEach(0..<bricks[row].count, id: \.self) { col in
                        if bricks[row][col].isActive {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(bricks[row][col].color)
                                .frame(width: 55, height: 30)
                                .position(x: CGFloat(col) * 60 + 30,
                                        y: CGFloat(row) * 40 + 50)
                        }
                    }
                }
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .position(ballPosition)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.green)
                    .frame(width: 100, height: 20)
                    .position(x: paddlePosition, y: geometry.size.height - 100)
                
                if !isGameActive {
                    Text("Tap to Start Level \(currentLevel)")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue.opacity(0.5))
                        .cornerRadius(10)
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        paddlePosition = value.location.x
                        if !isGameActive {
                            ballPosition.x = value.location.x
                        }
                    }
            )
            .onTapGesture {
                startGame()
            }
        }
        .alert("Game Over", isPresented: $showGameOver) {
            Button("Try Again") {
                currentLevel = 1
                setupLevel()
                showGameOver = false
            }
            Button("Quit") {
                dismiss()
            }
        } message: {
            Text(checkLevelComplete() && currentLevel == 3 ? "Congratulations! You won!" : "Try again!")
        }
        .onAppear {
            setupLevel()
        }
        .navigationTitle("Brick Breaker - Level \(currentLevel)")
    }
}

