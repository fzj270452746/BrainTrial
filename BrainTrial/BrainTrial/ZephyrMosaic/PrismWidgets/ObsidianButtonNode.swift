//
//  ObsidianButtonNode.swift
//  BrainTrial
//
//  Custom styled button node for SpriteKit
//

import SpriteKit

class ObsidianButtonNode: SKNode {

    // MARK: - Properties
    private var canvasShape: SKShapeNode!
    private var glyphLabel: SKLabelNode!
    private var iconSprite: SKSpriteNode?
    private var gradientOverlay: SKSpriteNode?

    private let chromaStart: UIColor
    private let chromaEnd: UIColor
    private let dimensionWidth: CGFloat
    private let dimensionHeight: CGFloat
    private let curvatureRadius: CGFloat

    var tapHandler: (() -> Void)?
    var isInteractionEnabled: Bool = true

    // MARK: - Initialization
    init(
        labelText: String,
        chromaStart: UIColor,
        chromaEnd: UIColor,
        width: CGFloat = 200,
        height: CGFloat = 56,
        curvature: CGFloat = 12,
        iconName: String? = nil
    ) {
        self.chromaStart = chromaStart
        self.chromaEnd = chromaEnd
        self.dimensionWidth = width
        self.dimensionHeight = height
        self.curvatureRadius = curvature

        super.init()

        isUserInteractionEnabled = true
        fabricateVisualElements(labelText: labelText, iconName: iconName)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Visual Assembly
    private func fabricateVisualElements(labelText: String, iconName: String?) {
        // Create base shape with rounded corners
        let pathRect = CGRect(x: -dimensionWidth / 2, y: -dimensionHeight / 2, width: dimensionWidth, height: dimensionHeight)
        let roundedPath = UIBezierPath(roundedRect: pathRect, cornerRadius: curvatureRadius)

        canvasShape = SKShapeNode(path: roundedPath.cgPath)
        canvasShape.fillColor = chromaStart
        canvasShape.strokeColor = chromaStart.luminanceAdjusted(by: 0.7)
        canvasShape.lineWidth = 2
        addChild(canvasShape)

        // Add gradient effect using multiple layers
        let highlightPath = UIBezierPath(roundedRect: CGRect(x: -dimensionWidth / 2 + 2, y: 0, width: dimensionWidth - 4, height: dimensionHeight / 2 - 2), cornerRadius: curvatureRadius - 2)
        let highlight = SKShapeNode(path: highlightPath.cgPath)
        highlight.fillColor = UIColor.white.withAlphaComponent(0.15)
        highlight.strokeColor = .clear
        canvasShape.addChild(highlight)

        // Add shadow effect
        let shadowShape = SKShapeNode(path: roundedPath.cgPath)
        shadowShape.fillColor = UIColor.black.withAlphaComponent(0.3)
        shadowShape.strokeColor = .clear
        shadowShape.position = CGPoint(x: 2, y: -3)
        shadowShape.zPosition = -1
        addChild(shadowShape)

        // Create label
        glyphLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        glyphLabel.text = labelText
        glyphLabel.fontSize = min(16, dimensionHeight * 0.32)
        glyphLabel.fontColor = .white
        glyphLabel.verticalAlignmentMode = .center
        glyphLabel.horizontalAlignmentMode = .center

        // Add icon if provided
        if let iconName = iconName {
            let iconSize = min(20, dimensionHeight * 0.4)
            let iconConfig = UIImage.SymbolConfiguration(pointSize: iconSize, weight: .bold)
            if let iconImage = UIImage(systemName: iconName, withConfiguration: iconConfig) {
                let texture = SKTexture(image: iconImage.withTintColor(.white, renderingMode: .alwaysTemplate))
                iconSprite = SKSpriteNode(texture: texture)
                iconSprite?.size = CGSize(width: iconSize, height: iconSize)
                iconSprite?.position = CGPoint(x: -dimensionWidth / 2 + iconSize / 2 + 12, y: 0)
                iconSprite?.colorBlendFactor = 1.0
                iconSprite?.color = .white
                addChild(iconSprite!)

                // Position label to the right of icon
                glyphLabel.horizontalAlignmentMode = .left
                glyphLabel.position = CGPoint(x: -dimensionWidth / 2 + iconSize + 20, y: 0)
            } else {
                glyphLabel.position = .zero
            }
        } else {
            glyphLabel.position = .zero
        }

        addChild(glyphLabel)
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isInteractionEnabled else { return }
        ZenithHapticOrchestrator.shared.triggerSelectionVibration()
        animateDepression()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isInteractionEnabled else { return }

        animateRelease()

        if let touch = touches.first {
            let location = touch.location(in: parent!)
            if contains(location) {
                tapHandler?()
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        animateRelease()
    }

    // MARK: - Animations
    private func animateDepression() {
        let scaleDown = SKAction.scale(to: 0.95, duration: 0.08)
        scaleDown.timingMode = .easeOut
        run(scaleDown)
        canvasShape.fillColor = chromaEnd
    }

    private func animateRelease() {
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        scaleUp.timingMode = .easeOut
        run(scaleUp)
        canvasShape.fillColor = chromaStart
    }

    // MARK: - Public Methods
    func updateGlyphText(_ text: String) {
        glyphLabel.text = text
    }

    func setInteractionState(_ enabled: Bool) {
        isInteractionEnabled = enabled
        alpha = enabled ? 1.0 : 0.5
    }
}

// MARK: - Icon Button Variant
class CrystalIconButton: SKNode {

    private var circleShape: SKShapeNode!
    private var iconSprite: SKSpriteNode!
    private let chromaTint: UIColor
    private let circleDiameter: CGFloat

    var tapHandler: (() -> Void)?
    var isInteractionEnabled: Bool = true

    init(systemIconName: String, chromaTint: UIColor, diameter: CGFloat = 50) {
        self.chromaTint = chromaTint
        self.circleDiameter = diameter

        super.init()

        isUserInteractionEnabled = true
        fabricateVisualElements(systemIconName: systemIconName)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func fabricateVisualElements(systemIconName: String) {
        // Circle background
        circleShape = SKShapeNode(circleOfRadius: circleDiameter / 2)
        circleShape.fillColor = chromaTint
        circleShape.strokeColor = chromaTint.luminanceAdjusted(by: 0.7)
        circleShape.lineWidth = 2
        addChild(circleShape)

        // Shadow
        let shadow = SKShapeNode(circleOfRadius: circleDiameter / 2)
        shadow.fillColor = UIColor.black.withAlphaComponent(0.25)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 2, y: -3)
        shadow.zPosition = -1
        addChild(shadow)

        // Icon
        let iconConfig = UIImage.SymbolConfiguration(pointSize: circleDiameter * 0.45, weight: .semibold)
        if let iconImage = UIImage(systemName: systemIconName, withConfiguration: iconConfig) {
            let texture = SKTexture(image: iconImage.withTintColor(.white, renderingMode: .alwaysTemplate))
            iconSprite = SKSpriteNode(texture: texture)
            iconSprite.colorBlendFactor = 1.0
            iconSprite.color = .white
            addChild(iconSprite)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isInteractionEnabled else { return }
        ZenithHapticOrchestrator.shared.triggerSelectionVibration()
        run(SKAction.scale(to: 0.9, duration: 0.08))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isInteractionEnabled else { return }
        run(SKAction.scale(to: 1.0, duration: 0.1))

        if let touch = touches.first {
            let location = touch.location(in: parent!)
            if contains(location) {
                tapHandler?()
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        run(SKAction.scale(to: 1.0, duration: 0.1))
    }
}
