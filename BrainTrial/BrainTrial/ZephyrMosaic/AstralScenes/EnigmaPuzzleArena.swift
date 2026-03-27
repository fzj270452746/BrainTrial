//
//  EnigmaPuzzleArena.swift
//  BrainTrial
//
//  Main game scene with puzzle gameplay
//

import SpriteKit

class EnigmaPuzzleArena: SKScene {

    // MARK: - Properties
    var selectedDifficulty: QuasarDifficultyTier = .novice

    private var puzzleOrchestrator: ZenithPuzzleOrchestrator!
    private var backgroundNode: SKSpriteNode!

    // UI Containers
    private var headerContainer: SKNode!
    private var puzzleBoardContainer: SKNode!
    private var handTilesContainer: SKNode!
    private var historyContainer: SKNode!
    private var controlsContainer: SKNode!

    // UI Elements
    private var difficultyBadge: SKNode!
    private var attemptsLabel: SKLabelNode!

    // Game State
    private var puzzleSlotNodes: [SKNode] = []
    private var handTileNodes: [VelvetTileNode] = []
    private var selectedHandTileNode: VelvetTileNode?
    private var historyRowNodes: [SKNode] = []

    // Layout Constants
    private var tileDimension: CGFloat = 50
    private var tileSpacing: CGFloat = 6
    private var safeTop: CGFloat = 0
    private var safeBottom: CGFloat = 0

    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        backgroundColor = .mahjongTableFelt
        calculateLayoutDimensions()
        initializeGameLogic()
        fabricateSceneElements()
        commencePuzzleSession()
    }

    private func calculateLayoutDimensions() {
        safeTop = HorizonCanvasMeasure.safePadding.top
        safeBottom = HorizonCanvasMeasure.safePadding.bottom

        // Calculate tile size based on available width
        let availableWidth = size.width - 40
        let tilesPerRow: CGFloat = selectedDifficulty == .novice ? 4 : 4
        let maxTileSize = (availableWidth - (tilesPerRow - 1) * 8) / tilesPerRow

        tileDimension = min(maxTileSize, 65)
        tileSpacing = 8
    }

    // MARK: - Initialization
    private func initializeGameLogic() {
        puzzleOrchestrator = ZenithPuzzleOrchestrator()
        puzzleOrchestrator.delegateHandler = self
    }

    // MARK: - Scene Construction
    private func fabricateSceneElements() {
        synthesizeBackground()
        synthesizeHeader()
        synthesizePuzzleBoard()
        synthesizeHandTilesArea()
        synthesizeControlButtons()
        synthesizeHistoryArea()
    }

    private func synthesizeBackground() {
        let gradientTexture = createGradientTexture(
            size: size,
            topColor: UIColor(red: 0.1, green: 0.28, blue: 0.2, alpha: 1.0),
            bottomColor: UIColor(red: 0.06, green: 0.16, blue: 0.11, alpha: 1.0)
        )

        backgroundNode = SKSpriteNode(texture: gradientTexture)
        backgroundNode.size = size
        backgroundNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundNode.zPosition = -10
        addChild(backgroundNode)

        // Add ambient particles
        let particles = NebulaParticleOrchestrator.shared.synthesizeAmbientMotes()
        particles.position = CGPoint(x: size.width / 2, y: size.height / 2)
        particles.zPosition = -5
        addChild(particles)
    }

    private func synthesizeHeader() {
        headerContainer = SKNode()
        let headerY = size.height - safeTop - 30
        headerContainer.position = CGPoint(x: size.width / 2, y: headerY)
        addChild(headerContainer)

        // Back button
        let backButton = CrystalIconButton(
            systemIconName: "chevron.left",
            chromaTint: UIColor(white: 0.3, alpha: 0.8),
            diameter: 40
        )
        backButton.position = CGPoint(x: -size.width / 2 + 35, y: 0)
        backButton.tapHandler = { [weak self] in
            self?.navigateToHome()
        }
        headerContainer.addChild(backButton)

        // Difficulty badge
        difficultyBadge = createDifficultyBadge()
        difficultyBadge.position = CGPoint(x: 0, y: 0)
        headerContainer.addChild(difficultyBadge)

        // Attempts counter
        let attemptsContainer = SKNode()
        attemptsContainer.position = CGPoint(x: size.width / 2 - 50, y: 0)
        headerContainer.addChild(attemptsContainer)

        let attemptsIcon = SKLabelNode(fontNamed: "AvenirNext-Bold")
        attemptsIcon.text = "⟳"
        attemptsIcon.fontSize = 16
        attemptsIcon.fontColor = .ivoryMistWhite
        attemptsIcon.position = CGPoint(x: -18, y: -5)
        attemptsContainer.addChild(attemptsIcon)

        attemptsLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        attemptsLabel.text = "0"
        attemptsLabel.fontSize = 18
        attemptsLabel.fontColor = .ivoryMistWhite
        attemptsLabel.horizontalAlignmentMode = .left
        attemptsLabel.position = CGPoint(x: -3, y: -6)
        attemptsContainer.addChild(attemptsLabel)
    }

    private func createDifficultyBadge() -> SKNode {
        let container = SKNode()

        let badgeWidth: CGFloat = 100
        let badgeHeight: CGFloat = 28
        let badgePath = UIBezierPath(roundedRect: CGRect(x: -badgeWidth/2, y: -badgeHeight/2, width: badgeWidth, height: badgeHeight), cornerRadius: badgeHeight/2)

        let badgeShape = SKShapeNode(path: badgePath.cgPath)
        badgeShape.fillColor = selectedDifficulty.accentGradient.first ?? .velvetJadeGreen
        badgeShape.strokeColor = .clear
        container.addChild(badgeShape)

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = selectedDifficulty.celestialTitle.uppercased()
        label.fontSize = 13
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        container.addChild(label)

        return container
    }

    private func synthesizePuzzleBoard() {
        puzzleBoardContainer = SKNode()

        // Calculate board position - below header
        let headerBottom = size.height - safeTop - 60
        let tilesPerRow = selectedDifficulty == .novice ? 4 : 4
        let rows = selectedDifficulty.mosaicTotalCount / tilesPerRow

        let boardHeight = CGFloat(rows) * tileDimension + CGFloat(rows - 1) * tileSpacing + 60
        let boardY = headerBottom - boardHeight / 2 - 10

        puzzleBoardContainer.position = CGPoint(x: size.width / 2, y: boardY)
        addChild(puzzleBoardContainer)

        // Board background
        let boardWidth = size.width - 30
        let boardPath = UIBezierPath(roundedRect: CGRect(x: -boardWidth/2, y: -boardHeight/2, width: boardWidth, height: boardHeight), cornerRadius: 16)

        let boardBg = SKShapeNode(path: boardPath.cgPath)
        boardBg.fillColor = UIColor.black.withAlphaComponent(0.25)
        boardBg.strokeColor = UIColor.mahjongAccentGold.withAlphaComponent(0.3)
        boardBg.lineWidth = 2
        boardBg.zPosition = -1
        puzzleBoardContainer.addChild(boardBg)

        // Title
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        titleLabel.text = "Fill the Pattern"
        titleLabel.fontSize = 14
        titleLabel.fontColor = UIColor.ivoryMistWhite.withAlphaComponent(0.7)
        titleLabel.position = CGPoint(x: 0, y: boardHeight/2 - 22)
        puzzleBoardContainer.addChild(titleLabel)
    }

    private func synthesizeHandTilesArea() {
        handTilesContainer = SKNode()

        // Calculate hand area position - in middle section
        let handTileSize = tileDimension * 0.85
        let tilesPerRow = 5
        let totalTiles = selectedDifficulty.candidatePoolSize
        let rows = (totalTiles + tilesPerRow - 1) / tilesPerRow
        let handHeight = CGFloat(rows) * handTileSize + CGFloat(rows - 1) * 6 + 50

        // Position between puzzle board and controls
        let controlsY = safeBottom + 100
        let puzzleBoardBottom = puzzleBoardContainer.position.y - 100
        let availableSpace = puzzleBoardBottom - controlsY - 30
        let handY = controlsY + 30 + availableSpace / 2

        handTilesContainer.position = CGPoint(x: size.width / 2, y: handY)
        addChild(handTilesContainer)

        // Hand area background
        let handWidth = size.width - 24
        let handPath = UIBezierPath(roundedRect: CGRect(x: -handWidth/2, y: -handHeight/2, width: handWidth, height: handHeight), cornerRadius: 14)

        let handBg = SKShapeNode(path: handPath.cgPath)
        handBg.fillColor = UIColor.black.withAlphaComponent(0.2)
        handBg.strokeColor = UIColor.ivoryMistWhite.withAlphaComponent(0.2)
        handBg.lineWidth = 1
        handBg.zPosition = -1
        handTilesContainer.addChild(handBg)

        // Title
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        titleLabel.text = "Your Hand"
        titleLabel.fontSize = 12
        titleLabel.fontColor = UIColor.ivoryMistWhite.withAlphaComponent(0.6)
        titleLabel.position = CGPoint(x: 0, y: handHeight/2 - 18)
        handTilesContainer.addChild(titleLabel)
    }

    private func synthesizeControlButtons() {
        controlsContainer = SKNode()
        let controlsY = safeBottom + 55
        controlsContainer.position = CGPoint(x: size.width / 2, y: controlsY)
        addChild(controlsContainer)

        // Submit button
        let submitButton = ObsidianButtonNode(
            labelText: "Check Answer",
            chromaStart: .aureolaGoldShimmer,
            chromaEnd: UIColor.aureolaGoldShimmer.luminanceAdjusted(by: 0.8),
            width: 180,
            height: 46,
            curvature: 12,
            iconName: "checkmark.circle.fill"
        )
        submitButton.position = CGPoint(x: -20, y: 0)
        submitButton.tapHandler = { [weak self] in
            self?.executeAttemptSubmission()
        }
        controlsContainer.addChild(submitButton)

        // Reset button
        let resetButton = CrystalIconButton(
            systemIconName: "arrow.counterclockwise",
            chromaTint: UIColor(white: 0.35, alpha: 1.0),
            diameter: 42
        )
        resetButton.position = CGPoint(x: 100, y: 0)
        resetButton.tapHandler = { [weak self] in
            self?.resetCurrentPlacements()
        }
        controlsContainer.addChild(resetButton)
    }

    private func synthesizeHistoryArea() {
        historyContainer = SKNode()
        // Position history above control buttons with more space
        let historyY = safeBottom + 160
        historyContainer.position = CGPoint(x: size.width / 2, y: historyY)
        historyContainer.zPosition = 5
        addChild(historyContainer)
    }

    // MARK: - Game Session
    private func commencePuzzleSession() {
        puzzleOrchestrator.initiatePuzzleSession(difficulty: selectedDifficulty)
        refreshPuzzleDisplay()
        refreshHandTilesDisplay()
        updateAttemptsDisplay()
        // Clear history
        historyRowNodes.forEach { $0.removeFromParent() }
        historyRowNodes.removeAll()
    }

    // MARK: - Display Updates
    private func refreshPuzzleDisplay() {
        // Clear existing puzzle nodes
        puzzleSlotNodes.forEach { $0.removeFromParent() }
        puzzleSlotNodes.removeAll()

        let totalTiles = selectedDifficulty.mosaicTotalCount
        let tilesPerRow = selectedDifficulty == .novice ? 4 : 4
        let rows = totalTiles / tilesPerRow

        let totalWidth = CGFloat(tilesPerRow) * tileDimension + CGFloat(tilesPerRow - 1) * tileSpacing
        let totalHeight = CGFloat(rows) * tileDimension + CGFloat(rows - 1) * tileSpacing
        let startX = -totalWidth / 2 + tileDimension / 2
        let startY = totalHeight / 2 - tileDimension / 2 - 15

        for index in 0..<totalTiles {
            let row = index / tilesPerRow
            let col = index % tilesPerRow

            let xPos = startX + CGFloat(col) * (tileDimension + tileSpacing)
            let yPos = startY - CGFloat(row) * (tileDimension + tileSpacing)

            let slotNode: SKNode

            if puzzleOrchestrator.isSlotVoid(index) {
                // Check if a tile has been placed here
                if let placedTile = puzzleOrchestrator.currentPlacement[index] {
                    let tileNode = VelvetTileNode(tileEssence: placedTile, dimension: tileDimension)
                    tileNode.position = CGPoint(x: xPos, y: yPos)
                    tileNode.delegateHandler = self
                    tileNode.name = "puzzleSlot_\(index)"
                    slotNode = tileNode
                } else {
                    // Empty slot
                    let vacantSlot = VacantSlotNode(index: index, dimension: tileDimension)
                    vacantSlot.position = CGPoint(x: xPos, y: yPos)
                    vacantSlot.tapHandler = { [weak self] slot in
                        self?.handleSlotTap(slot)
                    }
                    slotNode = vacantSlot
                }
            } else {
                // Fixed tile
                let tileEssence = puzzleOrchestrator.visibleMosaic[index]
                let tileNode = VelvetTileNode(tileEssence: tileEssence, dimension: tileDimension)
                tileNode.position = CGPoint(x: xPos, y: yPos)
                tileNode.isInteractionEnabled = false
                tileNode.alpha = 0.9
                slotNode = tileNode
            }

            puzzleBoardContainer.addChild(slotNode)
            puzzleSlotNodes.append(slotNode)
        }
    }

    private func refreshHandTilesDisplay() {
        // Clear existing hand tile nodes
        handTileNodes.forEach { $0.removeFromParent() }
        handTileNodes.removeAll()

        let tiles = puzzleOrchestrator.candidateHandTiles
        let tilesPerRow = 5

        let handTileSize = tileDimension * 0.85
        let handSpacing: CGFloat = 5

        let totalRows = (tiles.count + tilesPerRow - 1) / tilesPerRow
        let totalHeight = CGFloat(totalRows) * handTileSize + CGFloat(totalRows - 1) * handSpacing
        let startY = totalHeight / 2 - handTileSize / 2 - 12

        for (index, tile) in tiles.enumerated() {
            let row = index / tilesPerRow
            let col = index % tilesPerRow

            let rowTileCount = min(tilesPerRow, tiles.count - row * tilesPerRow)
            let rowWidth = CGFloat(rowTileCount) * handTileSize + CGFloat(rowTileCount - 1) * handSpacing
            let rowStartX = -rowWidth / 2 + handTileSize / 2

            let xPos = rowStartX + CGFloat(col) * (handTileSize + handSpacing)
            let yPos = startY - CGFloat(row) * (handTileSize + handSpacing)

            let tileNode = VelvetTileNode(tileEssence: tile, dimension: handTileSize)
            tileNode.position = CGPoint(x: xPos, y: yPos)
            tileNode.delegateHandler = self
            tileNode.name = "handTile_\(index)"

            // Check if this is the selected tile
            if tile == puzzleOrchestrator.selectedHandTile {
                tileNode.isSelected = true
                selectedHandTileNode = tileNode
            }

            // Entry animation
            tileNode.alpha = 0
            tileNode.setScale(0.8)
            let delay = Double(index) * 0.02
            tileNode.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.group([
                    SKAction.fadeIn(withDuration: 0.15),
                    SKAction.scale(to: 1.0, duration: 0.15)
                ])
            ]))

            handTilesContainer.addChild(tileNode)
            handTileNodes.append(tileNode)
        }
    }

    private func updateAttemptsDisplay() {
        attemptsLabel.text = "\(puzzleOrchestrator.endeavorCount)"
    }

    private func refreshHistoryDisplay() {
        // Clear existing history
        historyRowNodes.forEach { $0.removeFromParent() }
        historyRowNodes.removeAll()

        guard !puzzleOrchestrator.attemptChronicles.isEmpty else { return }

        // Only show the most recent attempt
        let chronicles = puzzleOrchestrator.attemptChronicles.suffix(1)
        let miniTileSize: CGFloat = 32
        let miniSpacing: CGFloat = 4

        var yOffset: CGFloat = 0

        for chronicle in chronicles.reversed() {
            let rowNode = SKNode()
            rowNode.position = CGPoint(x: 0, y: yOffset)

            let totalTiles = selectedDifficulty.mosaicTotalCount
            let totalWidth = CGFloat(totalTiles) * miniTileSize + CGFloat(totalTiles - 1) * miniSpacing
            let startX = -totalWidth / 2 + miniTileSize / 2

            for (index, verdict) in chronicle.verdictMatrix.enumerated() {
                let xPos = startX + CGFloat(index) * (miniTileSize + miniSpacing)

                // Create a container for the tile and indicator
                let tileContainer = SKNode()
                tileContainer.position = CGPoint(x: xPos, y: 0)

                // Check if this is a player-filled slot (void slot) or a fixed tile
                let isPlayerFilledSlot = puzzleOrchestrator.voidSlotIndices.contains(index)

                // Get the tile that was placed at this position
                if let placedTile = chronicle.placementSequence[index] {
                    // Show the actual tile image
                    let tileSprite = SKSpriteNode(imageNamed: placedTile.canvasIdentifier)
                    tileSprite.size = CGSize(width: miniTileSize - 4, height: miniTileSize - 4)

                    // Add background for the tile
                    let tileBg = SKShapeNode(rectOf: CGSize(width: miniTileSize, height: miniTileSize), cornerRadius: 4)
                    tileBg.fillColor = UIColor.mahjongTileFace
                    tileBg.strokeColor = .clear
                    tileBg.zPosition = 0
                    tileContainer.addChild(tileBg)

                    tileSprite.zPosition = 1
                    tileContainer.addChild(tileSprite)

                    // Only show verdict indicator for player-filled slots
                    if isPlayerFilledSlot {
                        let indicatorSize: CGFloat = 12
                        let indicatorBg = SKShapeNode(circleOfRadius: indicatorSize / 2)
                        indicatorBg.position = CGPoint(x: miniTileSize / 2 - 4, y: -miniTileSize / 2 + 4)
                        indicatorBg.zPosition = 2

                        switch verdict {
                        case .accurate:
                            indicatorBg.fillColor = UIColor.celadonMintFresh
                            indicatorBg.strokeColor = .white
                            indicatorBg.lineWidth = 1

                            let checkmark = SKLabelNode(fontNamed: "AvenirNext-Bold")
                            checkmark.text = "✓"
                            checkmark.fontSize = 8
                            checkmark.fontColor = .white
                            checkmark.verticalAlignmentMode = .center
                            checkmark.horizontalAlignmentMode = .center
                            indicatorBg.addChild(checkmark)

                            // Add green border to tile
                            tileBg.strokeColor = UIColor.celadonMintFresh
                            tileBg.lineWidth = 2

                        case .misplaced:
                            indicatorBg.fillColor = UIColor.crimsonEmberGlow
                            indicatorBg.strokeColor = .white
                            indicatorBg.lineWidth = 1

                            let xMark = SKLabelNode(fontNamed: "AvenirNext-Bold")
                            xMark.text = "✗"
                            xMark.fontSize = 8
                            xMark.fontColor = .white
                            xMark.verticalAlignmentMode = .center
                            xMark.horizontalAlignmentMode = .center
                            indicatorBg.addChild(xMark)

                            // Add red border to tile
                            tileBg.strokeColor = UIColor.crimsonEmberGlow
                            tileBg.lineWidth = 2

                        case .vacant:
                            indicatorBg.fillColor = UIColor.gray
                            indicatorBg.strokeColor = .white
                            indicatorBg.lineWidth = 1
                        }

                        tileContainer.addChild(indicatorBg)
                    }
                } else {
                    // Empty slot indicator
                    let emptyBg = SKShapeNode(rectOf: CGSize(width: miniTileSize, height: miniTileSize), cornerRadius: 4)
                    emptyBg.fillColor = UIColor.white.withAlphaComponent(0.1)
                    emptyBg.strokeColor = UIColor.white.withAlphaComponent(0.3)
                    emptyBg.lineWidth = 1
                    tileContainer.addChild(emptyBg)
                }

                rowNode.addChild(tileContainer)
            }

            historyContainer.addChild(rowNode)
            historyRowNodes.append(rowNode)

            yOffset -= miniTileSize + 8
        }

        // Add "View All" button if there are more than 1 attempt
        if puzzleOrchestrator.attemptChronicles.count > 1 {
            let viewAllButton = SKNode()
            viewAllButton.name = "viewAllHistoryButton"
            viewAllButton.position = CGPoint(x: 0, y: yOffset - 12)

            let buttonBg = SKShapeNode(rectOf: CGSize(width: 100, height: 26), cornerRadius: 13)
            buttonBg.fillColor = UIColor.white.withAlphaComponent(0.15)
            buttonBg.strokeColor = UIColor.white.withAlphaComponent(0.3)
            buttonBg.lineWidth = 1
            viewAllButton.addChild(buttonBg)

            let buttonLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            buttonLabel.text = "View All (\(puzzleOrchestrator.attemptChronicles.count))"
            buttonLabel.fontSize = 11
            buttonLabel.fontColor = .ivoryMistWhite
            buttonLabel.verticalAlignmentMode = .center
            viewAllButton.addChild(buttonLabel)

            viewAllButton.isUserInteractionEnabled = false
            historyContainer.addChild(viewAllButton)
            historyRowNodes.append(viewAllButton)
        }
    }

    private func presentFullHistoryDialog() {
        // Create full history overlay
        let overlay = SKNode()
        overlay.name = "fullHistoryOverlay"
        overlay.zPosition = 200

        // Dark background
        let darkBg = SKShapeNode(rectOf: size)
        darkBg.fillColor = UIColor.black.withAlphaComponent(0.85)
        darkBg.strokeColor = .clear
        darkBg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.addChild(darkBg)

        // Dialog container
        let dialogWidth = size.width - 40
        let dialogHeight = size.height - safeTop - safeBottom - 80
        let dialogContainer = SKNode()
        dialogContainer.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.addChild(dialogContainer)

        // Dialog background
        let dialogBg = SKShapeNode(rectOf: CGSize(width: dialogWidth, height: dialogHeight), cornerRadius: 16)
        dialogBg.fillColor = UIColor(red: 0.12, green: 0.22, blue: 0.18, alpha: 1.0)
        dialogBg.strokeColor = UIColor.mahjongAccentGold.withAlphaComponent(0.4)
        dialogBg.lineWidth = 2
        dialogContainer.addChild(dialogBg)

        // Title
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "Attempt History"
        titleLabel.fontSize = 18
        titleLabel.fontColor = .ivoryMistWhite
        titleLabel.position = CGPoint(x: 0, y: dialogHeight / 2 - 30)
        dialogContainer.addChild(titleLabel)

        // Close button
        let closeButton = CrystalIconButton(
            systemIconName: "xmark",
            chromaTint: UIColor(white: 0.3, alpha: 0.8),
            diameter: 36
        )
        closeButton.position = CGPoint(x: dialogWidth / 2 - 30, y: dialogHeight / 2 - 30)
        closeButton.tapHandler = { [weak self] in
            self?.dismissFullHistoryDialog()
        }
        dialogContainer.addChild(closeButton)

        // Scrollable history content
        let contentStartY = dialogHeight / 2 - 60
        let miniTileSize: CGFloat = 28
        let miniSpacing: CGFloat = 3
        let rowHeight: CGFloat = miniTileSize + 20

        var yOffset: CGFloat = contentStartY

        for (attemptIndex, chronicle) in puzzleOrchestrator.attemptChronicles.enumerated() {
            // Attempt number label
            let attemptLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            attemptLabel.text = "#\(attemptIndex + 1)"
            attemptLabel.fontSize = 12
            attemptLabel.fontColor = UIColor.ivoryMistWhite.withAlphaComponent(0.6)
            attemptLabel.horizontalAlignmentMode = .left
            attemptLabel.position = CGPoint(x: -dialogWidth / 2 + 20, y: yOffset)
            dialogContainer.addChild(attemptLabel)

            // Tiles row
            let totalTiles = selectedDifficulty.mosaicTotalCount
            let totalWidth = CGFloat(totalTiles) * miniTileSize + CGFloat(totalTiles - 1) * miniSpacing
            let startX = -totalWidth / 2 + miniTileSize / 2 + 15

            for (index, verdict) in chronicle.verdictMatrix.enumerated() {
                let xPos = startX + CGFloat(index) * (miniTileSize + miniSpacing)
                let tileContainer = SKNode()
                tileContainer.position = CGPoint(x: xPos, y: yOffset - 5)

                let isPlayerFilledSlot = puzzleOrchestrator.voidSlotIndices.contains(index)

                if let placedTile = chronicle.placementSequence[index] {
                    let tileSprite = SKSpriteNode(imageNamed: placedTile.canvasIdentifier)
                    tileSprite.size = CGSize(width: miniTileSize - 4, height: miniTileSize - 4)

                    let tileBg = SKShapeNode(rectOf: CGSize(width: miniTileSize, height: miniTileSize), cornerRadius: 3)
                    tileBg.fillColor = UIColor.mahjongTileFace
                    tileBg.strokeColor = .clear
                    tileBg.zPosition = 0
                    tileContainer.addChild(tileBg)

                    tileSprite.zPosition = 1
                    tileContainer.addChild(tileSprite)

                    if isPlayerFilledSlot {
                        let indicatorSize: CGFloat = 10
                        let indicatorBg = SKShapeNode(circleOfRadius: indicatorSize / 2)
                        indicatorBg.position = CGPoint(x: miniTileSize / 2 - 3, y: -miniTileSize / 2 + 3)
                        indicatorBg.zPosition = 2

                        switch verdict {
                        case .accurate:
                            indicatorBg.fillColor = UIColor.celadonMintFresh
                            tileBg.strokeColor = UIColor.celadonMintFresh
                            tileBg.lineWidth = 1.5
                        case .misplaced:
                            indicatorBg.fillColor = UIColor.crimsonEmberGlow
                            tileBg.strokeColor = UIColor.crimsonEmberGlow
                            tileBg.lineWidth = 1.5
                        case .vacant:
                            indicatorBg.fillColor = UIColor.gray
                        }
                        indicatorBg.strokeColor = .white
                        indicatorBg.lineWidth = 1
                        tileContainer.addChild(indicatorBg)
                    }
                }

                dialogContainer.addChild(tileContainer)
            }

            yOffset -= rowHeight

            // Stop if we're going off screen
            if yOffset < -dialogHeight / 2 + 40 {
                let moreLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
                moreLabel.text = "... and \(puzzleOrchestrator.attemptChronicles.count - attemptIndex - 1) more"
                moreLabel.fontSize = 11
                moreLabel.fontColor = UIColor.ivoryMistWhite.withAlphaComponent(0.5)
                moreLabel.position = CGPoint(x: 0, y: yOffset)
                dialogContainer.addChild(moreLabel)
                break
            }
        }

        addChild(overlay)

        // Animate in
        overlay.alpha = 0
        overlay.run(SKAction.fadeIn(withDuration: 0.2))
    }

    private func dismissFullHistoryDialog() {
        if let overlay = childNode(withName: "fullHistoryOverlay") {
            overlay.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.15),
                SKAction.removeFromParent()
            ]))
        }
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Check if tapped on "View All" button in history area
        let historyLocation = touch.location(in: historyContainer)
        if let viewAllButton = historyContainer.childNode(withName: "viewAllHistoryButton") {
            let buttonBounds = CGRect(x: -50, y: -13, width: 100, height: 26)
            let localPoint = CGPoint(x: historyLocation.x - viewAllButton.position.x,
                                     y: historyLocation.y - viewAllButton.position.y)
            if buttonBounds.contains(localPoint) {
                ZenithHapticOrchestrator.shared.triggerSelectionVibration()
                presentFullHistoryDialog()
                return
            }
        }

        // Check if tapped on dark background of full history overlay to dismiss
        if let overlay = childNode(withName: "fullHistoryOverlay") {
            let overlayLocation = touch.location(in: overlay)
            // If tapped outside the dialog, dismiss
            let dialogBounds = CGRect(x: 20, y: safeBottom + 40, width: size.width - 40, height: size.height - safeTop - safeBottom - 80)
            if !dialogBounds.contains(location) {
                dismissFullHistoryDialog()
            }
        }
    }

    // MARK: - User Interactions
    private func handleSlotTap(_ slot: VacantSlotNode) {
        guard puzzleOrchestrator.selectedHandTile != nil else {
            // Show hint that a tile needs to be selected
            slot.isHighlighted = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                slot.isHighlighted = false
            }
            return
        }

        // Place the tile
        if puzzleOrchestrator.placeTileInSlot(slotIndex: slot.slotIndex) {
            ZenithHapticOrchestrator.shared.triggerImpactVibration(style: .medium)

            // Add sparkle effect
            let sparkle = NebulaParticleOrchestrator.shared.synthesizeAccuracySparkle(at: slot.position)
            sparkle.zPosition = 10
            puzzleBoardContainer.addChild(sparkle)
            sparkle.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.8),
                SKAction.removeFromParent()
            ]))

            selectedHandTileNode?.isSelected = false
            selectedHandTileNode = nil
            refreshPuzzleDisplay()
            refreshHandTilesDisplay()
        }
    }

    private func executeAttemptSubmission() {
        guard puzzleOrchestrator.allSlotsAreFilled() else {
            // Shake the puzzle board to indicate incomplete
            puzzleBoardContainer.prismaticShakeMotion(intensity: 10, duration: 0.4)
            ZenithHapticOrchestrator.shared.triggerNotificationVibration(type: .warning)
            return
        }

        ZenithHapticOrchestrator.shared.triggerImpactVibration(style: .heavy)
        puzzleOrchestrator.executeAttemptValidation()
    }

    private func resetCurrentPlacements() {
        // Return all placed tiles to hand
        for (index, _) in puzzleOrchestrator.currentPlacement {
            _ = puzzleOrchestrator.removeTileFromSlot(slotIndex: index)
        }

        selectedHandTileNode?.isSelected = false
        selectedHandTileNode = nil
        puzzleOrchestrator.deselectHandTile()

        refreshPuzzleDisplay()
        refreshHandTilesDisplay()

        ZenithHapticOrchestrator.shared.triggerImpactVibration(style: .light)
    }

    // MARK: - Navigation
    private func navigateToHome() {
        let homeScene = CelestialHomeScene(size: size)
        homeScene.scaleMode = .aspectFill

        let transition = SKTransition.push(with: .right, duration: 0.4)
        view?.presentScene(homeScene, transition: transition)
    }

    // MARK: - Helper Methods
    private func createGradientTexture(size: CGSize, topColor: UIColor, bottomColor: UIColor) -> SKTexture {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()!

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = [topColor.cgColor, bottomColor.cgColor] as CFArray
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 1])!

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

    // MARK: - Victory Celebration
    private func celebrateTriumph(score: Int, attempts: Int) {
        // Add confetti particles
        let confetti = NebulaParticleOrchestrator.shared.synthesizeTriumphEmitter()
        confetti.position = CGPoint(x: size.width / 2, y: size.height + 50)
        confetti.zPosition = 50
        addChild(confetti)

        // Present victory dialog after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }

            let dialog = TriumphCelebrationDialog(
                score: score,
                attempts: attempts,
                difficulty: self.selectedDifficulty
            )
            dialog.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
            dialog.zPosition = 100
            dialog.appendActionButton(
                title: "Play Again",
                chromaStart: .velvetJadeGreen,
                chromaEnd: UIColor.velvetJadeGreen.luminanceAdjusted(by: 0.8)
            ) { [weak self] in
                self?.commencePuzzleSession()
            }
            dialog.appendActionButton(
                title: "Home",
                chromaStart: UIColor(white: 0.4, alpha: 1.0),
                chromaEnd: UIColor(white: 0.3, alpha: 1.0)
            ) { [weak self] in
                self?.navigateToHome()
            }

            self.addChild(dialog)
            dialog.animatePresentation()
        }
    }
}

// MARK: - VelvetTileNodeDelegate
extension EnigmaPuzzleArena: VelvetTileNodeDelegate {

    func tileNodeWasTapped(_ tileNode: VelvetTileNode) {
        guard let tileName = tileNode.name else { return }

        if tileName.hasPrefix("handTile_") {
            // Selecting a hand tile
            if let tile = tileNode.tileEssence {
                // Deselect previous
                selectedHandTileNode?.isSelected = false

                if selectedHandTileNode === tileNode {
                    // Deselect if tapping same tile
                    selectedHandTileNode = nil
                    puzzleOrchestrator.deselectHandTile()
                } else {
                    // Select new tile
                    tileNode.isSelected = true
                    selectedHandTileNode = tileNode
                    puzzleOrchestrator.selectHandTile(tile)
                }
            }
        } else if tileName.hasPrefix("puzzleSlot_") {
            // Tapping a placed tile - remove it
            if let indexString = tileName.split(separator: "_").last,
               let index = Int(indexString) {
                if let _ = puzzleOrchestrator.removeTileFromSlot(slotIndex: index) {
                    ZenithHapticOrchestrator.shared.triggerImpactVibration(style: .light)
                    refreshPuzzleDisplay()
                    refreshHandTilesDisplay()
                }
            }
        }
    }
}

// MARK: - ZenithPuzzleOrchestratorDelegate
extension EnigmaPuzzleArena: ZenithPuzzleOrchestratorDelegate {

    func puzzleStateDidUpdate() {
        // State updated, UI refresh handled elsewhere
    }

    func puzzleAttemptCompleted(isCorrect: Bool, verdicts: [TileVerdictGlyph]) {
        updateAttemptsDisplay()
        refreshHistoryDisplay()

        if !isCorrect {
            // Animate incorrect feedback
            for (index, verdict) in verdicts.enumerated() {
                if verdict == .misplaced, index < puzzleSlotNodes.count {
                    let slotNode = puzzleSlotNodes[index]
                    if let tileNode = slotNode as? VelvetTileNode {
                        tileNode.animateIncorrectPlacement()
                    }
                }
            }

            ZenithHapticOrchestrator.shared.triggerNotificationVibration(type: .error)
        }

        // Refresh displays after reset
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.refreshPuzzleDisplay()
            self?.refreshHandTilesDisplay()
        }
    }

    func puzzleTriumphAchieved(score: Int, attempts: Int) {
        // Save score
        LuminousScoreVault.shared.accumulateTriumphScore(score)
        LuminousScoreVault.shared.inscribeAchievement(
            alias: "Player",
            score: score,
            difficulty: selectedDifficulty
        )

        ZenithHapticOrchestrator.shared.triggerNotificationVibration(type: .success)
        celebrateTriumph(score: score, attempts: attempts)
    }
}
