//
//  ZenithPuzzleOrchestrator.swift
//  BrainTrial
//
//  Core game logic manager
//

import Foundation

protocol ZenithPuzzleOrchestratorDelegate: AnyObject {
    func puzzleStateDidUpdate()
    func puzzleAttemptCompleted(isCorrect: Bool, verdicts: [TileVerdictGlyph])
    func puzzleTriumphAchieved(score: Int, attempts: Int)
}

class ZenithPuzzleOrchestrator {

    // MARK: - Properties
    weak var delegateHandler: ZenithPuzzleOrchestratorDelegate?

    private(set) var currentDifficulty: QuasarDifficultyTier = .novice
    private(set) var sanctuaryPhase: NebulaSanctuaryPhase = .dormant

    // The complete original tile arrangement
    private(set) var primordialArrangement: [VelvetTileEssence] = []

    // Current display state (with some positions as nil for empty slots)
    private(set) var visibleMosaic: [VelvetTileEssence?] = []

    // Indices of slots that are empty (need to be filled)
    private(set) var voidSlotIndices: [Int] = []

    // Tiles available in player's hand
    private(set) var candidateHandTiles: [VelvetTileEssence] = []

    // Current player placement attempt
    private(set) var currentPlacement: [Int: VelvetTileEssence] = [:]

    // History of attempts
    private(set) var attemptChronicles: [EnigmaAttemptChronicle] = []

    // Game statistics
    private(set) var endeavorCount: Int = 0

    // Currently selected tile from hand
    var selectedHandTile: VelvetTileEssence?

    // MARK: - Initialization
    init() {}

    // MARK: - Game Setup
    func initiatePuzzleSession(difficulty: QuasarDifficultyTier) {
        currentDifficulty = difficulty
        sanctuaryPhase = .engaged
        endeavorCount = 0
        attemptChronicles = []
        currentPlacement = [:]
        selectedHandTile = nil

        synthesizePuzzleConfiguration()
    }

    private func synthesizePuzzleConfiguration() {
        // Get all available tiles
        let tileUniverse = VelvetTileEssence.constellateTileUniverse()

        // Shuffle and pick tiles for the puzzle
        let shuffledTiles = tileUniverse.constellateShuffled()
        primordialArrangement = Array(shuffledTiles.prefix(currentDifficulty.mosaicTotalCount))

        // Create visible mosaic with all tiles initially
        visibleMosaic = primordialArrangement

        // Randomly select which positions will be empty
        var allIndices = Array(0..<currentDifficulty.mosaicTotalCount)
        allIndices.stellarShuffle()
        voidSlotIndices = Array(allIndices.prefix(currentDifficulty.voidSlotCount)).sorted()

        // Extract the tiles that will be removed (these go to player's hand)
        var removedTiles: [VelvetTileEssence] = []
        for index in voidSlotIndices {
            if let tile = visibleMosaic[index] {
                removedTiles.append(tile)
            }
            visibleMosaic[index] = nil
        }

        // Create candidate hand tiles (removed tiles + some distractors)
        candidateHandTiles = removedTiles

        // Add distractor tiles (tiles not in the puzzle)
        let distractorCount = currentDifficulty.candidatePoolSize - removedTiles.count
        let remainingTiles = shuffledTiles.filter { tile in
            !primordialArrangement.contains(tile)
        }
        let distractors = Array(remainingTiles.prefix(distractorCount))
        candidateHandTiles.append(contentsOf: distractors)

        // Shuffle the hand tiles
        candidateHandTiles.stellarShuffle()

        delegateHandler?.puzzleStateDidUpdate()
    }

    // MARK: - Gameplay Actions
    func selectHandTile(_ tile: VelvetTileEssence) {
        selectedHandTile = tile
    }

    func deselectHandTile() {
        selectedHandTile = nil
    }

    func placeTileInSlot(slotIndex: Int) -> Bool {
        guard let tile = selectedHandTile,
              voidSlotIndices.contains(slotIndex),
              currentPlacement[slotIndex] == nil else {
            return false
        }

        currentPlacement[slotIndex] = tile

        // Remove from hand
        if let handIndex = candidateHandTiles.firstIndex(of: tile) {
            candidateHandTiles.remove(at: handIndex)
        }

        selectedHandTile = nil
        delegateHandler?.puzzleStateDidUpdate()

        return true
    }

    func removeTileFromSlot(slotIndex: Int) -> VelvetTileEssence? {
        guard let tile = currentPlacement[slotIndex] else {
            return nil
        }

        currentPlacement.removeValue(forKey: slotIndex)
        candidateHandTiles.append(tile)

        delegateHandler?.puzzleStateDidUpdate()

        return tile
    }

    func executeAttemptValidation() {
        guard allSlotsAreFilled() else { return }

        endeavorCount += 1

        // Build the complete placement sequence
        var placementSequence: [VelvetTileEssence?] = visibleMosaic

        for (index, tile) in currentPlacement {
            placementSequence[index] = tile
        }

        // Evaluate each placement
        var verdicts: [TileVerdictGlyph] = Array(repeating: .vacant, count: currentDifficulty.mosaicTotalCount)
        var allCorrect = true

        for i in 0..<currentDifficulty.mosaicTotalCount {
            if voidSlotIndices.contains(i) {
                // This is a slot that needed to be filled
                if let placedTile = currentPlacement[i] {
                    if placedTile == primordialArrangement[i] {
                        verdicts[i] = .accurate
                    } else {
                        verdicts[i] = .misplaced
                        allCorrect = false
                    }
                } else {
                    verdicts[i] = .vacant
                    allCorrect = false
                }
            } else {
                // This slot was already filled correctly
                verdicts[i] = .accurate
            }
        }

        // Record attempt
        let chronicle = EnigmaAttemptChronicle(
            placementSequence: placementSequence,
            verdictMatrix: verdicts,
            chronoStamp: Date()
        )
        attemptChronicles.append(chronicle)

        if allCorrect {
            // Victory!
            sanctuaryPhase = .triumphant
            let score = currentDifficulty.harvestLuminanceScore(endeavorCount: endeavorCount)
            delegateHandler?.puzzleTriumphAchieved(score: score, attempts: endeavorCount)
        } else {
            // Reset for next attempt
            resetCurrentAttempt()
            delegateHandler?.puzzleAttemptCompleted(isCorrect: false, verdicts: verdicts)
        }
    }

    // MARK: - Helper Methods
    func allSlotsAreFilled() -> Bool {
        for index in voidSlotIndices {
            if currentPlacement[index] == nil {
                return false
            }
        }
        return true
    }

    private func resetCurrentAttempt() {
        // Return all placed tiles to hand
        for (_, tile) in currentPlacement {
            candidateHandTiles.append(tile)
        }
        currentPlacement = [:]
        candidateHandTiles.stellarShuffle()

        delegateHandler?.puzzleStateDidUpdate()
    }

    func getTileAtSlot(_ index: Int) -> VelvetTileEssence? {
        if let placedTile = currentPlacement[index] {
            return placedTile
        }
        return visibleMosaic[index]
    }

    func isSlotVoid(_ index: Int) -> Bool {
        return voidSlotIndices.contains(index)
    }

    func getVerdictForSlot(_ index: Int, in chronicle: EnigmaAttemptChronicle) -> TileVerdictGlyph {
        guard index < chronicle.verdictMatrix.count else { return .vacant }
        return chronicle.verdictMatrix[index]
    }
}
