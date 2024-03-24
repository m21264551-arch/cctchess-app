import SwiftUI

struct Move: Equatable, Hashable, Sendable {
    let from: Square
    let to: Square
    let piece: Piece
    let capturedPiece: Piece?
    let promotion: PieceType?
    let isEnPassant: Bool
    let isCastling: Bool

    var key: MoveKey { MoveKey(from: from, to: to, promotion: promotion) }

    init(from: Square, to: Square, piece: Piece, capturedPiece: Piece? = nil,
         promotion: PieceType? = nil, isEnPassant: Bool = false, isCastling: Bool = false) {
        self.from = from
        self.to = to
        self.piece = piece
        self.capturedPiece = capturedPiece
        self.promotion = promotion
        self.isEnPassant = isEnPassant
        self.isCastling = isCastling
    }

    var notation: String {
        if isCastling {
            return to.file > from.file ? "O-O" : "O-O-O"
        }
        var result = ""
        if piece.type != .pawn {
            result += String(piece.fenCharacter).uppercased()
        }
        if capturedPiece != nil || isEnPassant {
            if piece.type == .pawn {
                result += String(UnicodeScalar(97 + from.file)!)
            }
            result += "x"
        }
        result += to.algebraic
        if let promo = promotion {
            result += "=\(String(Piece(type: promo, color: piece.color).fenCharacter).uppercased())"
        }
        return result
    }
}

struct MoveKey: Equatable, Hashable, Sendable {
    let from: Square
    let to: Square
    let promotion: PieceType?

    init(from: Square, to: Square, promotion: PieceType? = nil) {
        self.from = from
        self.to = to
        self.promotion = promotion
    }
}

enum CCTCategory: String, CaseIterable, Codable, Sendable {
    case check = "Checks"
    case capture = "Captures"
    case threat = "Threats"

    var systemImage: String {
        switch self {
        case .check: return "exclamationmark.triangle.fill"
        case .capture: return "target"
        case .threat: return "bolt.fill"
        }
    }

    var color: Color {
        switch self {
        case .check: return AppTheme.danger
        case .capture: return AppTheme.warning
        case .threat: return Color(red: 0.64, green: 0.42, blue: 0.02)
        }
    }

    var singularName: String {
        switch self {
        case .check: return "Check"
        case .capture: return "Capture"
        case .threat: return "Threat"
        }
    }
}

struct MoveFeedback: Equatable, Identifiable, Sendable {
    let id = UUID()
    let from: Square
    let to: Square
    let category: CCTCategory?
    let notation: String
    let isNew: Bool

    var color: Color {
        category?.color ?? AppTheme.mutedInk
    }

    var systemImage: String {
        category?.systemImage ?? "arrow.right.circle.fill"
    }

    var title: String {
        guard let category else { return "Legal move" }
        return isNew ? "\(category.singularName) found" : "Already found"
    }
}
