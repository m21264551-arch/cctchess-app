import Foundation

enum PieceColor: String, Codable, CaseIterable, Sendable {
    case white, black

    var opposite: PieceColor {
        self == .white ? .black : .white
    }
}

enum PieceType: String, Codable, CaseIterable, Sendable {
    case king, queen, rook, bishop, knight, pawn

    var value: Int {
        switch self {
        case .pawn: return 1
        case .knight: return 3
        case .bishop: return 3
        case .rook: return 5
        case .queen: return 9
        case .king: return 0
        }
    }
}

struct Piece: Equatable, Hashable, Codable, Sendable {
    let type: PieceType
    let color: PieceColor

    var fenCharacter: Character {
        let base: Character = switch type {
        case .king: "k"
        case .queen: "q"
        case .rook: "r"
        case .bishop: "b"
        case .knight: "n"
        case .pawn: "p"
        }
        return color == .white ? Character(base.uppercased()) : base
    }

    var unicodeCharacter: String {
        switch type {
        case .king: return "\u{265A}\u{FE0E}"
        case .queen: return "\u{265B}\u{FE0E}"
        case .rook: return "\u{265C}\u{FE0E}"
        case .bishop: return "\u{265D}\u{FE0E}"
        case .knight: return "\u{265E}\u{FE0E}"
        case .pawn: return "\u{265F}\u{FE0E}"
        }
    }

    init(type: PieceType, color: PieceColor) {
        self.type = type
        self.color = color
    }

    init?(fen: Character) {
        let isWhite = fen.isUppercase
        self.color = isWhite ? .white : .black
        switch fen.lowercased() {
        case "k": self.type = .king
        case "q": self.type = .queen
        case "r": self.type = .rook
        case "b": self.type = .bishop
        case "n": self.type = .knight
        case "p": self.type = .pawn
        default: return nil
        }
    }
}

enum PieceStyle: String, CaseIterable, Identifiable, Codable, Sendable {
    case chessnut = "Chessnut"
    case rhosgfx = "RhosGFX"
    case fantasy = "Fantasy"
    case spatial = "Spatial"
    case celtic = "Celtic"
    case kiwenSuwi = "Kiwen Suwi"
    case firi = "Firi"
    case sashite = "Sashite"

    var id: String { rawValue }
}

struct Square: Equatable, Hashable, Codable, Sendable, Comparable {
    let file: Int
    let rank: Int

    var isValid: Bool { file >= 0 && file < 8 && rank >= 0 && rank < 8 }

    var algebraic: String {
        "\(fileLabel)\(rank + 1)"
    }

    var fileLabel: String {
        String(UnicodeScalar(97 + file)!)
    }

    init(file: Int, rank: Int) {
        self.file = file
        self.rank = rank
    }

    init?(algebraic: String) {
        guard algebraic.count == 2 else { return nil }
        let chars = Array(algebraic)
        guard let fileVal = chars[0].asciiValue.map({ Int($0) - 97 }),
              let rankVal = chars[1].wholeNumberValue.map({ $0 - 1 }) else { return nil }
        guard fileVal >= 0, fileVal < 8, rankVal >= 0, rankVal < 8 else { return nil }
        self.file = fileVal
        self.rank = rankVal
    }

    func offset(df: Int, dr: Int) -> Square? {
        let newSquare = Square(file: file + df, rank: rank + dr)
        return newSquare.isValid ? newSquare : nil
    }

    static func < (lhs: Square, rhs: Square) -> Bool {
        if lhs.rank != rhs.rank { return lhs.rank < rhs.rank }
        return lhs.file < rhs.file
    }
}

struct CastlingRights: Equatable, Codable, Sendable {
    var whiteKingside: Bool
    var whiteQueenside: Bool
    var blackKingside: Bool
    var blackQueenside: Bool

    static let all = CastlingRights(whiteKingside: true, whiteQueenside: true, blackKingside: true, blackQueenside: true)
    static let none = CastlingRights(whiteKingside: false, whiteQueenside: false, blackKingside: false, blackQueenside: false)
}
