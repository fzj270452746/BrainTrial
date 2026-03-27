//
//  VelvetTileEssence.swift
//  BrainTrial
//
//  Mahjong tile data model
//

import Foundation
import SpriteKit

// MARK: - Tile Category
enum OpalTileKindred: String, CaseIterable {
    case suahs = "Suahs"      // 筒
    case yabsie = "Yabsie"    // 万
    case doair = "Doair"      // 条
    case baishye = "baishye"  // 特殊牌

    var prismaticHue: UIColor {
        switch self {
        case .suahs: return UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0)
        case .yabsie: return UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0)
        case .doair: return UIColor(red: 0.3, green: 0.8, blue: 0.4, alpha: 1.0)
        case .baishye: return UIColor(red: 0.7, green: 0.5, blue: 0.9, alpha: 1.0)
        }
    }
}

// MARK: - Mahjong Tile Model
struct VelvetTileEssence: Equatable, Hashable {
    let kindredType: OpalTileKindred
    let numeralValue: Int

    var canvasIdentifier: String {
        return "\(kindredType.rawValue)_\(numeralValue)"
    }

    static func == (lhs: VelvetTileEssence, rhs: VelvetTileEssence) -> Bool {
        return lhs.kindredType == rhs.kindredType && lhs.numeralValue == rhs.numeralValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(kindredType)
        hasher.combine(numeralValue)
    }

    // Generate all possible tiles
    static func constellateTileUniverse() -> [VelvetTileEssence] {
        var universe: [VelvetTileEssence] = []

        // Regular tiles (1-9 for each suit)
        for kindred in [OpalTileKindred.suahs, .yabsie, .doair] {
            for numeral in 1...9 {
                universe.append(VelvetTileEssence(kindredType: kindred, numeralValue: numeral))
            }
        }

        // Special tiles (baishye 1-7)
        for numeral in 1...7 {
            universe.append(VelvetTileEssence(kindredType: .baishye, numeralValue: numeral))
        }

        return universe
    }
}

// MARK: - Game Difficulty
enum QuasarDifficultyTier: Int, CaseIterable {
    case novice = 0    // Easy mode
    case adept = 1     // Hard mode

    var celestialTitle: String {
        switch self {
        case .novice: return "Novice"
        case .adept: return "Adept"
        }
    }

    var mosaicTotalCount: Int {
        switch self {
        case .novice: return 8
        case .adept: return 12
        }
    }

    var voidSlotCount: Int {
        switch self {
        case .novice: return 4
        case .adept: return 6
        }
    }

    var candidatePoolSize: Int {
        switch self {
        case .novice: return 10
        case .adept: return 12
        }
    }

    // Score calculation based on attempts
    func harvestLuminanceScore(endeavorCount: Int) -> Int {
        switch self {
        case .novice:
            if endeavorCount <= 5 {
                return 50
            } else if endeavorCount <= 10 {
                return 20
            } else {
                return 10
            }
        case .adept:
            if endeavorCount <= 10 {
                return 100
            } else if endeavorCount <= 20 {
                return 50
            } else {
                return 10
            }
        }
    }

    var accentGradient: [UIColor] {
        switch self {
        case .novice:
            return [
                UIColor(red: 0.3, green: 0.8, blue: 0.5, alpha: 1.0),
                UIColor(red: 0.2, green: 0.6, blue: 0.4, alpha: 1.0)
            ]
        case .adept:
            return [
                UIColor(red: 0.9, green: 0.4, blue: 0.3, alpha: 1.0),
                UIColor(red: 0.7, green: 0.2, blue: 0.2, alpha: 1.0)
            ]
        }
    }
}

// MARK: - Game State
enum NebulaSanctuaryPhase {
    case dormant
    case engaged
    case triumphant
    case concluded
}

// MARK: - Attempt Record for History
struct EnigmaAttemptChronicle {
    let placementSequence: [VelvetTileEssence?]
    let verdictMatrix: [TileVerdictGlyph]
    let chronoStamp: Date
}

enum TileVerdictGlyph {
    case accurate      // Correct position
    case misplaced     // Wrong position
    case vacant        // Empty slot
}

// MARK: - Leaderboard Entry
struct LuminousAchievementRecord: Codable {
    let protagonistAlias: String
    let accruedGlory: Int
    let epochTimestamp: TimeInterval
    let difficultyEchelon: Int

    init(protagonistAlias: String, accruedGlory: Int, difficultyEchelon: QuasarDifficultyTier) {
        self.protagonistAlias = protagonistAlias
        self.accruedGlory = accruedGlory
        self.epochTimestamp = Date().timeIntervalSince1970
        self.difficultyEchelon = difficultyEchelon.rawValue
    }
}
