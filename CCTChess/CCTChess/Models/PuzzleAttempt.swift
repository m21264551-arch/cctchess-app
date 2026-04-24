import Foundation
import SwiftData

@Model
final class PuzzleAttempt {
    var puzzleId: String
    var date: Date
    var checksFound: Int
    var checksTotal: Int
    var capturesFound: Int
    var capturesTotal: Int
    var threatsFound: Int
    var threatsTotal: Int
    var timeSpentSeconds: Double
    var cctCount: Int
    var ratingBefore: Double
    var ratingAfter: Double

    var overallAccuracy: Double {
        let total = checksTotal + capturesTotal + threatsTotal
        guard total > 0 else { return 0 }
        let found = checksFound + capturesFound + threatsFound
        return Double(found) / Double(total)
    }

    var checkAccuracy: Double {
        guard checksTotal > 0 else { return 1.0 }
        return Double(checksFound) / Double(checksTotal)
    }

    var captureAccuracy: Double {
        guard capturesTotal > 0 else { return 1.0 }
        return Double(capturesFound) / Double(capturesTotal)
    }

    var threatAccuracy: Double {
        guard threatsTotal > 0 else { return 1.0 }
        return Double(threatsFound) / Double(threatsTotal)
    }

    var ratingChange: Double {
        ratingAfter - ratingBefore
    }

    init(puzzleId: String, date: Date = Date(), checksFound: Int, checksTotal: Int,
         capturesFound: Int, capturesTotal: Int, threatsFound: Int, threatsTotal: Int,
         timeSpentSeconds: Double, cctCount: Int = 0, ratingBefore: Double = 0, ratingAfter: Double = 0) {
        self.puzzleId = puzzleId
        self.date = date
        self.checksFound = checksFound
        self.checksTotal = checksTotal
        self.capturesFound = capturesFound
        self.capturesTotal = capturesTotal
        self.threatsFound = threatsFound
        self.threatsTotal = threatsTotal
        self.timeSpentSeconds = timeSpentSeconds
        self.cctCount = cctCount
        self.ratingBefore = ratingBefore
        self.ratingAfter = ratingAfter
    }
}
