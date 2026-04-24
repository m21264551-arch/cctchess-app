import Testing
@testable import CCTChess

@Suite("FEN Parser Tests")
struct FENParserTests {

    @Test func parsesStartingPosition() {
        let board = Board(fen: Board.startingFEN)
        #expect(board != nil)
        let b = board!

        #expect(b.activeColor == .white)
        #expect(b.castlingRights == .all)
        #expect(b.enPassantTarget == nil)
        #expect(b.halfmoveClock == 0)
        #expect(b.fullmoveNumber == 1)

        #expect(b.piece(at: Square(file: 0, rank: 0)) == Piece(type: .rook, color: .white))
        #expect(b.piece(at: Square(file: 4, rank: 0)) == Piece(type: .king, color: .white))
        #expect(b.piece(at: Square(file: 4, rank: 7)) == Piece(type: .king, color: .black))
        #expect(b.piece(at: Square(file: 0, rank: 1)) == Piece(type: .pawn, color: .white))
        #expect(b.piece(at: Square(file: 0, rank: 6)) == Piece(type: .pawn, color: .black))
        #expect(b.isEmpty(at: Square(file: 4, rank: 4)))
    }

    @Test func roundTripFEN() {
        let fen = Board.startingFEN
        let board = Board(fen: fen)!
        #expect(board.toFEN() == fen)
    }

    @Test func parsesEnPassant() {
        let fen = "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1"
        let board = Board(fen: fen)!
        #expect(board.activeColor == .black)
        #expect(board.enPassantTarget == Square(algebraic: "e3"))
    }

    @Test func parsesMidgamePosition() {
        let fen = "r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 4 4"
        let board = Board(fen: fen)
        #expect(board != nil)
        let b = board!
        #expect(b.piece(at: Square(algebraic: "h5")!) == Piece(type: .queen, color: .white))
        #expect(b.piece(at: Square(algebraic: "c4")!) == Piece(type: .bishop, color: .white))
        #expect(b.piece(at: Square(algebraic: "c6")!) == Piece(type: .knight, color: .black))
    }

    @Test func squareAlgebraicConversion() {
        let sq = Square(algebraic: "e4")
        #expect(sq != nil)
        #expect(sq!.file == 4)
        #expect(sq!.rank == 3)
        #expect(sq!.algebraic == "e4")

        let a1 = Square(file: 0, rank: 0)
        #expect(a1.algebraic == "a1")
        let h8 = Square(file: 7, rank: 7)
        #expect(h8.algebraic == "h8")
    }

    @Test func rejectsInvalidFEN() {
        #expect(Board(fen: "invalid") == nil)
        #expect(Board(fen: "") == nil)
        #expect(Board(fen: "8/8/8/8/8/8/8/8") == nil)
    }
}
