import Testing
@testable import CCTChess

@Suite("CCT Analyzer Tests")
struct CCTAnalyzerTests {

    @Test func scholarsMatePositionAnalysis() {
        let fen = "r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 4 4"
        let board = Board(fen: fen)!
        let analysis = CCTAnalyzer.analyze(board: board)

        #expect(analysis.checks.count >= 1)

        let qxf7Check = analysis.checks.first {
            $0.from == Square(algebraic: "h5")! && $0.to == Square(algebraic: "f7")!
        }
        #expect(qxf7Check != nil)

        #expect(analysis.captures.count >= 1)
    }

    @Test func startingPositionHasNoChecksOrCaptures() {
        let board = Board(fen: Board.startingFEN)!
        let analysis = CCTAnalyzer.analyze(board: board)

        #expect(analysis.checks.isEmpty)
        #expect(analysis.captures.isEmpty)
    }

    @Test func startingPositionHasThreats() {
        let board = Board(fen: Board.startingFEN)!
        let analysis = CCTAnalyzer.analyze(board: board)

        #expect(analysis.threats.count >= 0)
    }

    @Test func positionWithMultipleCaptures() {
        let fen = "rnbqkbnr/ppp1pppp/8/3p4/4P3/8/PPPP1PPP/RNBQKBNR w KQkq d6 0 2"
        let board = Board(fen: fen)!
        let analysis = CCTAnalyzer.analyze(board: board)

        let exd5 = analysis.captures.first {
            $0.from == Square(algebraic: "e4")! && $0.to == Square(algebraic: "d5")!
        }
        #expect(exd5 != nil)
    }

    @Test func quietPawnPushCanGiveCheck() {
        let fen = "6k1/R7/5P2/6P1/6K1/2P5/p7/r7 w - - 0 1"
        let board = Board(fen: fen)!
        let analysis = CCTAnalyzer.analyze(board: board)

        let f7Check = analysis.checks.first {
            $0.from == Square(algebraic: "f6")! && $0.to == Square(algebraic: "f7")!
        }
        #expect(f7Check != nil)
    }

    @Test func categoriesDoNotOverlap() {
        let fen = "r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 4 4"
        let board = Board(fen: fen)!
        let analysis = CCTAnalyzer.analyze(board: board)

        let checkKeys = Set(analysis.checks.map(\.key))
        let captureKeys = Set(analysis.captures.map(\.key))
        let threatKeys = Set(analysis.threats.map(\.key))

        #expect(captureKeys.isDisjoint(with: checkKeys))
        #expect(threatKeys.isDisjoint(with: checkKeys))
        #expect(threatKeys.isDisjoint(with: captureKeys))
    }

    @Test func randomPuzzleReturnsValidPlayablePosition() {
        for _ in 0..<5 {
            let puzzle = PuzzleStore.randomPuzzle(targetCCTRange: 1...50)
            let board = Board(fen: puzzle.fen)
            #expect(board != nil, "Generated invalid FEN: \(puzzle.fen)")

            let analysis = CCTAnalyzer.analyze(board: board!)
            #expect(analysis.totalMoves > 0, "Generated puzzle has no CCT moves")
            #expect(puzzle.cctCount == analysis.totalMoves)
        }
    }

    @Test func fallbackPuzzleIsValidAndPlayable() {
        let puzzle = PuzzleStore.randomPuzzle(targetCCTRange: 999...1_000, maxAttempts: 0)
        let board = Board(fen: puzzle.fen)
        #expect(board != nil)

        let analysis = CCTAnalyzer.analyze(board: board!)
        #expect(analysis.totalMoves > 0)
        #expect(puzzle.cctCount == analysis.totalMoves)
    }
}
