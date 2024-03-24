import SwiftUI

@Observable
@MainActor
final class PuzzleViewModel {
    let puzzle: Puzzle
    let board: Board
    let analysis: CCTAnalysis
    private let legalMoves: [Move]

    private(set) var currentPhase: CCTCategory = .check
    private(set) var selectedSquare: Square?
    private(set) var foundChecks: Set<MoveKey> = []
    private(set) var foundCaptures: Set<MoveKey> = []
    private(set) var foundThreats: Set<MoveKey> = []
    private(set) var checksComplete = false
    private(set) var capturesComplete = false
    private(set) var threatsComplete = false
    private(set) var checksGivenUp = false
    private(set) var capturesGivenUp = false
    private(set) var threatsGivenUp = false
    private(set) var allPhasesComplete = false
    private(set) var showingPhaseComplete = false
    private(set) var showingGiveUpConfirmation = false
    private(set) var completedPhaseName = ""
    private(set) var moveFeedback: MoveFeedback?

    let startTime = Date()

    init(puzzle: Puzzle) {
        self.puzzle = puzzle
        let parsedBoard = Board(fen: puzzle.fen) ?? Board()
        self.board = parsedBoard
        self.analysis = CCTAnalyzer.analyze(board: parsedBoard)
        self.legalMoves = MoveGenerator.legalMoves(for: parsedBoard)
    }

    var currentPhaseExpectedMoves: [Move] {
        CCTAnalyzer.movesForCategory(currentPhase, in: analysis)
    }

    var currentPhaseFoundKeys: Set<MoveKey> {
        switch currentPhase {
        case .check: return foundChecks
        case .capture: return foundCaptures
        case .threat: return foundThreats
        }
    }

    var currentPhaseAllFound: Bool {
        currentPhaseFoundKeys.count >= currentPhaseExpectedMoves.count
    }

    var currentPhaseHasUnfoundMoves: Bool {
        currentPhaseFoundKeys.count < currentPhaseExpectedMoves.count
    }

    var giveUpActionTitle: String {
        showingGiveUpConfirmation ? "Record misses" : "I'm stuck"
    }

    var giveUpActionSystemImage: String {
        showingGiveUpConfirmation ? "exclamationmark.triangle.fill" : "questionmark.circle"
    }

    var legalTargets: Set<Square> {
        guard let source = selectedSquare else { return [] }
        let moves = legalMoves.filter { $0.from == source }
        return Set(moves.map(\.to))
    }

    func progressText(hideCounts: Bool) -> String {
        let found = currentPhaseFoundKeys.count
        let total = currentPhaseExpectedMoves.count
        if hideCounts {
            return "\(found) \(currentPhase.rawValue) found"
        }
        return "\(found)/\(total) \(currentPhase.rawValue)"
    }

    func selectSquare(_ square: Square) {
        guard !showingPhaseComplete else { return }

        if let source = selectedSquare {
            if legalTargets.contains(square) {
                attemptMove(from: source, to: square)
                return
            }
            if square == source {
                selectedSquare = nil
                return
            }
        }

        if let piece = board.piece(at: square), piece.color == board.activeColor {
            let hasLegalMoves = legalMoves.contains { $0.from == square }
            selectedSquare = hasLegalMoves ? square : nil
        } else {
            selectedSquare = nil
        }
    }

    func attemptMove(from source: Square, to destination: Square) {
        guard !showingPhaseComplete else { return }

        guard let legalMove = legalMoves.first(where: { $0.from == source && $0.to == destination }) else {
            selectedSquare = nil
            return
        }

        let moveKey = legalMove.key
        let matchingMove = currentPhaseExpectedMoves.first { $0.key == moveKey }

        if let matchingMove {
            let wasNew: Bool
            switch currentPhase {
            case .check:
                wasNew = foundChecks.insert(moveKey).inserted
            case .capture:
                wasNew = foundCaptures.insert(moveKey).inserted
            case .threat:
                wasNew = foundThreats.insert(moveKey).inserted
            }

            showMoveFeedback(for: matchingMove, isNew: wasNew)

            if wasNew {
                showingGiveUpConfirmation = false
            }

            if wasNew && currentPhaseAllFound {
                triggerPhaseCompletion()
            }
        } else {
            showLegalMoveFeedback(for: legalMove)
        }

        selectedSquare = nil
    }

    func continuePhase() {
        guard !showingPhaseComplete else { return }
        guard currentPhaseAllFound else { return }

        showingGiveUpConfirmation = false
        triggerPhaseCompletion()
    }

    func handleGiveUpAction() {
        guard !showingPhaseComplete, currentPhaseHasUnfoundMoves else { return }

        if showingGiveUpConfirmation {
            giveUpCurrentPhase()
        } else {
            showingGiveUpConfirmation = true
        }
    }

    func prepareCurrentPhase() {
        guard !showingPhaseComplete, currentPhaseAllFound else { return }
        triggerPhaseCompletion()
    }

    private func giveUpCurrentPhase() {
        showingGiveUpConfirmation = false
        advanceToNextPhase(solved: false)
    }

    private func triggerPhaseCompletion() {
        completedPhaseName = currentPhase.rawValue
        showingPhaseComplete = true

        Task {
            try? await Task.sleep(for: .seconds(1.5))
            showingPhaseComplete = false
            advanceToNextPhase(solved: true)
        }
    }

    private func advanceToNextPhase(solved: Bool) {
        switch currentPhase {
        case .check:
            checksComplete = solved
            checksGivenUp = !solved
            currentPhase = .capture
        case .capture:
            capturesComplete = solved
            capturesGivenUp = !solved
            currentPhase = .threat
        case .threat:
            threatsComplete = solved
            threatsGivenUp = !solved
            allPhasesComplete = true
        }
        selectedSquare = nil
        moveFeedback = nil
        if !allPhasesComplete {
            prepareCurrentPhase()
        }
    }

    private func showMoveFeedback(for move: Move, isNew: Bool) {
        let feedback = MoveFeedback(
            from: move.from,
            to: move.to,
            category: currentPhase,
            notation: move.notation,
            isNew: isNew
        )
        moveFeedback = feedback

        Task {
            try? await Task.sleep(for: .milliseconds(900))
            if moveFeedback?.id == feedback.id {
                moveFeedback = nil
            }
        }
    }

    private func showLegalMoveFeedback(for move: Move) {
        let feedback = MoveFeedback(
            from: move.from,
            to: move.to,
            category: nil,
            notation: move.notation,
            isNew: false
        )
        moveFeedback = feedback

        Task {
            try? await Task.sleep(for: .milliseconds(700))
            if moveFeedback?.id == feedback.id {
                moveFeedback = nil
            }
        }
    }

    func foundMoves(for category: CCTCategory) -> [Move] {
        let foundKeys: Set<MoveKey> = switch category {
        case .check: foundChecks
        case .capture: foundCaptures
        case .threat: foundThreats
        }
        return CCTAnalyzer.movesForCategory(category, in: analysis).filter { foundKeys.contains($0.key) }
    }

    func buildAttempt() -> PuzzleAttempt {
        PuzzleAttempt(
            puzzleId: puzzle.id,
            checksFound: foundChecks.count,
            checksTotal: analysis.checks.count,
            capturesFound: foundCaptures.count,
            capturesTotal: analysis.captures.count,
            threatsFound: foundThreats.count,
            threatsTotal: analysis.threats.count,
            timeSpentSeconds: Date().timeIntervalSince(startTime),
            cctCount: analysis.totalMoves
        )
    }

    var missedChecks: [Move] {
        analysis.checks.filter { !foundChecks.contains($0.key) }
    }

    var missedCaptures: [Move] {
        analysis.captures.filter { !foundCaptures.contains($0.key) }
    }

    var missedThreats: [Move] {
        analysis.threats.filter { !foundThreats.contains($0.key) }
    }
}
