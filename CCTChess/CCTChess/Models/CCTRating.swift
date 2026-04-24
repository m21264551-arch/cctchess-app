import Foundation
import SwiftData

@Model
final class CCTRating {
    var rating: Double
    var gamesPlayed: Int
    var lastUpdated: Date

    init(rating: Double = 1000, gamesPlayed: Int = 0, lastUpdated: Date = Date()) {
        self.rating = rating
        self.gamesPlayed = gamesPlayed
        self.lastUpdated = lastUpdated
    }

    func update(accuracy: Double, puzzleDifficulty: Int) {
        let k: Double = gamesPlayed < 10 ? 64 : (gamesPlayed < 30 ? 32 : 16)

        let difficultyRating = Self.ratingForCCTCount(puzzleDifficulty)
        let expected = 1.0 / (1.0 + pow(10.0, (difficultyRating - rating) / 400.0))
        let score = accuracy
        rating = max(400, min(2400, rating + k * (score - expected)))
        gamesPlayed += 1
        lastUpdated = Date()
    }

    static func ratingForCCTCount(_ count: Int) -> Double {
        switch count {
        case ...3: return 600
        case 4...6: return 800
        case 7...10: return 1000
        case 11...15: return 1200
        case 16...20: return 1400
        case 21...28: return 1600
        case 29...36: return 1800
        default: return 2000
        }
    }

    var targetCCTRange: ClosedRange<Int> {
        switch rating {
        case ..<700: return 2...5
        case 700..<900: return 3...8
        case 900..<1100: return 5...12
        case 1100..<1300: return 8...18
        case 1300..<1500: return 12...24
        case 1500..<1700: return 16...30
        case 1700..<1900: return 20...36
        default: return 24...50
        }
    }

    var ratingTier: String {
        switch rating {
        case ..<700: return "Novice"
        case 700..<900: return "Beginner"
        case 900..<1100: return "Intermediate"
        case 1100..<1300: return "Advanced"
        case 1300..<1500: return "Expert"
        case 1500..<1700: return "Master"
        case 1700..<1900: return "Grandmaster"
        default: return "Legend"
        }
    }
}
