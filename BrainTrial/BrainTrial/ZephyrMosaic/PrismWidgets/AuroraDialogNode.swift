//
//  AuroraDialogNode.swift
//  BrainTrial
//
//  Custom modal dialog node
//

import SpriteKit

class AuroraDialogNode: SKNode {

    // MARK: - Properties
    private var backdropOverlay: SKShapeNode!
    private var dialogContainer: SKShapeNode!
    private var titleLabel: SKLabelNode!
    private var messageLabel: SKLabelNode?
    private var contentContainer: SKNode!
    private var buttonContainer: SKNode!

    private let dialogWidth: CGFloat
    private let dialogMinHeight: CGFloat

    var dismissHandler: (() -> Void)?

    // MARK: - Initialization
    init(title: String, width: CGFloat = 300, minHeight: CGFloat = 200) {
        self.dialogWidth = width
        self.dialogMinHeight = minHeight

        super.init()

        isUserInteractionEnabled = true
        fabricateBackdrop()
        fabricateDialogFrame(title: title)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Visual Assembly
    private func fabricateBackdrop() {
        let screenSize = CGSize(width: HorizonCanvasMeasure.canvasWidth, height: HorizonCanvasMeasure.canvasHeight)
        backdropOverlay = SKShapeNode(rectOf: screenSize)
        backdropOverlay.fillColor = UIColor.black.withAlphaComponent(0.6)
        backdropOverlay.strokeColor = .clear
        backdropOverlay.zPosition = 0
        addChild(backdropOverlay)
    }

    private func fabricateDialogFrame(title: String) {
        // Dialog background with shadow
        let shadowRect = CGRect(x: -dialogWidth / 2 + 5, y: -dialogMinHeight / 2 - 8, width: dialogWidth, height: dialogMinHeight)
        let shadowPath = UIBezierPath(roundedRect: shadowRect, cornerRadius: 20)
        let shadowShape = SKShapeNode(path: shadowPath.cgPath)
        shadowShape.fillColor = UIColor.black.withAlphaComponent(0.4)
        shadowShape.strokeColor = .clear
        shadowShape.zPosition = 1
        addChild(shadowShape)

        // Main dialog
        let dialogRect = CGRect(x: -dialogWidth / 2, y: -dialogMinHeight / 2, width: dialogWidth, height: dialogMinHeight)
        let dialogPath = UIBezierPath(roundedRect: dialogRect, cornerRadius: 20)
        dialogContainer = SKShapeNode(path: dialogPath.cgPath)
        dialogContainer.fillColor = UIColor(white: 0.15, alpha: 0.98)
        dialogContainer.strokeColor = UIColor.mahjongAccentGold.withAlphaComponent(0.5)
        dialogContainer.lineWidth = 2
        dialogContainer.zPosition = 2
        addChild(dialogContainer)

        // Gradient header
        let headerHeight: CGFloat = 60
        let headerRect = CGRect(x: -dialogWidth / 2 + 2, y: dialogMinHeight / 2 - headerHeight - 2, width: dialogWidth - 4, height: headerHeight)
        let headerPath = UIBezierPath(roundedRect: headerRect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 18, height: 18))
        let headerShape = SKShapeNode(path: headerPath.cgPath)
        headerShape.fillColor = UIColor.mahjongTableFelt
        headerShape.strokeColor = .clear
        headerShape.zPosition = 3
        dialogContainer.addChild(headerShape)

        // Title
        titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = title
        titleLabel.fontSize = 22
        titleLabel.fontColor = .mahjongAccentGold
        titleLabel.verticalAlignmentMode = .center
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.position = CGPoint(x: 0, y: dialogMinHeight / 2 - headerHeight / 2 - 2)
        titleLabel.zPosition = 4
        dialogContainer.addChild(titleLabel)

        // Content container
        contentContainer = SKNode()
        contentContainer.position = CGPoint(x: 0, y: 20)
        contentContainer.zPosition = 3
        dialogContainer.addChild(contentContainer)

        // Button container
        buttonContainer = SKNode()
        buttonContainer.position = CGPoint(x: 0, y: -dialogMinHeight / 2 + 50)
        buttonContainer.zPosition = 3
        dialogContainer.addChild(buttonContainer)
    }

    // MARK: - Public Methods
    func setMessageText(_ message: String) {
        messageLabel?.removeFromParent()

        messageLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        messageLabel?.text = message
        messageLabel?.fontSize = 16
        messageLabel?.fontColor = .ivoryMistWhite
        messageLabel?.verticalAlignmentMode = .center
        messageLabel?.horizontalAlignmentMode = .center
        messageLabel?.preferredMaxLayoutWidth = dialogWidth - 40
        messageLabel?.numberOfLines = 0
        contentContainer.addChild(messageLabel!)
    }

    func appendActionButton(title: String, chromaStart: UIColor, chromaEnd: UIColor, handler: @escaping () -> Void) {
        let buttonWidth: CGFloat = dialogWidth - 60
        let button = ObsidianButtonNode(labelText: title, chromaStart: chromaStart, chromaEnd: chromaEnd, width: buttonWidth, height: 48, curvature: 10)
        button.tapHandler = { [weak self] in
            handler()
            self?.animateDismissal()
        }

        let existingButtons = buttonContainer.children.count
        button.position = CGPoint(x: 0, y: CGFloat(existingButtons) * -60)
        buttonContainer.addChild(button)
    }

    func appendCustomContent(_ node: SKNode) {
        contentContainer.addChild(node)
    }

    // MARK: - Animation
    func animatePresentation() {
        backdropOverlay.alpha = 0
        dialogContainer.alpha = 0
        dialogContainer.setScale(0.8)

        let fadeBackdrop = SKAction.fadeAlpha(to: 1, duration: 0.2)
        let fadeDialog = SKAction.fadeIn(withDuration: 0.25)
        let scaleDialog = SKAction.scale(to: 1.0, duration: 0.25)
        scaleDialog.timingMode = .easeOut

        backdropOverlay.run(fadeBackdrop)
        dialogContainer.run(SKAction.group([fadeDialog, scaleDialog]))

        ZenithHapticOrchestrator.shared.triggerImpactVibration(style: .medium)
    }

    func animateDismissal() {
        let fadeBackdrop = SKAction.fadeOut(withDuration: 0.2)
        let fadeDialog = SKAction.fadeOut(withDuration: 0.15)
        let scaleDialog = SKAction.scale(to: 0.85, duration: 0.15)

        backdropOverlay.run(fadeBackdrop)
        dialogContainer.run(SKAction.group([fadeDialog, scaleDialog])) { [weak self] in
            self?.dismissHandler?()
            self?.removeFromParent()
        }
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Prevent touches from passing through
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Check if tap is outside dialog (on backdrop)
        if !dialogContainer.contains(location) {
            animateDismissal()
        }
    }
}

// MARK: - Victory Dialog
class TriumphCelebrationDialog: AuroraDialogNode {

    init(score: Int, attempts: Int, difficulty: QuasarDifficultyTier) {
        super.init(title: "Victory!", width: 320, minHeight: 280)

        fabricateVictoryContent(score: score, attempts: attempts, difficulty: difficulty)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func fabricateVictoryContent(score: Int, attempts: Int, difficulty: QuasarDifficultyTier) {
        // Trophy icon
        let trophyConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .bold)
        if let trophyImage = UIImage(systemName: "trophy.fill", withConfiguration: trophyConfig) {
            let texture = SKTexture(image: trophyImage.withTintColor(.aureolaGoldShimmer, renderingMode: .alwaysTemplate))
            let trophySprite = SKSpriteNode(texture: texture)
            trophySprite.colorBlendFactor = 1.0
            trophySprite.color = .aureolaGoldShimmer
            trophySprite.position = CGPoint(x: 0, y: 50)

            // Pulsing animation
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.1, duration: 0.5),
                SKAction.scale(to: 1.0, duration: 0.5)
            ])
            trophySprite.run(SKAction.repeatForever(pulse))

            appendCustomContent(trophySprite)
        }

        // Score display
        let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.text = "+\(score) Points"
        scoreLabel.fontSize = 28
        scoreLabel.fontColor = .aureolaGoldShimmer
        scoreLabel.position = CGPoint(x: 0, y: 0)
        appendCustomContent(scoreLabel)

        // Attempts info
        let attemptsLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        attemptsLabel.text = "Completed in \(attempts) attempts"
        attemptsLabel.fontSize = 16
        attemptsLabel.fontColor = .ivoryMistWhite
        attemptsLabel.position = CGPoint(x: 0, y: -30)
        appendCustomContent(attemptsLabel)

        // Difficulty badge
        let difficultyLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        difficultyLabel.text = difficulty.celestialTitle + " Mode"
        difficultyLabel.fontSize = 14
        difficultyLabel.fontColor = difficulty.accentGradient.first ?? .white
        difficultyLabel.position = CGPoint(x: 0, y: -55)
        appendCustomContent(difficultyLabel)
    }
}

// MARK: - How To Play Dialog
class EnigmaGuideDialog: AuroraDialogNode {

    init() {
        super.init(title: "How To Play", width: 340, minHeight: 480)
        fabricateGuideContent()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func fabricateGuideContent() {
        let instructions = [
            ("1.", "Observe the tile pattern with missing pieces"),
            ("2.", "Select a tile from your hand below"),
            ("3.", "Tap an empty slot to place your tile"),
            ("4.", "Green ✓ = correct, Red ✗ = wrong"),
            ("5.", "Fill all slots correctly to win!")
        ]

        var yOffset: CGFloat = 110

        for (number, text) in instructions {
            let numberLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            numberLabel.text = number
            numberLabel.fontSize = 18
            numberLabel.fontColor = .mahjongAccentGold
            numberLabel.horizontalAlignmentMode = .left
            numberLabel.position = CGPoint(x: -140, y: yOffset)
            appendCustomContent(numberLabel)

            let textLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
            textLabel.text = text
            textLabel.fontSize = 14
            textLabel.fontColor = .ivoryMistWhite
            textLabel.horizontalAlignmentMode = .left
            textLabel.preferredMaxLayoutWidth = 250
            textLabel.numberOfLines = 2
            textLabel.position = CGPoint(x: -110, y: yOffset)
            appendCustomContent(textLabel)

            yOffset -= 42
        }

        // Scoring info
        let scoringTitle = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoringTitle.text = "Scoring"
        scoringTitle.fontSize = 16
        scoringTitle.fontColor = .mahjongAccentGold
        scoringTitle.position = CGPoint(x: 0, y: yOffset - 15)
        appendCustomContent(scoringTitle)

        let scoringInfo = SKLabelNode(fontNamed: "AvenirNext-Regular")
        scoringInfo.text = "Fewer attempts = Higher score!"
        scoringInfo.fontSize = 13
        scoringInfo.fontColor = .ivoryMistWhite
        scoringInfo.position = CGPoint(x: 0, y: yOffset - 38)
        appendCustomContent(scoringInfo)
    }
}

// MARK: - Rate App Dialog
class StellarRatingDialog: AuroraDialogNode {

    private var starNodes: [SKSpriteNode] = []
    private var selectedRating: Int = 0

    init() {
        super.init(title: "Rate This App", width: 320, minHeight: 260)
        fabricateRatingContent()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func fabricateRatingContent() {
        // Message
        let messageLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        messageLabel.text = "Enjoying Mahjong Brain Trial?"
        messageLabel.fontSize = 16
        messageLabel.fontColor = .ivoryMistWhite
        messageLabel.position = CGPoint(x: 0, y: 50)
        appendCustomContent(messageLabel)

        let subMessage = SKLabelNode(fontNamed: "AvenirNext-Regular")
        subMessage.text = "Your feedback helps us improve!"
        subMessage.fontSize = 13
        subMessage.fontColor = UIColor.ivoryMistWhite.withAlphaComponent(0.7)
        subMessage.position = CGPoint(x: 0, y: 25)
        appendCustomContent(subMessage)

        // Stars container
        let starContainer = SKNode()
        starContainer.position = CGPoint(x: 0, y: -15)
        appendCustomContent(starContainer)

        let starSize: CGFloat = 40
        let spacing: CGFloat = 50

        for i in 0..<5 {
            let starConfig = UIImage.SymbolConfiguration(pointSize: starSize, weight: .regular)
            let starImage = UIImage(systemName: "star", withConfiguration: starConfig)!
            let texture = SKTexture(image: starImage.withTintColor(.aureolaGoldShimmer, renderingMode: .alwaysTemplate))

            let starNode = SKSpriteNode(texture: texture)
            starNode.colorBlendFactor = 1.0
            starNode.color = UIColor.aureolaGoldShimmer.withAlphaComponent(0.4)
            starNode.position = CGPoint(x: CGFloat(i - 2) * spacing, y: 0)
            starNode.name = "star_\(i)"

            starContainer.addChild(starNode)
            starNodes.append(starNode)
        }

        // Make stars interactive
        starContainer.isUserInteractionEnabled = false
    }

    func handleStarSelection(at location: CGPoint) {
        for (index, star) in starNodes.enumerated() {
            let starPosition = star.convert(star.position, to: self)
            if abs(location.x - starPosition.x) < 30 && abs(location.y - starPosition.y + 15) < 30 {
                updateStarRating(index + 1)
                ZenithHapticOrchestrator.shared.triggerSelectionVibration()
                break
            }
        }
    }

    private func updateStarRating(_ rating: Int) {
        selectedRating = rating

        for (index, star) in starNodes.enumerated() {
            let starConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
            let imageName = index < rating ? "star.fill" : "star"
            let starImage = UIImage(systemName: imageName, withConfiguration: starConfig)!
            let texture = SKTexture(image: starImage.withTintColor(.aureolaGoldShimmer, renderingMode: .alwaysTemplate))

            star.texture = texture
            star.color = index < rating ? .aureolaGoldShimmer : UIColor.aureolaGoldShimmer.withAlphaComponent(0.4)

            if index < rating {
                star.run(SKAction.sequence([
                    SKAction.scale(to: 1.3, duration: 0.1),
                    SKAction.scale(to: 1.0, duration: 0.1)
                ]))
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Check star taps
        handleStarSelection(at: location)

        // Check backdrop tap
        if let dialogContainer = children.first(where: { $0 is SKShapeNode && $0.zPosition == 2 }) {
            if !dialogContainer.contains(location) {
                animateDismissal()
            }
        }
    }
}
