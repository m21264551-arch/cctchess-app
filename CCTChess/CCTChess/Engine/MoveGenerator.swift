import Foundation

struct MoveGenerator: Sendable {

    static func legalMoves(for board: Board) -> [Move] {
        pseudoLegalMoves(for: board).filter { move in
            let newBoard = board.applying(move)
            return !newBoard.isInCheck(color: board.activeColor)
        }
    }

    static func pseudoLegalMoves(for board: Board) -> [Move] {
        var moves: [Move] = []
        for (square, piece) in board.allPieces(of: board.activeColor) {
            switch piece.type {
            case .pawn: moves.append(contentsOf: pawnMoves(from: square, piece: piece, board: board))
            case .knight: moves.append(contentsOf: knightMoves(from: square, piece: piece, board: board))
            case .bishop: moves.append(contentsOf: slidingMoves(from: square, piece: piece, directions: diagonals, board: board))
            case .rook: moves.append(contentsOf: slidingMoves(from: square, piece: piece, directions: straights, board: board))
            case .queen: moves.append(contentsOf: slidingMoves(from: square, piece: piece, directions: diagonals + straights, board: board))
            case .king: moves.append(contentsOf: kingMoves(from: square, piece: piece, board: board))
            }
        }
        return moves
    }

    private static let diagonals = [(1,1),(1,-1),(-1,1),(-1,-1)]
    private static let straights = [(0,1),(0,-1),(1,0),(-1,0)]
    private static let knightOffsets = [(1,2),(2,1),(2,-1),(1,-2),(-1,-2),(-2,-1),(-2,1),(-1,2)]

    private static func pawnMoves(from: Square, piece: Piece, board: Board) -> [Move] {
        var moves: [Move] = []
        let dir = piece.color == .white ? 1 : -1
        let startRank = piece.color == .white ? 1 : 6
        let promoRank = piece.color == .white ? 7 : 0
        let promoTypes: [PieceType] = [.queen, .rook, .bishop, .knight]

        if let fwd = from.offset(df: 0, dr: dir), board.isEmpty(at: fwd) {
            if fwd.rank == promoRank {
                for promo in promoTypes {
                    moves.append(Move(from: from, to: fwd, piece: piece, promotion: promo))
                }
            } else {
                moves.append(Move(from: from, to: fwd, piece: piece))
            }

            if from.rank == startRank, let fwd2 = from.offset(df: 0, dr: dir * 2), board.isEmpty(at: fwd2) {
                moves.append(Move(from: from, to: fwd2, piece: piece))
            }
        }

        for df in [-1, 1] {
            guard let diag = from.offset(df: df, dr: dir) else { continue }

            if let target = board.piece(at: diag), target.color != piece.color {
                if diag.rank == promoRank {
                    for promo in promoTypes {
                        moves.append(Move(from: from, to: diag, piece: piece, capturedPiece: target, promotion: promo))
                    }
                } else {
                    moves.append(Move(from: from, to: diag, piece: piece, capturedPiece: target))
                }
            }

            if diag == board.enPassantTarget {
                let capturedPawn = Piece(type: .pawn, color: piece.color.opposite)
                moves.append(Move(from: from, to: diag, piece: piece, capturedPiece: capturedPawn, isEnPassant: true))
            }
        }

        return moves
    }

    private static func knightMoves(from: Square, piece: Piece, board: Board) -> [Move] {
        var moves: [Move] = []
        for (df, dr) in knightOffsets {
            guard let to = from.offset(df: df, dr: dr) else { continue }
            if let target = board.piece(at: to) {
                if target.color != piece.color {
                    moves.append(Move(from: from, to: to, piece: piece, capturedPiece: target))
                }
            } else {
                moves.append(Move(from: from, to: to, piece: piece))
            }
        }
        return moves
    }

    private static func slidingMoves(from: Square, piece: Piece, directions: [(Int, Int)], board: Board) -> [Move] {
        var moves: [Move] = []
        for (df, dr) in directions {
            var sq = from.offset(df: df, dr: dr)
            while let s = sq, s.isValid {
                if let target = board.piece(at: s) {
                    if target.color != piece.color {
                        moves.append(Move(from: from, to: s, piece: piece, capturedPiece: target))
                    }
                    break
                }
                moves.append(Move(from: from, to: s, piece: piece))
                sq = s.offset(df: df, dr: dr)
            }
        }
        return moves
    }

    private static func kingMoves(from: Square, piece: Piece, board: Board) -> [Move] {
        var moves: [Move] = []
        let allDirs = diagonals + straights
        for (df, dr) in allDirs {
            guard let to = from.offset(df: df, dr: dr) else { continue }
            if let target = board.piece(at: to) {
                if target.color != piece.color {
                    moves.append(Move(from: from, to: to, piece: piece, capturedPiece: target))
                }
            } else {
                moves.append(Move(from: from, to: to, piece: piece))
            }
        }

        let rank = piece.color == .white ? 0 : 7
        guard from == Square(file: 4, rank: rank) else { return moves }
        guard !board.isInCheck(color: piece.color) else { return moves }

        let canKingside = piece.color == .white ? board.castlingRights.whiteKingside : board.castlingRights.blackKingside
        if canKingside {
            let f5 = Square(file: 5, rank: rank)
            let g = Square(file: 6, rank: rank)
            if board.isEmpty(at: f5) && board.isEmpty(at: g) &&
               !board.isSquareAttacked(f5, by: piece.color.opposite) &&
               !board.isSquareAttacked(g, by: piece.color.opposite) {
                moves.append(Move(from: from, to: g, piece: piece, isCastling: true))
            }
        }

        let canQueenside = piece.color == .white ? board.castlingRights.whiteQueenside : board.castlingRights.blackQueenside
        if canQueenside {
            let d = Square(file: 3, rank: rank)
            let c = Square(file: 2, rank: rank)
            let b = Square(file: 1, rank: rank)
            if board.isEmpty(at: d) && board.isEmpty(at: c) && board.isEmpty(at: b) &&
               !board.isSquareAttacked(d, by: piece.color.opposite) &&
               !board.isSquareAttacked(c, by: piece.color.opposite) {
                moves.append(Move(from: from, to: c, piece: piece, isCastling: true))
            }
        }

        return moves
    }

    static func attackSquares(for piece: Piece, at square: Square, on board: Board) -> [Square] {
        var attacked: [Square] = []

        switch piece.type {
        case .pawn:
            let dir = piece.color == .white ? 1 : -1
            for df in [-1, 1] {
                if let sq = square.offset(df: df, dr: dir) {
                    attacked.append(sq)
                }
            }
        case .knight:
            for (df, dr) in knightOffsets {
                if let sq = square.offset(df: df, dr: dr) {
                    attacked.append(sq)
                }
            }
        case .bishop:
            for (df, dr) in diagonals {
                var sq = square.offset(df: df, dr: dr)
                while let s = sq, s.isValid {
                    attacked.append(s)
                    if board.piece(at: s) != nil { break }
                    sq = s.offset(df: df, dr: dr)
                }
            }
        case .rook:
            for (df, dr) in straights {
                var sq = square.offset(df: df, dr: dr)
                while let s = sq, s.isValid {
                    attacked.append(s)
                    if board.piece(at: s) != nil { break }
                    sq = s.offset(df: df, dr: dr)
                }
            }
        case .queen:
            for (df, dr) in diagonals + straights {
                var sq = square.offset(df: df, dr: dr)
                while let s = sq, s.isValid {
                    attacked.append(s)
                    if board.piece(at: s) != nil { break }
                    sq = s.offset(df: df, dr: dr)
                }
            }
        case .king:
            for (df, dr) in diagonals + straights {
                if let sq = square.offset(df: df, dr: dr) {
                    attacked.append(sq)
                }
            }
        }

        return attacked
    }
}
