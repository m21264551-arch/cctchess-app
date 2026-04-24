import Testing
@testable import CCTChess

@MainActor
@Suite("Puzzle View Model Tests")
struct PuzzleViewModelTests {

    @Test func selectionUsesAllLegalMovesNotOnlyCurrentCCTCategory() {
        let puzzle = Puzzle(id: "starting-position", fen: Board.startingFEN, cctCount: 0)
        let viewModel = PuzzleViewModel(puzzle: puzzle)
        let source = Square(algebraic: "e2")!

        viewModel.selectSquare(source)

        #expect(viewModel.selectedSquare == source)
        #expect(viewModel.legalTargets.contains(Square(algebraic: "e3")!))
        #expect(viewModel.legalTargets.contains(Square(algebraic: "e4")!))
    }

    @Test func legalMoveOutsideCurrentCCTCategoryDoesNotCountAsFound() {
        let puzzle = Puzzle(id: "starting-position", fen: Board.startingFEN, cctCount: 0)
        let viewModel = PuzzleViewModel(puzzle: puzzle)

        viewModel.attemptMove(from: Square(algebraic: "e2")!, to: Square(algebraic: "e4")!)

        #expect(viewModel.foundChecks.isEmpty)
        #expect(viewModel.foundCaptures.isEmpty)
        #expect(viewModel.foundThreats.isEmpty)
        #expect(viewModel.selectedSquare == nil)
    }

    @Test func continuePhaseDoesNotAdvanceWhenCurrentPhaseHasUnfoundMoves() {
        let puzzle = Puzzle(
            id: "scholars-mate",
            fen: "r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 4 4",
            cctCount: 0
        )
        let viewModel = PuzzleViewModel(puzzle: puzzle)

        viewModel.continuePhase()

        #expect(viewModel.currentPhase == .check)
        #expect(!viewModel.checksComplete)
        #expect(!viewModel.checksGivenUp)
    }

    @Test func giveUpRequiresConfirmationAndRecordsPhaseAsMissed() {
        let puzzle = Puzzle(
            id: "scholars-mate",
            fen: "r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 4 4",
            cctCount: 0
        )
        let viewModel = PuzzleViewModel(puzzle: puzzle)

        viewModel.handleGiveUpAction()

        #expect(viewModel.currentPhase == .check)
        #expect(viewModel.showingGiveUpConfirmation)

        viewModel.handleGiveUpAction()

        #expect(viewModel.currentPhase == .capture)
        #expect(!viewModel.checksComplete)
        #expect(viewModel.checksGivenUp)
    }
}
