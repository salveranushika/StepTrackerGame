import SpriteKit
import CoreMotion

class MazeRunnerGameScene: SKScene, SKPhysicsContactDelegate {
    private let ballNode = SKSpriteNode(color: .blue, size: CGSize(width: 30, height: 30))
    private let goalNode = SKSpriteNode(color: .green, size: CGSize(width: 40, height: 40))
    private let motionManager = CMMotionManager()
    private var remainingSteps = 0
    
    private struct PhysicsCategory {
        static let ball: UInt32 = 0x1 << 0
        static let goal: UInt32 = 0x1 << 1
        static let wall: UInt32 = 0x1 << 2
        static let boundary: UInt32 = 0x1 << 3
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        setupBall()
        setupGoal()
        setupWalls()
        setupBoundary()
        startMotionUpdates()
    }
    

    func setRemainingSteps(_ steps: Int) {
        remainingSteps = steps
    }

    private func setupBall() {
        ballNode.position = CGPoint(x: frame.midX, y: frame.minY + 100)
        ballNode.physicsBody = SKPhysicsBody(circleOfRadius: 15)
        ballNode.physicsBody?.isDynamic = true
        ballNode.physicsBody?.categoryBitMask = PhysicsCategory.ball
        ballNode.physicsBody?.contactTestBitMask = PhysicsCategory.goal
        ballNode.physicsBody?.collisionBitMask = PhysicsCategory.wall | PhysicsCategory.boundary
        ballNode.physicsBody?.restitution = 0.5
        addChild(ballNode)
    }

    private func setupGoal() {
        goalNode.position = CGPoint(x: frame.midX, y: frame.maxY - 100)
        goalNode.physicsBody = SKPhysicsBody(rectangleOf: goalNode.size)
        goalNode.physicsBody?.isDynamic = false
        goalNode.physicsBody?.categoryBitMask = PhysicsCategory.goal
        addChild(goalNode)
    }

    private func setupWalls() {
        let wallSize = CGSize(width: 200, height: 20)
        let wall1 = SKSpriteNode(color: .gray, size: wallSize)
        wall1.position = CGPoint(x: frame.midX, y: frame.midY)
        wall1.physicsBody = SKPhysicsBody(rectangleOf: wallSize)
        wall1.physicsBody?.isDynamic = false
        wall1.physicsBody?.categoryBitMask = PhysicsCategory.wall
        addChild(wall1)
        
        let wall2 = SKSpriteNode(color: .gray, size: CGSize(width: 20, height: 200))
        wall2.position = CGPoint(x: frame.midX - 100, y: frame.midY + 100)
        wall2.physicsBody = SKPhysicsBody(rectangleOf: wall2.size)
        wall2.physicsBody?.isDynamic = false
        wall2.physicsBody?.categoryBitMask = PhysicsCategory.wall
        addChild(wall2)
        
        let wall3 = SKSpriteNode(color: .gray, size: CGSize(width: 200, height: 20))
        wall3.position = CGPoint(x: frame.midX, y: frame.midY - 150)
        wall3.physicsBody = SKPhysicsBody(rectangleOf: wall3.size)
        wall3.physicsBody?.isDynamic = false
        wall3.physicsBody?.categoryBitMask = PhysicsCategory.wall
        addChild(wall3)
    }

    private func setupBoundary() {
        let boundary = SKPhysicsBody(edgeLoopFrom: frame)
        boundary.categoryBitMask = PhysicsCategory.boundary
        self.physicsBody = boundary
    }
    
    private func startMotionUpdates() {
        guard motionManager.isAccelerometerAvailable, motionManager.isGyroAvailable else { return }
        
        motionManager.startAccelerometerUpdates()
        motionManager.startGyroUpdates()
        
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self = self, let motion = motion else { return }
            
            // Using combined acceleration from both accelerometer and gyroscope data
            let gravity = CGVector(dx: motion.gravity.x * 10, dy: motion.gravity.y * 10)
            self.physicsWorld.gravity = gravity
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if contactMask == (PhysicsCategory.ball | PhysicsCategory.goal) {
            // Handle ball reaching the goal
            displayWinMessage()
        }
    }
    
    private func displayWinMessage() {
        let label = SKLabelNode(text: "You Win!")
        label.fontSize = 48
        label.fontColor = .green
        label.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(label)
        
        
        motionManager.stopDeviceMotionUpdates()
        ballNode.removeFromParent()
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            if let self = self {
                label.removeFromParent()
                self.setupBall()
                self.startMotionUpdates()
                self.spendStepsForNextLevel()
            }
        }
    }
    
    private func spendStepsForNextLevel() {
        
        if remainingSteps > 50 {
            remainingSteps -= 50
            
            print("Next level unlocked using steps as currency.")
        } else {
            print("Insufficient steps to unlock next level.")
        }
    }
}
