import SwiftUI
import SpriteKit

struct MazeRunnerGameView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let skView = SKView()
        let scene = MazeRunnerGameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
        
        let viewController = UIViewController()
        viewController.view = skView
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
