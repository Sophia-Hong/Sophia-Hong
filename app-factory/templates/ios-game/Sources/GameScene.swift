import SpriteKit

/// Minimal tap-to-score scene. ios-builder replaces game logic per SPEC.md; keep the Score/GameOver hooks.
final class GameScene: SKScene {
    private let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private(set) var score = 0 { didSet { scoreLabel.text = "\(score)" } }
    private var target = SKShapeNode(circleOfRadius: 36)

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.07, green: 0.08, blue: 0.12, alpha: 1)
        scoreLabel.fontSize = 48
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 120)
        scoreLabel.text = "0"
        addChild(scoreLabel)
        target.fillColor = .systemOrange
        target.strokeColor = .clear
        addChild(target)
        moveTarget()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let p = touches.first?.location(in: self) else { return }
        if target.contains(p) {
            score += 1
            run(SKAction.playSoundFileNamed("tap.caf", waitForCompletion: false))
            moveTarget()
        }
    }

    private func moveTarget() {
        let x = CGFloat.random(in: 60...(size.width - 60))
        let y = CGFloat.random(in: 120...(size.height - 200))
        target.run(.move(to: CGPoint(x: x, y: y), duration: 0.15))
    }
}
