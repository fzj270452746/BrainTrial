//
//  GloryChronicleScene.swift
//  BrainTrial
//
//  Leaderboard scene
//

import SpriteKit

class GloryChronicleScene: SKScene {

    // MARK: - Properties
    private var backgroundNode: SKSpriteNode!
    private var headerContainer: SKNode!
    private var tabContainer: SKNode!
    private var listContainer: SKNode!
    private var statsContainer: SKNode!

    private var selectedDifficultyFilter: QuasarDifficultyTier? = nil
    private var listScrollNode: SKNode!
    private var currentScrollOffset: CGFloat = 0
    private var maxScrollOffset: CGFloat = 0

    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        backgroundColor = .mahjongTableFelt
        fabricateSceneElements()
        populateLeaderboardList()
    }

    // MARK: - Scene Construction
    private func fabricateSceneElements() {
        synthesizeBackground()
        synthesizeHeader()
        synthesizeFilterTabs()
        synthesizeListArea()
        synthesizeStatsSection()
    }

    private func synthesizeBackground() {
        let gradientTexture = createGradientTexture(
            size: size,
            colors: [
                UIColor(red: 0.08, green: 0.2, blue: 0.15, alpha: 1.0),
                UIColor(red: 0.05, green: 0.14, blue: 0.1, alpha: 1.0)
            ]
        )

        backgroundNode = SKSpriteNode(texture: gradientTexture)
        backgroundNode.size = size
        backgroundNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundNode.zPosition = -10
        addChild(backgroundNode)

        // Decorative elements
        let particles = NebulaParticleOrchestrator.shared.synthesizeAmbientMotes()
        particles.position = CGPoint(x: size.width / 2, y: size.height / 2)
        particles.zPosition = -5
        particles.particleBirthRate = 2
        addChild(particles)
    }

    private func synthesizeHeader() {
        headerContainer = SKNode()
        let headerY = size.height - HorizonCanvasMeasure.safePadding.top - 50
        headerContainer.position = CGPoint(x: size.width / 2, y: headerY)
        addChild(headerContainer)

        // Back button
        let backButton = CrystalIconButton(
            systemIconName: "chevron.left",
            chromaTint: UIColor(white: 0.3, alpha: 0.8),
            diameter: 44
        )
        backButton.position = CGPoint(x: -size.width / 2 + 40, y: 0)
        backButton.tapHandler = { [weak self] in
            self?.navigateToHome()
        }
        headerContainer.addChild(backButton)

        // Title with trophy icon
        let titleContainer = SKNode()

        let trophyConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        if let trophyImage = UIImage(systemName: "trophy.fill", withConfiguration: trophyConfig) {
            let texture = SKTexture(image: trophyImage.withTintColor(.aureolaGoldShimmer, renderingMode: .alwaysTemplate))
            let trophySprite = SKSpriteNode(texture: texture)
            trophySprite.colorBlendFactor = 1.0
            trophySprite.color = .aureolaGoldShimmer
            trophySprite.position = CGPoint(x: -85, y: 0)
            titleContainer.addChild(trophySprite)
        }

        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "Leaderboard"
        titleLabel.fontSize = 24
        titleLabel.fontColor = .ivoryMistWhite
        titleLabel.verticalAlignmentMode = .center
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.position = CGPoint(x: -65, y: 0)
        titleContainer.addChild(titleLabel)

        headerContainer.addChild(titleContainer)
    }

    private func synthesizeFilterTabs() {
        tabContainer = SKNode()
        let tabY = size.height - HorizonCanvasMeasure.safePadding.top - 110
        tabContainer.position = CGPoint(x: size.width / 2, y: tabY)
        addChild(tabContainer)

        let tabs = [
            ("All", nil as QuasarDifficultyTier?),
            ("Novice", QuasarDifficultyTier.novice),
            ("Adept", QuasarDifficultyTier.adept)
        ]

        let tabWidth: CGFloat = 90
        let tabSpacing: CGFloat = 10
        let totalWidth = CGFloat(tabs.count) * tabWidth + CGFloat(tabs.count - 1) * tabSpacing
        var xPos = -totalWidth / 2 + tabWidth / 2

        for (title, difficulty) in tabs {
            let tab = createFilterTab(title: title, difficulty: difficulty)
            tab.position = CGPoint(x: xPos, y: 0)
            tabContainer.addChild(tab)
            xPos += tabWidth + tabSpacing
        }
    }

    private func createFilterTab(title: String, difficulty: QuasarDifficultyTier?) -> SKNode {
        let container = SKNode()
        container.name = difficulty?.celestialTitle ?? "all"

        let isSelected = difficulty == selectedDifficultyFilter

        let tabWidth: CGFloat = 90
        let tabHeight: CGFloat = 36
        let tabPath = UIBezierPath(roundedRect: CGRect(x: -tabWidth/2, y: -tabHeight/2, width: tabWidth, height: tabHeight), cornerRadius: tabHeight/2)

        let tabShape = SKShapeNode(path: tabPath.cgPath)
        tabShape.fillColor = isSelected ? UIColor.mahjongAccentGold : UIColor.black.withAlphaComponent(0.3)
        tabShape.strokeColor = isSelected ? .mahjongAccentGold : UIColor.white.withAlphaComponent(0.2)
        tabShape.lineWidth = 1
        container.addChild(tabShape)

        let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        label.text = title
        label.fontSize = 14
        label.fontColor = isSelected ? .obsidianDepth : .ivoryMistWhite
        label.verticalAlignmentMode = .center
        container.addChild(label)

        // Make interactive
        container.isUserInteractionEnabled = true

        return container
    }

    private func synthesizeListArea() {
        listContainer = SKNode()
        let listY = size.height * 0.45
        listContainer.position = CGPoint(x: size.width / 2, y: listY)
        addChild(listContainer)

        // Background for list
        let listWidth = size.width - 40
        let listHeight: CGFloat = size.height * 0.5
        let listPath = UIBezierPath(roundedRect: CGRect(x: -listWidth/2, y: -listHeight/2, width: listWidth, height: listHeight), cornerRadius: 16)

        let listBg = SKShapeNode(path: listPath.cgPath)
        listBg.fillColor = UIColor.black.withAlphaComponent(0.25)
        listBg.strokeColor = UIColor.mahjongAccentGold.withAlphaComponent(0.2)
        listBg.lineWidth = 1
        listBg.zPosition = -1
        listContainer.addChild(listBg)

        // Scroll container
        listScrollNode = SKNode()
        listScrollNode.position = .zero
        listContainer.addChild(listScrollNode)
    }

    private func synthesizeStatsSection() {
        statsContainer = SKNode()
        let statsY = HorizonCanvasMeasure.safePadding.bottom + 80
        statsContainer.position = CGPoint(x: size.width / 2, y: statsY)
        addChild(statsContainer)

        let scoreVault = LuminousScoreVault.shared

        // Stats row
        let stats = [
            ("Total Score", GloryDisplayFormatter.formatScore(scoreVault.cumulativeGlory)),
            ("Games", "\(scoreVault.calculateTotalGamesPlayed())"),
            ("Best", GloryDisplayFormatter.formatScore(scoreVault.fetchHighestScore()))
        ]

        let statWidth: CGFloat = 100
        let totalWidth = CGFloat(stats.count) * statWidth
        var xPos = -totalWidth / 2 + statWidth / 2

        for (label, value) in stats {
            let statNode = createStatDisplay(label: label, value: value)
            statNode.position = CGPoint(x: xPos, y: 0)
            statsContainer.addChild(statNode)
            xPos += statWidth
        }
    }

    private func createStatDisplay(label: String, value: String) -> SKNode {
        let container = SKNode()

        let valueLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        valueLabel.text = value
        valueLabel.fontSize = 22
        valueLabel.fontColor = .aureolaGoldShimmer
        valueLabel.position = CGPoint(x: 0, y: 10)
        container.addChild(valueLabel)

        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        titleLabel.text = label
        titleLabel.fontSize = 12
        titleLabel.fontColor = UIColor.ivoryMistWhite.withAlphaComponent(0.6)
        titleLabel.position = CGPoint(x: 0, y: -15)
        container.addChild(titleLabel)

        return container
    }

    // MARK: - Leaderboard Population
    private func populateLeaderboardList() {
        // Clear existing
        listScrollNode.removeAllChildren()

        let records: [LuminousAchievementRecord]
        if let filter = selectedDifficultyFilter {
            records = LuminousScoreVault.shared.fetchRecordsForDifficulty(filter, count: 20)
        } else {
            records = LuminousScoreVault.shared.fetchTopRecords(count: 20)
        }

        let rowHeight: CGFloat = 60
        let listWidth = size.width - 60
        var yPos: CGFloat = size.height * 0.22

        if records.isEmpty {
            // Empty state
            let emptyLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
            emptyLabel.text = "No records yet!"
            emptyLabel.fontSize = 18
            emptyLabel.fontColor = UIColor.ivoryMistWhite.withAlphaComponent(0.5)
            emptyLabel.position = .zero
            listScrollNode.addChild(emptyLabel)

            let hintLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
            hintLabel.text = "Play a game to get started"
            hintLabel.fontSize = 14
            hintLabel.fontColor = UIColor.ivoryMistWhite.withAlphaComponent(0.3)
            hintLabel.position = CGPoint(x: 0, y: -25)
            listScrollNode.addChild(hintLabel)
        } else {
            for (index, record) in records.enumerated() {
                let row = createLeaderboardRow(
                    rank: index + 1,
                    record: record,
                    width: listWidth
                )
                row.position = CGPoint(x: 0, y: yPos)
                listScrollNode.addChild(row)

                // Entry animation
                row.alpha = 0
                row.run(SKAction.sequence([
                    SKAction.wait(forDuration: Double(index) * 0.05),
                    SKAction.fadeIn(withDuration: 0.3)
                ]))

                yPos -= rowHeight
            }
        }

        maxScrollOffset = max(0, CGFloat(records.count) * rowHeight - size.height * 0.45)
    }

    private func createLeaderboardRow(rank: Int, record: LuminousAchievementRecord, width: CGFloat) -> SKNode {
        let container = SKNode()

        // Row background
        let rowHeight: CGFloat = 54
        let rowPath = UIBezierPath(roundedRect: CGRect(x: -width/2, y: -rowHeight/2, width: width, height: rowHeight), cornerRadius: 10)

        let rowBg = SKShapeNode(path: rowPath.cgPath)
        rowBg.fillColor = rank <= 3 ? UIColor.mahjongAccentGold.withAlphaComponent(0.1) : UIColor.white.withAlphaComponent(0.05)
        rowBg.strokeColor = rank <= 3 ? UIColor.mahjongAccentGold.withAlphaComponent(0.3) : .clear
        rowBg.lineWidth = 1
        container.addChild(rowBg)

        // Rank
        let rankLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        rankLabel.text = GloryDisplayFormatter.formatRank(rank)
        rankLabel.fontSize = rank <= 3 ? 22 : 16
        rankLabel.fontColor = rank <= 3 ? .aureolaGoldShimmer : UIColor.ivoryMistWhite.withAlphaComponent(0.7)
        rankLabel.horizontalAlignmentMode = .left
        rankLabel.verticalAlignmentMode = .center
        rankLabel.position = CGPoint(x: -width/2 + 15, y: 0)
        container.addChild(rankLabel)

        // Player name
        let nameLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        nameLabel.text = record.protagonistAlias
        nameLabel.fontSize = 16
        nameLabel.fontColor = .ivoryMistWhite
        nameLabel.horizontalAlignmentMode = .left
        nameLabel.verticalAlignmentMode = .center
        nameLabel.position = CGPoint(x: -width/2 + 60, y: 5)
        container.addChild(nameLabel)

        // Date
        let dateLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        dateLabel.text = GloryDisplayFormatter.formatRelativeDate(record.epochTimestamp)
        dateLabel.fontSize = 11
        dateLabel.fontColor = UIColor.ivoryMistWhite.withAlphaComponent(0.4)
        dateLabel.horizontalAlignmentMode = .left
        dateLabel.verticalAlignmentMode = .center
        dateLabel.position = CGPoint(x: -width/2 + 60, y: -12)
        container.addChild(dateLabel)

        // Difficulty badge
        if let difficulty = QuasarDifficultyTier(rawValue: record.difficultyEchelon) {
            let badgeWidth: CGFloat = 55
            let badgeHeight: CGFloat = 20
            let badgePath = UIBezierPath(roundedRect: CGRect(x: -badgeWidth/2, y: -badgeHeight/2, width: badgeWidth, height: badgeHeight), cornerRadius: badgeHeight/2)

            let badge = SKShapeNode(path: badgePath.cgPath)
            badge.fillColor = difficulty.accentGradient.first?.withAlphaComponent(0.3) ?? .clear
            badge.strokeColor = difficulty.accentGradient.first ?? .clear
            badge.lineWidth = 1
            badge.position = CGPoint(x: width/2 - 100, y: 0)
            container.addChild(badge)

            let diffLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
            diffLabel.text = difficulty == .novice ? "NOV" : "ADV"
            diffLabel.fontSize = 10
            diffLabel.fontColor = difficulty.accentGradient.first ?? .white
            diffLabel.verticalAlignmentMode = .center
            diffLabel.position = CGPoint(x: width/2 - 100, y: 0)
            container.addChild(diffLabel)
        }

        // Score
        let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.text = GloryDisplayFormatter.formatScore(record.accruedGlory)
        scoreLabel.fontSize = 18
        scoreLabel.fontColor = .aureolaGoldShimmer
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: width/2 - 15, y: 0)
        container.addChild(scoreLabel)

        return container
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: tabContainer)

        // Check tab touches
        for child in tabContainer.children {
            if child.contains(location) {
                handleTabSelection(child)
                return
            }
        }
    }

    private func handleTabSelection(_ tab: SKNode) {
        guard let name = tab.name else { return }

        ZenithHapticOrchestrator.shared.triggerSelectionVibration()

        if name == "all" {
            selectedDifficultyFilter = nil
        } else if name == QuasarDifficultyTier.novice.celestialTitle {
            selectedDifficultyFilter = .novice
        } else if name == QuasarDifficultyTier.adept.celestialTitle {
            selectedDifficultyFilter = .adept
        }

        // Update tab visuals
        updateTabVisuals()
        populateLeaderboardList()
    }

    private func updateTabVisuals() {
        for child in tabContainer.children {
            guard let name = child.name,
                  let shapeNode = child.children.first as? SKShapeNode,
                  let labelNode = child.children.last as? SKLabelNode else { continue }

            let isSelected: Bool
            if name == "all" {
                isSelected = selectedDifficultyFilter == nil
            } else if name == QuasarDifficultyTier.novice.celestialTitle {
                isSelected = selectedDifficultyFilter == .novice
            } else {
                isSelected = selectedDifficultyFilter == .adept
            }

            shapeNode.fillColor = isSelected ? UIColor.mahjongAccentGold : UIColor.black.withAlphaComponent(0.3)
            shapeNode.strokeColor = isSelected ? .mahjongAccentGold : UIColor.white.withAlphaComponent(0.2)
            labelNode.fontColor = isSelected ? .obsidianDepth : .ivoryMistWhite
        }
    }

    // MARK: - Navigation
    private func navigateToHome() {
        let homeScene = CelestialHomeScene(size: size)
        homeScene.scaleMode = .aspectFill

        let transition = SKTransition.push(with: .right, duration: 0.4)
        view?.presentScene(homeScene, transition: transition)
    }

    // MARK: - Helper Methods
    private func createGradientTexture(size: CGSize, colors: [UIColor]) -> SKTexture {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()!

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let cgColors = colors.map { $0.cgColor } as CFArray
        let gradient = CGGradient(colorsSpace: colorSpace, colors: cgColors, locations: [0, 1])!

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
}
