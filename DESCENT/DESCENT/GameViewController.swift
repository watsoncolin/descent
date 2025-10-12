import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let view = self.view as? SKView else { return }

        // Create and configure the scene
        let scene = GameScene(size: view.bounds.size)
        scene.scaleMode = .aspectFill

        // Present the scene
        view.presentScene(scene)

        // CRITICAL: Disable any caching/optimization that might create large textures
        view.ignoresSiblingOrder = true  // Prevents internal render optimization
        view.allowsTransparency = false  // Prevents alpha blending buffer
        view.shouldCullNonVisibleNodes = true  // Only render visible nodes

        // Debug settings (disable for production)
        view.showsFPS = true
        view.showsNodeCount = true
        view.showsPhysics = false // Enable when debugging physics
    }

    override var prefersStatusBarHidden: Bool {
        return true // Hide status bar for fullscreen game
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
