import Foundation

struct PuzzleStore: Sendable {
    static func randomPuzzle(targetCCTRange: ClosedRange<Int>, maxAttempts: Int = 80) -> Puzzle {
        let db = FENDatabase.shared
        var firstPlayablePuzzle: Puzzle?

        for _ in 0..<maxAttempts {
            guard let fen = db.randomFEN(),
                  let puzzle = playablePuzzle(from: fen) else { continue }

            firstPlayablePuzzle = firstPlayablePuzzle ?? puzzle

            if targetCCTRange.contains(puzzle.cctCount) {
                return puzzle
            }
        }

        return firstPlayablePuzzle ?? fallbackPuzzle
    }

    private static func playablePuzzle(from fen: String, id: String = UUID().uuidString) -> Puzzle? {
        guard let board = Board(fen: fen) else { return nil }
        let totalCCT = CCTAnalyzer.analyze(board: board).totalMoves
        guard totalCCT >= 1 else { return nil }
        return Puzzle(
            id: id,
            fen: fen,
            cctCount: totalCCT
        )
    }

    private static let fallbackFEN = "r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 4 4"
    private static let fallbackPuzzle = playablePuzzle(from: fallbackFEN, id: "fallback") ?? Puzzle(id: "fallback", fen: fallbackFEN, cctCount: 1)
}
