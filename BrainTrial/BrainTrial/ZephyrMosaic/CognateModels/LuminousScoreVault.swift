//
//  LuminousScoreVault.swift
//  BrainTrial
//
//  Leaderboard and score persistence manager
//

import Foundation

class LuminousScoreVault {

    static let shared = LuminousScoreVault()

    private let chroniclesKey = AetherPersistenceKeys.leaderboardChronicles
    private let cumulativeScoreKey = AetherPersistenceKeys.cumulativeGloryScore

    private(set) var achievementRecords: [LuminousAchievementRecord] = []
    private(set) var cumulativeGlory: Int = 0

    private init() {
        loadPersistedData()
    }

    // MARK: - Data Loading
    private func loadPersistedData() {
        cumulativeGlory = UserDefaults.standard.integer(forKey: cumulativeScoreKey)

        if let data = UserDefaults.standard.data(forKey: chroniclesKey),
           let records = try? JSONDecoder().decode([LuminousAchievementRecord].self, from: data) {
            achievementRecords = records.sorted { $0.accruedGlory > $1.accruedGlory }
        }
    }

    // MARK: - Score Management
    func accumulateTriumphScore(_ score: Int) {
        cumulativeGlory += score
        UserDefaults.standard.set(cumulativeGlory, forKey: cumulativeScoreKey)
    }

    func inscribeAchievement(alias: String, score: Int, difficulty: QuasarDifficultyTier) {
        let record = LuminousAchievementRecord(
            protagonistAlias: alias,
            accruedGlory: score,
            difficultyEchelon: difficulty
        )

        achievementRecords.append(record)
        achievementRecords.sort { $0.accruedGlory > $1.accruedGlory }

        // Keep only top 100 records
        if achievementRecords.count > 100 {
            achievementRecords = Array(achievementRecords.prefix(100))
        }

        persistRecords()
    }

    private func persistRecords() {
        if let data = try? JSONEncoder().encode(achievementRecords) {
            UserDefaults.standard.set(data, forKey: chroniclesKey)
        }
    }

    // MARK: - Leaderboard Queries
    func fetchTopRecords(count: Int = 10) -> [LuminousAchievementRecord] {
        return Array(achievementRecords.prefix(count))
    }

    func fetchRecordsForDifficulty(_ difficulty: QuasarDifficultyTier, count: Int = 10) -> [LuminousAchievementRecord] {
        let filtered = achievementRecords.filter { $0.difficultyEchelon == difficulty.rawValue }
        return Array(filtered.prefix(count))
    }

    func determineRankPosition(for score: Int) -> Int {
        var rank = 1
        for record in achievementRecords {
            if score > record.accruedGlory {
                return rank
            }
            rank += 1
        }
        return rank
    }

    // MARK: - Statistics
    func calculateTotalGamesPlayed() -> Int {
        return achievementRecords.count
    }

    func calculateAverageScore() -> Double {
        guard !achievementRecords.isEmpty else { return 0 }
        let total = achievementRecords.reduce(0) { $0 + $1.accruedGlory }
        return Double(total) / Double(achievementRecords.count)
    }

    func fetchHighestScore() -> Int {
        return achievementRecords.first?.accruedGlory ?? 0
    }

    // MARK: - Data Management
    func purgeAllRecords() {
        achievementRecords = []
        cumulativeGlory = 0
        UserDefaults.standard.removeObject(forKey: chroniclesKey)
        UserDefaults.standard.set(0, forKey: cumulativeScoreKey)
    }
}

// MARK: - Score Display Formatter
struct GloryDisplayFormatter {

    static func formatScore(_ score: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: score)) ?? "\(score)"
    }

    static func formatDate(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    static func formatRelativeDate(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    static func formatRank(_ rank: Int) -> String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "#\(rank)"
        }
    }
}
