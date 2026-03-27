//
//  CelestialHomeScene.swift
//  BrainTrial
//
//  Main menu home scene
//

import SpriteKit

class CelestialHomeScene: SKScene {

    // MARK: - Properties
    private var backgroundNode: SKSpriteNode!
    private var titleContainer: SKNode!
    private var menuContainer: SKNode!
    private var scoreDisplayLabel: SKLabelNode!
    private var ambientParticles: SKEmitterNode?

    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        backgroundColor = .mahjongTableFelt
        fabricateSceneElements()
        animateSceneEntry()
    }

    // MARK: - Scene Construction
    private func fabricateSceneElements() {
        synthesizeBackground()
        synthesizeTitleSection()
        synthesizeMenuButtons()
        synthesizeScoreDisplay()
        synthesizeAmbientEffects()
        synthesizeFooterButtons()
    }

    private func synthesizeBackground() {
        // Gradient background
        let gradientTexture = createGradientTexture(
            size: size,
            colors: [
                UIColor(red: 0.08, green: 0.22, blue: 0.16, alpha: 1.0),
                UIColor(red: 0.12, green: 0.30, blue: 0.22, alpha: 1.0),
                UIColor(red: 0.06, green: 0.18, blue: 0.12, alpha: 1.0)
            ]
        )

        backgroundNode = SKSpriteNode(texture: gradientTexture)
        backgroundNode.size = size
        backgroundNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundNode.zPosition = -10
        addChild(backgroundNode)

        // Decorative pattern overlay
        let patternNode = createDecorativePattern()
        patternNode.zPosition = -9
        addChild(patternNode)
    }

    private func synthesizeTitleSection() {
        titleContainer = SKNode()
        let isCompact = HorizonCanvasMeasure.isCompactDevice
        let titleY = isCompact ? size.height * 0.82 : size.height * 0.78
        titleContainer.position = CGPoint(x: size.width / 2, y: titleY)
        addChild(titleContainer)

        let titleFontSize: CGFloat = isCompact ? 38 : 48 * HorizonCanvasMeasure.proportionalScale
        let subtitleFontSize: CGFloat = isCompact ? 22 : 28 * HorizonCanvasMeasure.proportionalScale

        // Main title with shadow
        let titleShadow = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        titleShadow.text = "Mahjong"
        titleShadow.fontSize = titleFontSize
        titleShadow.fontColor = UIColor.black.withAlphaComponent(0.4)
        titleShadow.position = CGPoint(x: 3, y: -3)
        titleContainer.addChild(titleShadow)

        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        titleLabel.text = "Mahjong"
        titleLabel.fontSize = titleFontSize
        titleLabel.fontColor = .mahjongAccentGold
        titleLabel.position = .zero
        titleContainer.addChild(titleLabel)

        // Subtitle
        let subtitleLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        subtitleLabel.text = "Brain Trial"
        subtitleLabel.fontSize = subtitleFontSize
        subtitleLabel.fontColor = .ivoryMistWhite
        subtitleLabel.position = CGPoint(x: 0, y: isCompact ? -35 : -45)
        titleContainer.addChild(subtitleLabel)

        // Decorative mahjong tiles display
        let tilesDisplay = createDecorativeTilesDisplay()
        tilesDisplay.position = CGPoint(x: 0, y: isCompact ? -80 : -110)
        titleContainer.addChild(tilesDisplay)
    }

    private func synthesizeMenuButtons() {
        menuContainer = SKNode()
        let isCompact = HorizonCanvasMeasure.isCompactDevice
        let menuY = isCompact ? size.height * 0.38 : size.height * 0.42
        menuContainer.position = CGPoint(x: size.width / 2, y: menuY)
        addChild(menuContainer)

        let buttonWidth: CGFloat = min(280, size.width - 60)
        let buttonHeight: CGFloat = isCompact ? 48 : 58
        let buttonSpacing: CGFloat = isCompact ? 58 : 75

        // Novice Mode Button
        let noviceButton = ObsidianButtonNode(
            labelText: "Novice Mode",
            chromaStart: UIColor(red: 0.2, green: 0.7, blue: 0.5, alpha: 1.0),
            chromaEnd: UIColor(red: 0.15, green: 0.55, blue: 0.4, alpha: 1.0),
            width: buttonWidth,
            height: buttonHeight,
            curvature: 14,
            iconName: "leaf.fill"
        )
        noviceButton.position = CGPoint(x: 0, y: buttonSpacing)
        noviceButton.tapHandler = { [weak self] in
            self?.transitionToGameScene(difficulty: .novice)
        }
        menuContainer.addChild(noviceButton)

        // Adept Mode Button
        let adeptButton = ObsidianButtonNode(
            labelText: "Adept Mode",
            chromaStart: UIColor(red: 0.85, green: 0.35, blue: 0.25, alpha: 1.0),
            chromaEnd: UIColor(red: 0.7, green: 0.25, blue: 0.2, alpha: 1.0),
            width: buttonWidth,
            height: buttonHeight,
            curvature: 14,
            iconName: "flame.fill"
        )
        adeptButton.position = CGPoint(x: 0, y: 0)
        adeptButton.tapHandler = { [weak self] in
            self?.transitionToGameScene(difficulty: .adept)
        }
        menuContainer.addChild(adeptButton)

        // How To Play Button
        let howToPlayButton = ObsidianButtonNode(
            labelText: "How To Play",
            chromaStart: UIColor(red: 0.4, green: 0.5, blue: 0.75, alpha: 1.0),
            chromaEnd: UIColor(red: 0.3, green: 0.4, blue: 0.6, alpha: 1.0),
            width: buttonWidth,
            height: buttonHeight,
            curvature: 14,
            iconName: "questionmark.circle.fill"
        )
        howToPlayButton.position = CGPoint(x: 0, y: -buttonSpacing)
        howToPlayButton.tapHandler = { [weak self] in
            self?.presentHowToPlayDialog()
        }
        menuContainer.addChild(howToPlayButton)

        // Leaderboard Button
        let leaderboardButton = ObsidianButtonNode(
            labelText: "Leaderboard",
            chromaStart: UIColor(red: 0.75, green: 0.55, blue: 0.2, alpha: 1.0),
            chromaEnd: UIColor(red: 0.6, green: 0.45, blue: 0.15, alpha: 1.0),
            width: buttonWidth,
            height: buttonHeight,
            curvature: 14,
            iconName: "trophy.fill"
        )
        leaderboardButton.position = CGPoint(x: 0, y: -buttonSpacing * 2)
        leaderboardButton.tapHandler = { [weak self] in
            self?.transitionToLeaderboardScene()
        }
        menuContainer.addChild(leaderboardButton)
    }

    private func synthesizeScoreDisplay() {
        let isCompact = HorizonCanvasMeasure.isCompactDevice
        let scoreContainer = SKNode()
        scoreContainer.position = CGPoint(x: size.width / 2, y: isCompact ? size.height * 0.08 : size.height * 0.12)
        addChild(scoreContainer)

        // Background pill
        let pillWidth: CGFloat = isCompact ? 150 : 180
        let pillHeight: CGFloat = isCompact ? 40 : 50
        let pillPath = UIBezierPath(roundedRect: CGRect(x: -pillWidth/2, y: -pillHeight/2, width: pillWidth, height: pillHeight), cornerRadius: pillHeight/2)
        let pillShape = SKShapeNode(path: pillPath.cgPath)
        pillShape.fillColor = UIColor.black.withAlphaComponent(0.3)
        pillShape.strokeColor = UIColor.mahjongAccentGold.withAlphaComponent(0.5)
        pillShape.lineWidth = 2
        scoreContainer.addChild(pillShape)

        // Star icon
        let starSize: CGFloat = isCompact ? 18 : 22
        let starConfig = UIImage.SymbolConfiguration(pointSize: starSize, weight: .bold)
        if let starImage = UIImage(systemName: "star.fill", withConfiguration: starConfig) {
            let texture = SKTexture(image: starImage.withTintColor(.aureolaGoldShimmer, renderingMode: .alwaysTemplate))
            let starSprite = SKSpriteNode(texture: texture)
            starSprite.colorBlendFactor = 1.0
            starSprite.color = .aureolaGoldShimmer
            starSprite.position = CGPoint(x: isCompact ? -45 : -55, y: 0)
            scoreContainer.addChild(starSprite)
        }

        // Score label
        scoreDisplayLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreDisplayLabel.text = GloryDisplayFormatter.formatScore(LuminousScoreVault.shared.cumulativeGlory)
        scoreDisplayLabel.fontSize = isCompact ? 18 : 22
        scoreDisplayLabel.fontColor = .ivoryMistWhite
        scoreDisplayLabel.verticalAlignmentMode = .center
        scoreDisplayLabel.horizontalAlignmentMode = .center
        scoreDisplayLabel.position = CGPoint(x: isCompact ? 12 : 15, y: 0)
        scoreContainer.addChild(scoreDisplayLabel)
    }

    private func synthesizeAmbientEffects() {
        ambientParticles = NebulaParticleOrchestrator.shared.synthesizeAmbientMotes()
        ambientParticles?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        ambientParticles?.zPosition = -5
        addChild(ambientParticles!)
    }

    private func synthesizeFooterButtons() {
        let footerY = HorizonCanvasMeasure.safePadding.bottom + 50

        // Rate App Button
        let rateButton = CrystalIconButton(
            systemIconName: "heart.fill",
            chromaTint: UIColor(red: 0.9, green: 0.3, blue: 0.4, alpha: 1.0),
            diameter: 46
        )
        rateButton.position = CGPoint(x: size.width - 50, y: footerY)
        rateButton.tapHandler = { [weak self] in
            self?.presentRateAppDialog()
        }
        addChild(rateButton)

        // Settings Button (optional for future)
        let settingsButton = CrystalIconButton(
            systemIconName: "gearshape.fill",
            chromaTint: UIColor(red: 0.5, green: 0.5, blue: 0.55, alpha: 1.0),
            diameter: 46
        )
        settingsButton.position = CGPoint(x: 50, y: footerY)
        settingsButton.tapHandler = { [weak self] in
            self?.presentSettingsDialog()
        }
        addChild(settingsButton)
    }

    // MARK: - Helper Methods
    private func createGradientTexture(size: CGSize, colors: [UIColor]) -> SKTexture {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()!

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let cgColors = colors.map { $0.cgColor } as CFArray
        let locations: [CGFloat] = [0, 0.5, 1]
        let gradient = CGGradient(colorsSpace: colorSpace, colors: cgColors, locations: locations)!

        context.drawLinearGradient(
            gradient,
            start: CGPoint(x: 0, y: size.height),
            end: CGPoint(x: 0, y: 0),
            options: []
        )

        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return SKTexture(image: image)
    }

    private func createDecorativePattern() -> SKNode {
        let patternNode = SKNode()
        let tileSize: CGFloat = 80
        let opacity: CGFloat = 0.03

        for y in stride(from: 0, to: size.height + tileSize, by: tileSize) {
            for x in stride(from: 0, to: size.width + tileSize, by: tileSize) {
                let diamond = SKShapeNode(rectOf: CGSize(width: 30, height: 30))
                diamond.fillColor = UIColor.white.withAlphaComponent(opacity)
                diamond.strokeColor = .clear
                diamond.zRotation = .pi / 4
                diamond.position = CGPoint(x: x, y: y)
                patternNode.addChild(diamond)
            }
        }

        return patternNode
    }

    private func createDecorativeTilesDisplay() -> SKNode {
        let container = SKNode()
        let isCompact = HorizonCanvasMeasure.isCompactDevice
        let tileSize: CGFloat = isCompact ? 40 : 50 * HorizonCanvasMeasure.proportionalScale
        let spacing: CGFloat = tileSize + (isCompact ? 6 : 10)

        // Display a few sample tiles
        let sampleTiles = [
            VelvetTileEssence(kindredType: .suahs, numeralValue: 1),
            VelvetTileEssence(kindredType: .yabsie, numeralValue: 5),
            VelvetTileEssence(kindredType: .doair, numeralValue: 9),
            VelvetTileEssence(kindredType: .baishye, numeralValue: 3)
        ]

        let startX = -spacing * 1.5

        for (index, tile) in sampleTiles.enumerated() {
            let tileNode = VelvetTileNode(tileEssence: tile, dimension: tileSize)
            tileNode.position = CGPoint(x: startX + CGFloat(index) * spacing, y: 0)
            tileNode.isInteractionEnabled = false

            // Add floating animation
            let floatUp = SKAction.moveBy(x: 0, y: isCompact ? 3 : 5, duration: 1.5 + Double(index) * 0.2)
            let floatDown = SKAction.moveBy(x: 0, y: isCompact ? -3 : -5, duration: 1.5 + Double(index) * 0.2)
            floatUp.timingMode = .easeInEaseOut
            floatDown.timingMode = .easeInEaseOut
            tileNode.run(SKAction.repeatForever(SKAction.sequence([floatUp, floatDown])))

            container.addChild(tileNode)
        }

        return container
    }

    // MARK: - Animations
    private func animateSceneEntry() {
        titleContainer.alpha = 0
        menuContainer.alpha = 0
        titleContainer.position.y += 30

        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let moveDown = SKAction.moveBy(x: 0, y: -30, duration: 0.5)
        moveDown.timingMode = .easeOut

        titleContainer.run(SKAction.group([fadeIn, moveDown]))
        menuContainer.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.2),
            fadeIn
        ]))
    }

    // MARK: - Navigation
    private func transitionToGameScene(difficulty: QuasarDifficultyTier) {
        ZenithHapticOrchestrator.shared.triggerImpactVibration(style: .medium)

        let gameScene = EnigmaPuzzleArena(size: size)
        gameScene.scaleMode = .aspectFill
        gameScene.selectedDifficulty = difficulty

        let transition = SKTransition.push(with: .left, duration: 0.4)
        view?.presentScene(gameScene, transition: transition)
    }

    private func transitionToLeaderboardScene() {
        ZenithHapticOrchestrator.shared.triggerImpactVibration(style: .light)

        let leaderboardScene = GloryChronicleScene(size: size)
        leaderboardScene.scaleMode = .aspectFill

        let transition = SKTransition.push(with: .left, duration: 0.4)
        view?.presentScene(leaderboardScene, transition: transition)
    }

    private func presentHowToPlayDialog() {
        let dialog = EnigmaGuideDialog()
        dialog.position = CGPoint(x: size.width / 2, y: size.height / 2)
        dialog.zPosition = 100
        dialog.appendActionButton(
            title: "Got It!",
            chromaStart: .velvetJadeGreen,
            chromaEnd: UIColor.velvetJadeGreen.luminanceAdjusted(by: 0.8)
        ) { }
        addChild(dialog)
        dialog.animatePresentation()
    }

    private func presentRateAppDialog() {
        let dialog = StellarRatingDialog()
        dialog.position = CGPoint(x: size.width / 2, y: size.height / 2)
        dialog.zPosition = 100
        dialog.appendActionButton(
            title: "Submit",
            chromaStart: .aureolaGoldShimmer,
            chromaEnd: UIColor.aureolaGoldShimmer.luminanceAdjusted(by: 0.8)
        ) {
            // Handle rating submission
        }
        dialog.appendActionButton(
            title: "Maybe Later",
            chromaStart: UIColor(white: 0.4, alpha: 1.0),
            chromaEnd: UIColor(white: 0.3, alpha: 1.0)
        ) { }
        addChild(dialog)
        dialog.animatePresentation()
    }

    private func presentSettingsDialog() {
        let dialog = AuroraDialogNode(title: "Settings", width: 300, minHeight: 220)
        dialog.position = CGPoint(x: size.width / 2, y: size.height / 2)
        dialog.zPosition = 100
        dialog.setMessageText("Sound and haptic settings coming soon!")
        dialog.appendActionButton(
            title: "Close",
            chromaStart: UIColor(white: 0.4, alpha: 1.0),
            chromaEnd: UIColor(white: 0.3, alpha: 1.0)
        ) { }
        addChild(dialog)
        dialog.animatePresentation()
    }

    // MARK: - Scene Updates
    func refreshScoreDisplay() {
        scoreDisplayLabel.text = GloryDisplayFormatter.formatScore(LuminousScoreVault.shared.cumulativeGlory)
    }
}
