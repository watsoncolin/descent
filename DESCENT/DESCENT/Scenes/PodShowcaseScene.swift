//
//  PodShowcaseScene.swift
//  DESCENT
//
//  Debug scene to showcase all pod upgrade combinations
//

import SpriteKit

class PodShowcaseScene: SKScene {

    private var pods: [[PlayerPod]] = []
    private var labels: [SKLabelNode] = []

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.1, green: 0.05, blue: 0.15, alpha: 1.0)

        // Disable physics for showcase scene
        physicsWorld.gravity = .zero

        setupShowcase()
    }

    private func setupShowcase() {
        // Title
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "POD UPGRADE SHOWCASE"
        title.fontSize = 24
        title.fontColor = .white
        title.position = CGPoint(x: frame.midX, y: frame.maxY - 50)
        addChild(title)

        let subtitle = SKLabelNode(fontNamed: "AvenirNext-Regular")
        subtitle.text = "Tap anywhere to return to game"
        subtitle.fontSize = 14
        subtitle.fontColor = UIColor(white: 0.7, alpha: 1.0)
        subtitle.position = CGPoint(x: frame.midX, y: frame.maxY - 80)
        addChild(subtitle)

        // Create grid layout
        let startY = frame.maxY - 150
        let spacing: CGFloat = 100

        // Section 1: Drill Strength Levels
        addSectionLabel("DRILL STRENGTH", at: CGPoint(x: frame.midX, y: startY))
        createPodRow(
            startY: startY - 30,
            configs: [
                (drill: 1, hull: 1, engine: 1, label: "Lv 1"),
                (drill: 2, hull: 1, engine: 1, label: "Lv 2"),
                (drill: 3, hull: 1, engine: 1, label: "Lv 3"),
                (drill: 4, hull: 1, engine: 1, label: "Lv 4"),
                (drill: 5, hull: 1, engine: 1, label: "Lv 5")
            ]
        )

        // Section 2: Hull Armor Levels
        addSectionLabel("HULL ARMOR", at: CGPoint(x: frame.midX, y: startY - spacing))
        createPodRow(
            startY: startY - spacing - 30,
            configs: [
                (drill: 1, hull: 1, engine: 1, label: "Lv 1"),
                (drill: 1, hull: 2, engine: 1, label: "Lv 2"),
                (drill: 1, hull: 3, engine: 1, label: "Lv 3"),
                (drill: 1, hull: 4, engine: 1, label: "Lv 4"),
                (drill: 1, hull: 5, engine: 1, label: "Lv 5"),
                (drill: 1, hull: 6, engine: 1, label: "Lv 6")
            ]
        )

        // Section 3: Engine Speed Levels
        addSectionLabel("ENGINE SPEED", at: CGPoint(x: frame.midX, y: startY - spacing * 2))
        createPodRow(
            startY: startY - spacing * 2 - 30,
            configs: [
                (drill: 1, hull: 1, engine: 1, label: "Lv 1"),
                (drill: 1, hull: 1, engine: 2, label: "Lv 2"),
                (drill: 1, hull: 1, engine: 3, label: "Lv 3"),
                (drill: 1, hull: 1, engine: 4, label: "Lv 4"),
                (drill: 1, hull: 1, engine: 5, label: "Lv 5")
            ]
        )

        // Section 4: Combined Examples
        addSectionLabel("COMBINED UPGRADES", at: CGPoint(x: frame.midX, y: startY - spacing * 3))
        createPodRow(
            startY: startY - spacing * 3 - 30,
            configs: [
                (drill: 1, hull: 1, engine: 1, label: "Basic"),
                (drill: 3, hull: 3, engine: 3, label: "Mid Tier"),
                (drill: 5, hull: 6, engine: 5, label: "Max Power"),
                (drill: 2, hull: 5, engine: 1, label: "Tank Build"),
                (drill: 5, hull: 2, engine: 5, label: "Speed Build")
            ]
        )

        // Section 5: Progressive Upgrade Path
        addSectionLabel("PROGRESSION EXAMPLE", at: CGPoint(x: frame.midX, y: startY - spacing * 4))
        createPodRow(
            startY: startY - spacing * 4 - 30,
            configs: [
                (drill: 1, hull: 1, engine: 1, label: "Start"),
                (drill: 2, hull: 2, engine: 1, label: "Early"),
                (drill: 3, hull: 3, engine: 2, label: "Mid"),
                (drill: 4, hull: 4, engine: 3, label: "Late"),
                (drill: 5, hull: 5, engine: 4, label: "End"),
                (drill: 5, hull: 6, engine: 5, label: "Max")
            ]
        )
    }

    private func addSectionLabel(_ text: String, at position: CGPoint) {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = 18
        label.fontColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)  // Gold
        label.position = position
        addChild(label)
    }

    private func createPodRow(startY: CGFloat, configs: [(drill: Int, hull: Int, engine: Int, label: String)]) {
        let totalWidth = frame.width * 0.9
        let spacing = totalWidth / CGFloat(configs.count)
        let startX = (frame.width - totalWidth) / 2 + spacing / 2

        for (index, config) in configs.enumerated() {
            let x = startX + CGFloat(index) * spacing
            let y = startY

            // Create pod
            let pod = PlayerPod()
            pod.position = CGPoint(x: x, y: y)
            pod.updateUpgrades(drillLevel: config.drill, hullLevel: config.hull, engineLevel: config.engine)

            // Disable physics for showcase (these are static displays)
            pod.physicsBody?.isDynamic = false
            pod.physicsBody?.affectedByGravity = false

            addChild(pod)

            // Add label below pod
            let label = SKLabelNode(fontNamed: "AvenirNext-Regular")
            label.text = config.label
            label.fontSize = 12
            label.fontColor = .white
            label.position = CGPoint(x: x, y: y - 35)
            addChild(label)

            // Add detail labels (smaller, showing D/H/E levels)
            let detailLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
            detailLabel.text = "D:\(config.drill) H:\(config.hull) E:\(config.engine)"
            detailLabel.fontSize = 9
            detailLabel.fontColor = UIColor(white: 0.6, alpha: 1.0)
            detailLabel.position = CGPoint(x: x, y: y - 48)
            addChild(detailLabel)

            // Add background panel for each pod
            let panel = SKShapeNode(rectOf: CGSize(width: spacing * 0.9, height: 90), cornerRadius: 5)
            panel.fillColor = UIColor(white: 0.1, alpha: 0.3)
            panel.strokeColor = UIColor(white: 0.3, alpha: 0.5)
            panel.lineWidth = 1
            panel.position = CGPoint(x: x, y: y - 5)
            panel.zPosition = -1
            addChild(panel)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Return to game scene
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = .aspectFill
        view?.presentScene(gameScene, transition: SKTransition.fade(withDuration: 0.5))
    }
}
