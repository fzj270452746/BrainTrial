//
//  CelestialExtensions.swift
//  BrainTrial
//
//  Utility extensions for the game
//

import Foundation
import SpriteKit

// MARK: - Screen Dimension Utilities
struct HorizonCanvasMeasure {
    static var canvasWidth: CGFloat {
        return UIScreen.main.bounds.width
    }

    static var canvasHeight: CGFloat {
        return UIScreen.main.bounds.height
    }

    static var safePadding: UIEdgeInsets {
        if #available(iOS 15.0, *) {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            return windowScene?.windows.first?.safeAreaInsets ?? .zero
        } else {
            return UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
        }
    }

    static var proportionalScale: CGFloat {
        let baseWidth: CGFloat = 375.0 // iPhone SE width
        return min(canvasWidth / baseWidth, 1.3)
    }

    static var isCompactDevice: Bool {
        return canvasHeight < 700
    }

    static var tileOptimalDimension: CGFloat {
        let baseSize: CGFloat = 60.0
        return baseSize * proportionalScale
    }
}

// MARK: - UIColor Extensions
extension UIColor {
    static let velvetJadeGreen = UIColor(red: 0.0, green: 0.5, blue: 0.4, alpha: 1.0)
    static let crimsonEmberGlow = UIColor(red: 0.85, green: 0.2, blue: 0.25, alpha: 1.0)
    static let aureolaGoldShimmer = UIColor(red: 0.95, green: 0.75, blue: 0.2, alpha: 1.0)
    static let obsidianDepth = UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
    static let ivoryMistWhite = UIColor(red: 0.98, green: 0.96, blue: 0.92, alpha: 1.0)
    static let azureTwilightBlue = UIColor(red: 0.2, green: 0.4, blue: 0.7, alpha: 1.0)
    static let amethystDuskPurple = UIColor(red: 0.5, green: 0.3, blue: 0.7, alpha: 1.0)
    static let celadonMintFresh = UIColor(red: 0.6, green: 0.85, blue: 0.75, alpha: 1.0)

    // Mahjong theme colors
    static let mahjongTableFelt = UIColor(red: 0.15, green: 0.35, blue: 0.25, alpha: 1.0)
    static let mahjongTileFace = UIColor(red: 0.98, green: 0.96, blue: 0.90, alpha: 1.0)
    static let mahjongTileShadow = UIColor(red: 0.7, green: 0.65, blue: 0.55, alpha: 1.0)
    static let mahjongAccentRed = UIColor(red: 0.8, green: 0.15, blue: 0.15, alpha: 1.0)
    static let mahjongAccentGold = UIColor(red: 0.85, green: 0.7, blue: 0.3, alpha: 1.0)

    convenience init(hexadecimalCipher: String) {
        let hex = hexadecimalCipher.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }

    func luminanceAdjusted(by factor: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: min(b * factor, 1.0), alpha: a)
    }
}

// MARK: - CGPoint Extensions
extension CGPoint {
    func euclideanDistance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }

    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}

// MARK: - SKNode Extensions
extension SKNode {
    func celestialPulseAnimation(duration: TimeInterval = 0.3, scaleFactor: CGFloat = 1.1) {
        let scaleUp = SKAction.scale(to: scaleFactor, duration: duration / 2)
        let scaleDown = SKAction.scale(to: 1.0, duration: duration / 2)
        scaleUp.timingMode = .easeOut
        scaleDown.timingMode = .easeIn
        run(SKAction.sequence([scaleUp, scaleDown]))
    }

    func etherealFadeIn(duration: TimeInterval = 0.4) {
        alpha = 0
        let fadeIn = SKAction.fadeIn(withDuration: duration)
        fadeIn.timingMode = .easeOut
        run(fadeIn)
    }

    func etherealFadeOut(duration: TimeInterval = 0.4, completion: (() -> Void)? = nil) {
        let fadeOut = SKAction.fadeOut(withDuration: duration)
        fadeOut.timingMode = .easeIn
        run(fadeOut) {
            completion?()
        }
    }

    func prismaticShakeMotion(intensity: CGFloat = 5.0, duration: TimeInterval = 0.4) {
        let shakeCount = 6
        let interval = duration / Double(shakeCount)
        var actions: [SKAction] = []

        for i in 0..<shakeCount {
            let offset = (i % 2 == 0 ? intensity : -intensity) * CGFloat(shakeCount - i) / CGFloat(shakeCount)
            let move = SKAction.moveBy(x: offset, y: 0, duration: interval)
            actions.append(move)
        }

        run(SKAction.sequence(actions))
    }
}

// MARK: - Array Extensions
extension Array {
    func constellateShuffled() -> [Element] {
        var result = self
        for i in stride(from: count - 1, through: 1, by: -1) {
            let j = Int.random(in: 0...i)
            result.swapAt(i, j)
        }
        return result
    }

    mutating func stellarShuffle() {
        self = constellateShuffled()
    }
}

// MARK: - String Extensions
extension String {
    func celestialLocalized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}

// MARK: - UserDefaults Keys
struct AetherPersistenceKeys {
    static let cumulativeGloryScore = "nebula_cumulative_glory_score"
    static let leaderboardChronicles = "nebula_leaderboard_chronicles"
    static let hasCompletedTutorial = "nebula_tutorial_completion_flag"
    static let preferredDifficultyTier = "nebula_preferred_difficulty"
    static let soundEffectsEnabled = "nebula_sound_effects_toggle"
    static let hapticFeedbackEnabled = "nebula_haptic_feedback_toggle"
}

// MARK: - Haptic Feedback Manager
class ZenithHapticOrchestrator {
    static let shared = ZenithHapticOrchestrator()

    private var isHapticEnabled: Bool {
        return UserDefaults.standard.bool(forKey: AetherPersistenceKeys.hapticFeedbackEnabled)
    }

    private init() {
        // Set default value if not set
        if UserDefaults.standard.object(forKey: AetherPersistenceKeys.hapticFeedbackEnabled) == nil {
            UserDefaults.standard.set(true, forKey: AetherPersistenceKeys.hapticFeedbackEnabled)
        }
    }

    func triggerSelectionVibration() {
        guard isHapticEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    func triggerImpactVibration(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard isHapticEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    func triggerNotificationVibration(type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isHapticEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}
