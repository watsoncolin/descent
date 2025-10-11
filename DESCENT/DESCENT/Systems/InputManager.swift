//
//  InputManager.swift
//  DESCENT
//
//  Handles all touch input for the game
//

import SpriteKit

protocol InputManagerDelegate: AnyObject {
    func inputDidBegin(at location: CGPoint)
    func inputDidMove(to location: CGPoint)
    func inputDidEnd()
    func inputDidCancel()
}

class InputManager {

    // MARK: - Properties

    weak var delegate: InputManagerDelegate?

    private(set) var isTouching: Bool = false
    private(set) var currentTouchLocation: CGPoint?

    // MARK: - Touch Handling

    func handleTouchesBegan(_ touches: Set<UITouch>, in scene: SKScene) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: scene)

        isTouching = true
        currentTouchLocation = location
        delegate?.inputDidBegin(at: location)
    }

    func handleTouchesMoved(_ touches: Set<UITouch>, in scene: SKScene) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: scene)

        currentTouchLocation = location
        delegate?.inputDidMove(to: location)
    }

    func handleTouchesEnded(_ touches: Set<UITouch>, in scene: SKScene) {
        isTouching = false
        currentTouchLocation = nil
        delegate?.inputDidEnd()
    }

    func handleTouchesCancelled(_ touches: Set<UITouch>, in scene: SKScene) {
        isTouching = false
        currentTouchLocation = nil
        delegate?.inputDidCancel()
    }

    // MARK: - Reset

    /// Clear touch state (used when locking movement)
    func reset() {
        isTouching = false
        currentTouchLocation = nil
    }
}
