//
//  VelvetTileNode.swift
//  BrainTrial
//
//  Mahjong tile visual node
//

import SpriteKit

protocol VelvetTileNodeDelegate: AnyObject {
    func tileNodeWasTapped(_ tileNode: VelvetTileNode)
    func tileNodeDragBegan(_ tileNode: VelvetTileNode, at position: CGPoint)
    func tileNodeDragMoved(_ tileNode: VelvetTileNode, to position: CGPoint)
    func tileNodeDragEnded(_ tileNode: VelvetTileNode, at position: CGPoint)
}

// Make delegate methods optional
extension VelvetTileNodeDelegate {
    func tileNodeDragBegan(_ tileNode: VelvetTileNode, at position: CGPoint) {}
    func tileNodeDragMoved(_ tileNode: VelvetTileNode, to position: CGPoint) {}
    func tileNodeDragEnded(_ tileNode: VelvetTileNode, at position: CGPoint) {}
}

class VelvetTileNode: SKNode {

    // MARK: - Properties
    let tileEssence: VelvetTileEssence?
    private var tileContainer: SKShapeNode!
    private var tileSprite: SKSpriteNode?
    private var selectionGlow: SKShapeNode?

    weak var delegateHandler: VelvetTileNodeDelegate?

    var tileDimension: CGFloat
    var isInteractionEnabled: Bool = true
    var isSelected: Bool = false {
        didSet {
            updateSelectionVisual()
        }
    }
    var isDraggable: Bool = false

    private var initialTouchPosition: CGPoint?
    private var isDragging: Bool = false

    // MARK: - Initialization
    init(tileEssence: VelvetTileEssence?, dimension: CGFloat = 60) {
        self.tileEssence = tileEssence
        self.tileDimension = dimension

        super.init()

        isUserInteractionEnabled = true
        fabricateVisualElements()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Visual Assembly
    private func fabricateVisualElements() {
        // Create tile background shape (3D effect)
        let cornerRadius: CGFloat = tileDimension * 0.12
        let tileRect = CGRect(x: -tileDimension / 2, y: -tileDimension / 2, width: tileDimension, height: tileDimension)

        // Bottom shadow layer
        let shadowPath = UIBezierPath(roundedRect: tileRect.offsetBy(dx: 3, dy: -4), cornerRadius: cornerRadius)
        let shadowShape = SKShapeNode(path: shadowPath.cgPath)
        shadowShape.fillColor = UIColor.black.withAlphaComponent(0.35)
        shadowShape.strokeColor = .clear
        shadowShape.zPosition = -2
        addChild(shadowShape)

        // Side depth layer (3D effect)
        let depthRect = CGRect(x: -tileDimension / 2 + 2, y: -tileDimension / 2 - 4, width: tileDimension, height: tileDimension)
        let depthPath = UIBezierPath(roundedRect: depthRect, cornerRadius: cornerRadius)
        let depthShape = SKShapeNode(path: depthPath.cgPath)
        depthShape.fillColor = UIColor.mahjongTileShadow
        depthShape.strokeColor = .clear
        depthShape.zPosition = -1
        addChild(depthShape)

        // Main tile face
        let tilePath = UIBezierPath(roundedRect: tileRect, cornerRadius: cornerRadius)
        tileContainer = SKShapeNode(path: tilePath.cgPath)
        tileContainer.fillColor = .mahjongTileFace
        tileContainer.strokeColor = UIColor(white: 0.8, alpha: 1.0)
        tileContainer.lineWidth = 1
        tileContainer.zPosition = 0
        addChild(tileContainer)

        // Top highlight for 3D effect
        let highlightRect = CGRect(x: -tileDimension / 2 + 4, y: 4, width: tileDimension - 8, height: tileDimension / 2 - 8)
        let highlightPath = UIBezierPath(roundedRect: highlightRect, cornerRadius: cornerRadius - 2)
        let highlightShape = SKShapeNode(path: highlightPath.cgPath)
        highlightShape.fillColor = UIColor.white.withAlphaComponent(0.3)
        highlightShape.strokeColor = .clear
        highlightShape.zPosition = 1
        tileContainer.addChild(highlightShape)

        // Add tile image if essence exists
        if let essence = tileEssence {
            tileSprite = SKSpriteNode(imageNamed: essence.canvasIdentifier)
            tileSprite?.size = CGSize(width: tileDimension * 0.75, height: tileDimension * 0.75)
            tileSprite?.zPosition = 2
            tileContainer.addChild(tileSprite!)
        }
    }

    // MARK: - Selection Visual
    private func updateSelectionVisual() {
        selectionGlow?.removeFromParent()

        if isSelected {
            let glowRect = CGRect(x: -tileDimension / 2 - 4, y: -tileDimension / 2 - 4, width: tileDimension + 8, height: tileDimension + 8)
            let glowPath = UIBezierPath(roundedRect: glowRect, cornerRadius: tileDimension * 0.15)

            selectionGlow = SKShapeNode(path: glowPath.cgPath)
            selectionGlow?.fillColor = UIColor.aureolaGoldShimmer.withAlphaComponent(0.3)
            selectionGlow?.strokeColor = .aureolaGoldShimmer
            selectionGlow?.lineWidth = 3
            selectionGlow?.zPosition = -0.5
            selectionGlow?.glowWidth = 5
            addChild(selectionGlow!)

            // Pulse animation
            let pulseUp = SKAction.scale(to: 1.05, duration: 0.5)
            let pulseDown = SKAction.scale(to: 1.0, duration: 0.5)
            selectionGlow?.run(SKAction.repeatForever(SKAction.sequence([pulseUp, pulseDown])))
        }
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isInteractionEnabled, let touch = touches.first else { return }

        initialTouchPosition = touch.location(in: parent!)
        isDragging = false

        ZenithHapticOrchestrator.shared.triggerSelectionVibration()
        animatePress()

        if isDraggable {
            delegateHandler?.tileNodeDragBegan(self, at: initialTouchPosition!)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isInteractionEnabled, isDraggable, let touch = touches.first else { return }

        let currentPosition = touch.location(in: parent!)

        if let initial = initialTouchPosition {
            let distance = currentPosition.euclideanDistance(to: initial)
            if distance > 10 {
                isDragging = true
            }
        }

        if isDragging {
            position = currentPosition
            delegateHandler?.tileNodeDragMoved(self, to: currentPosition)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isInteractionEnabled, let touch = touches.first else { return }

        animateRelease()

        let endPosition = touch.location(in: parent!)

        if isDraggable && isDragging {
            delegateHandler?.tileNodeDragEnded(self, at: endPosition)
        } else {
            delegateHandler?.tileNodeWasTapped(self)
        }

        isDragging = false
        initialTouchPosition = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        animateRelease()
        isDragging = false
        initialTouchPosition = nil
    }

    // MARK: - Animations
    private func animatePress() {
        let scaleDown = SKAction.scale(to: 0.92, duration: 0.08)
        scaleDown.timingMode = .easeOut
        run(scaleDown)
    }

    private func animateRelease() {
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.12)
        scaleUp.timingMode = .easeOut
        run(scaleUp)
    }

    func animateCorrectPlacement() {
        let flash = SKAction.sequence([
            SKAction.run { self.tileContainer.fillColor = UIColor.celadonMintFresh },
            SKAction.wait(forDuration: 0.15),
            SKAction.run { self.tileContainer.fillColor = .mahjongTileFace }
        ])
        run(SKAction.repeat(flash, count: 2))
    }

    func animateIncorrectPlacement() {
        prismaticShakeMotion(intensity: 8, duration: 0.3)
        let flash = SKAction.sequence([
            SKAction.run { self.tileContainer.fillColor = UIColor.crimsonEmberGlow.withAlphaComponent(0.3) },
            SKAction.wait(forDuration: 0.1),
            SKAction.run { self.tileContainer.fillColor = .mahjongTileFace }
        ])
        run(SKAction.repeat(flash, count: 2))
    }
}

// MARK: - Empty Slot Node
class VacantSlotNode: SKNode {

    private var slotContainer: SKShapeNode!
    let slotIndex: Int
    var slotDimension: CGFloat
    var isHighlighted: Bool = false {
        didSet {
            updateHighlightVisual()
        }
    }

    var tapHandler: ((VacantSlotNode) -> Void)?

    init(index: Int, dimension: CGFloat = 60) {
        self.slotIndex = index
        self.slotDimension = dimension

        super.init()

        isUserInteractionEnabled = true
        fabricateVisualElements()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func fabricateVisualElements() {
        let cornerRadius: CGFloat = slotDimension * 0.12
        let slotRect = CGRect(x: -slotDimension / 2, y: -slotDimension / 2, width: slotDimension, height: slotDimension)
        let slotPath = UIBezierPath(roundedRect: slotRect, cornerRadius: cornerRadius)

        slotContainer = SKShapeNode(path: slotPath.cgPath)
        slotContainer.fillColor = UIColor.black.withAlphaComponent(0.2)
        slotContainer.strokeColor = UIColor.white.withAlphaComponent(0.5)
        slotContainer.lineWidth = 2
        addChild(slotContainer)

        // Question mark indicator
        let questionLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        questionLabel.text = "?"
        questionLabel.fontSize = slotDimension * 0.5
        questionLabel.fontColor = UIColor.white.withAlphaComponent(0.4)
        questionLabel.verticalAlignmentMode = .center
        questionLabel.horizontalAlignmentMode = .center
        addChild(questionLabel)
    }

    private func updateHighlightVisual() {
        if isHighlighted {
            slotContainer.strokeColor = .aureolaGoldShimmer
            slotContainer.lineWidth = 3
            slotContainer.glowWidth = 3
        } else {
            slotContainer.strokeColor = UIColor.white.withAlphaComponent(0.5)
            slotContainer.lineWidth = 2
            slotContainer.glowWidth = 0
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        ZenithHapticOrchestrator.shared.triggerSelectionVibration()
        isHighlighted = true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: parent!)
            if contains(location) {
                tapHandler?(self)
            }
        }
        isHighlighted = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isHighlighted = false
    }
}
