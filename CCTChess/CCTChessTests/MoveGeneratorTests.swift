import Testing
@testable import CCTChess

@Suite("Move Generator Tests")
struct MoveGeneratorTests {

    @Test func startingPositionHas20Moves() {
        let board = Board(fen: Board.startingFEN)!
        let moves = MoveGenerator.legalMoves(for: board)
        #expect(moves.count == 20)
    }

    @Test func startingPositionHasNoCapturesOrChecks() {
        let board = Board(fen: Board.startingFEN)!
        let moves = MoveGenerator.legalMoves(for: board)
        let captures = moves.filter { $0.capturedPiece != nil }
        #expect(captures.isEmpty)

        for move in moves {
            let newBoard = board.applying(move)
            #expect(!newBoard.isInCheck(color: .black))
        }
    }

    @Test func scholarsMateHasCheckmate() {
        let fen = "r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 4 4"
        let board = Board(fen: fen)!
        let moves = MoveGenerator.legalMoves(for: board)

        let qxf7 = moves.first { $0.from == Square(algebraic: "h5")! && $0.to == Square(algebraic: "f7")! }
        #expect(qxf7 != nil)
        #expect(qxf7!.capturedPiece != nil)

        let afterQxf7 = board.applying(qxf7!)
        #expect(afterQxf7.isInCheck(color: .black))

        let blackMoves = MoveGenerator.legalMoves(for: afterQxf7)
        #expect(blackMoves.isEmpty)
    }

    @Test func enPassantCaptureWorks() {
        let fen = "rnbqkbnr/ppp1pppp/8/3pP3/8/8/PPPP1PPP/RNBQKBNR w KQkq d6 0 3"
        let board = Board(fen: fen)!
        let moves = MoveGenerator.legalMoves(for: board)

        let ep = moves.first { $0.isEnPassant }
        #expect(ep != nil)
        #expect(ep!.from == Square(algebraic: "e5")!)
        #expect(ep!.to == Square(algebraic: "d6")!)
    }

    @Test func castlingWorks() {
        let fen = "r3k2r/pppppppp/8/8/8/8/PPPPPPPP/R3K2R w KQkq - 0 1"
        let board = Board(fen: fen)!
        let moves = MoveGenerator.legalMoves(for: board)

        let kingside = moves.first { $0.isCastling && $0.to.file == 6 }
        let queenside = moves.first { $0.isCastling && $0.to.file == 2 }
        #expect(kingside != nil)
        #expect(queenside != nil)
    }

    @Test func pinnedPieceCannotMove() {
        // Bishop on a4 pins pawn on d1-a4 diagonal through c2 to king on e1
        // Actually: rook on e8 pins pawn on e2 to king on e1 (file pin)
        // Pawn e2 can still push forward along the pin line.
        // Better: bishop on a3 pins pawn on c1... no.
        // Use: bishop on h5, pawn on f3, king on e2 - bishop pins pawn diagonally
        // h5(7,4) -> g4(6,3) -> f3(5,2) -> e2(4,1) - yes, this pins f3 pawn to e2 king
        let fen = "4k3/8/8/7b/8/5P2/4K3/8 w - - 0 1"
        let board = Board(fen: fen)!
        let moves = MoveGenerator.legalMoves(for: board)

        let pawnMoves = moves.filter { $0.piece.type == .pawn }
        #expect(pawnMoves.isEmpty)
    }

    @Test func promotionGeneratesFourOptions() {
        let fen = "8/4P3/8/8/8/8/8/4K2k w - - 0 1"
        let board = Board(fen: fen)!
        let moves = MoveGenerator.legalMoves(for: board)

        let promos = moves.filter { $0.promotion != nil }
        #expect(promos.count == 4)
        let promoTypes = Set(promos.compactMap(\.promotion))
        #expect(promoTypes == Set([.queen, .rook, .bishop, .knight]))
    }
}
