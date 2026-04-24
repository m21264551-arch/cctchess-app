import Foundation

struct Board: Equatable, Sendable {
    private(set) var squares: [[Piece?]]
    var activeColor: PieceColor
    var castlingRights: CastlingRights
    var enPassantTarget: Square?
    var halfmoveClock: Int
    var fullmoveNumber: Int

    static let startingFEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

    init() {
        self.squares = Array(repeating: Array(repeating: nil as Piece?, count: 8), count: 8)
        self.activeColor = .white
        self.castlingRights = .none
        self.enPassantTarget = nil
        self.halfmoveClock = 0
        self.fullmoveNumber = 1
    }

    init?(fen: String) {
        let parts = fen.split(separator: " ")
        guard parts.count >= 4 else { return nil }

        var board = Array(repeating: Array(repeating: nil as Piece?, count: 8), count: 8)
        let ranks = parts[0].split(separator: "/")
        guard ranks.count == 8 else { return nil }

        for (rankIndex, rankStr) in ranks.enumerated() {
            let rank = 7 - rankIndex
            var file = 0
            for char in rankStr {
                if let skip = char.wholeNumberValue {
                    file += skip
                } else if let piece = Piece(fen: char) {
                    guard file < 8 else { return nil }
                    board[rank][file] = piece
                    file += 1
                } else {
                    return nil
                }
            }
            guard file == 8 else { return nil }
        }

        self.squares = board
        self.activeColor = String(parts[1]) == "w" ? .white : .black

        let castleStr = String(parts[2])
        self.castlingRights = CastlingRights(
            whiteKingside: castleStr.contains("K"),
            whiteQueenside: castleStr.contains("Q"),
            blackKingside: castleStr.contains("k"),
            blackQueenside: castleStr.contains("q")
        )

        let epStr = String(parts[3])
        self.enPassantTarget = epStr == "-" ? nil : Square(algebraic: epStr)
        self.halfmoveClock = parts.count > 4 ? Int(String(parts[4])) ?? 0 : 0
        self.fullmoveNumber = parts.count > 5 ? Int(String(parts[5])) ?? 1 : 1
    }

    func piece(at square: Square) -> Piece? {
        guard square.isValid else { return nil }
        return squares[square.rank][square.file]
    }

    mutating func place(_ piece: Piece, at square: Square) {
        guard square.isValid else { return }
        squares[square.rank][square.file] = piece
    }

    mutating func removePiece(at square: Square) {
        guard square.isValid else { return }
        squares[square.rank][square.file] = nil
    }

    func isEmpty(at square: Square) -> Bool {
        piece(at: square) == nil
    }

    func kingSquare(for color: PieceColor) -> Square? {
        for rank in 0..<8 {
            for file in 0..<8 {
                let sq = Square(file: file, rank: rank)
                if let p = piece(at: sq), p.type == .king, p.color == color {
                    return sq
                }
            }
        }
        return nil
    }

    func allPieces(of color: PieceColor) -> [(Square, Piece)] {
        var result: [(Square, Piece)] = []
        for rank in 0..<8 {
            for file in 0..<8 {
                let sq = Square(file: file, rank: rank)
                if let p = piece(at: sq), p.color == color {
                    result.append((sq, p))
                }
            }
        }
        return result
    }

    func applying(_ move: Move) -> Board {
        var newBoard = self

        newBoard.removePiece(at: move.from)

        if move.isEnPassant {
            let capturedPawnRank = move.from.rank
            newBoard.removePiece(at: Square(file: move.to.file, rank: capturedPawnRank))
        }

        let placedPiece: Piece
        if let promo = move.promotion {
            placedPiece = Piece(type: promo, color: move.piece.color)
        } else {
            placedPiece = move.piece
        }
        newBoard.place(placedPiece, at: move.to)

        if move.isCastling {
            let isKingside = move.to.file > move.from.file
            let rookFromFile = isKingside ? 7 : 0
            let rookToFile = isKingside ? 5 : 3
            let rookRank = move.from.rank
            if let rook = newBoard.piece(at: Square(file: rookFromFile, rank: rookRank)) {
                newBoard.removePiece(at: Square(file: rookFromFile, rank: rookRank))
                newBoard.place(rook, at: Square(file: rookToFile, rank: rookRank))
            }
        }

        if move.piece.type == .king {
            if move.piece.color == .white {
                newBoard.castlingRights.whiteKingside = false
                newBoard.castlingRights.whiteQueenside = false
            } else {
                newBoard.castlingRights.blackKingside = false
                newBoard.castlingRights.blackQueenside = false
            }
        }
        if move.piece.type == .rook {
            if move.from == Square(file: 0, rank: 0) { newBoard.castlingRights.whiteQueenside = false }
            if move.from == Square(file: 7, rank: 0) { newBoard.castlingRights.whiteKingside = false }
            if move.from == Square(file: 0, rank: 7) { newBoard.castlingRights.blackQueenside = false }
            if move.from == Square(file: 7, rank: 7) { newBoard.castlingRights.blackKingside = false }
        }
        if move.to == Square(file: 0, rank: 0) { newBoard.castlingRights.whiteQueenside = false }
        if move.to == Square(file: 7, rank: 0) { newBoard.castlingRights.whiteKingside = false }
        if move.to == Square(file: 0, rank: 7) { newBoard.castlingRights.blackQueenside = false }
        if move.to == Square(file: 7, rank: 7) { newBoard.castlingRights.blackKingside = false }

        if move.piece.type == .pawn && abs(move.to.rank - move.from.rank) == 2 {
            let epRank = (move.from.rank + move.to.rank) / 2
            newBoard.enPassantTarget = Square(file: move.from.file, rank: epRank)
        } else {
            newBoard.enPassantTarget = nil
        }

        if move.piece.type == .pawn || move.capturedPiece != nil {
            newBoard.halfmoveClock = 0
        } else {
            newBoard.halfmoveClock = halfmoveClock + 1
        }

        if activeColor == .black {
            newBoard.fullmoveNumber = fullmoveNumber + 1
        }
        newBoard.activeColor = activeColor.opposite

        return newBoard
    }

    func isSquareAttacked(_ square: Square, by attackerColor: PieceColor) -> Bool {
        let knightOffsets = [(1,2),(2,1),(2,-1),(1,-2),(-1,-2),(-2,-1),(-2,1),(-1,2)]
        for (df, dr) in knightOffsets {
            if let sq = square.offset(df: df, dr: dr),
               let p = piece(at: sq), p.color == attackerColor, p.type == .knight {
                return true
            }
        }

        let diagonals = [(1,1),(1,-1),(-1,1),(-1,-1)]
        for (df, dr) in diagonals {
            var dist = 1
            var sq = square.offset(df: df, dr: dr)
            while let s = sq, s.isValid {
                if let p = piece(at: s) {
                    if p.color == attackerColor {
                        if p.type == .bishop || p.type == .queen { return true }
                        if p.type == .king && dist == 1 { return true }
                        if p.type == .pawn && dist == 1 {
                            let pawnDir = attackerColor == .white ? -1 : 1
                            if dr == pawnDir { return true }
                        }
                    }
                    break
                }
                dist += 1
                sq = s.offset(df: df, dr: dr)
            }
        }

        let straights = [(0,1),(0,-1),(1,0),(-1,0)]
        for (df, dr) in straights {
            var dist = 1
            var sq = square.offset(df: df, dr: dr)
            while let s = sq, s.isValid {
                if let p = piece(at: s) {
                    if p.color == attackerColor {
                        if p.type == .rook || p.type == .queen { return true }
                        if p.type == .king && dist == 1 { return true }
                    }
                    break
                }
                dist += 1
                sq = s.offset(df: df, dr: dr)
            }
        }

        return false
    }

    func isInCheck(color: PieceColor) -> Bool {
        guard let kingSq = kingSquare(for: color) else { return false }
        return isSquareAttacked(kingSq, by: color.opposite)
    }

    func toFEN() -> String {
        var fen = ""
        for rank in (0..<8).reversed() {
            var empty = 0
            for file in 0..<8 {
                if let p = squares[rank][file] {
                    if empty > 0 {
                        fen += "\(empty)"
                        empty = 0
                    }
                    fen += String(p.fenCharacter)
                } else {
                    empty += 1
                }
            }
            if empty > 0 { fen += "\(empty)" }
            if rank > 0 { fen += "/" }
        }

        fen += " \(activeColor == .white ? "w" : "b")"

        var castleStr = ""
        if castlingRights.whiteKingside { castleStr += "K" }
        if castlingRights.whiteQueenside { castleStr += "Q" }
        if castlingRights.blackKingside { castleStr += "k" }
        if castlingRights.blackQueenside { castleStr += "q" }
        fen += " \(castleStr.isEmpty ? "-" : castleStr)"

        fen += " \(enPassantTarget?.algebraic ?? "-")"
        fen += " \(halfmoveClock) \(fullmoveNumber)"
        return fen
    }
}
