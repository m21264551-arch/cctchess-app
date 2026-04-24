import Foundation

struct CCTAnalysis: Sendable {
    let checks: [Move]
    let captures: [Move]
    let threats: [Move]

    var totalMoves: Int { checks.count + captures.count + threats.count }
}

struct CCTAnalyzer: Sendable {

    static func analyze(board: Board) -> CCTAnalysis {
        let allMoves = MoveGenerator.legalMoves(for: board)

        var checks: [Move] = []
        var captures: [Move] = []
        var threats: [Move] = []
        var checkKeys: Set<MoveKey> = []
        var captureKeys: Set<MoveKey> = []

        for move in allMoves {
            let newBoard = board.applying(move)
            if newBoard.isInCheck(color: board.activeColor.opposite) {
                checks.append(move)
                checkKeys.insert(move.key)
            }
        }

        for move in allMoves {
            if move.capturedPiece != nil && !checkKeys.contains(move.key) {
                captures.append(move)
                captureKeys.insert(move.key)
            }
        }

        for move in allMoves {
            let key = move.key
            guard !checkKeys.contains(key) && !captureKeys.contains(key) else { continue }

            let newBoard = board.applying(move)
            let attackedSquares = MoveGenerator.attackSquares(for: move.promotion.map { Piece(type: $0, color: move.piece.color) } ?? move.piece, at: move.to, on: newBoard)
            let createsNewThreat = attackedSquares.contains { sq in
                if let target = newBoard.piece(at: sq), target.color == board.activeColor.opposite, target.type != .king {
                    return true
                }
                return false
            }

            if createsNewThreat {
                threats.append(move)
            }
        }

        return CCTAnalysis(checks: checks, captures: captures, threats: threats)
    }

    static func movesForCategory(_ category: CCTCategory, in analysis: CCTAnalysis) -> [Move] {
        switch category {
        case .check: return analysis.checks
        case .capture: return analysis.captures
        case .threat: return analysis.threats
        }
    }
}
