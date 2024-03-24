import SwiftUI
import UIKit

struct PieceView: View {
    @AppStorage("pieceStyle") private var pieceStyleName: String = PieceStyle.chessnut.rawValue

    let piece: Piece
    let size: CGFloat
    let styleOverride: PieceStyle?

    init(piece: Piece, size: CGFloat, styleOverride: PieceStyle? = nil) {
        self.piece = piece
        self.size = size
        self.styleOverride = styleOverride
    }

    private var pieceStyle: PieceStyle {
        styleOverride ?? PieceStyle(rawValue: pieceStyleName) ?? .chessnut
    }

    private var assetName: String {
        "piece_\(pieceStyle.assetID)_\(piece.color.assetCode)\(piece.type.assetCode)"
    }

    var body: some View {
        Group {
            if let image = UIImage(named: assetName) {
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
            } else {
                Text(piece.type.fallbackSymbol(for: piece.color))
                    .font(.system(size: size * 0.82, weight: .regular, design: .serif))
                    .foregroundStyle(piece.color == .white ? .white : .black)
                    .shadow(color: piece.color == .white ? .black.opacity(0.65) : .white.opacity(0.35), radius: 0.8)
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

private extension PieceStyle {
    var assetID: String {
        switch self {
        case .chessnut: return "chessnut"
        case .rhosgfx: return "rhosgfx"
        case .fantasy: return "fantasy"
        case .spatial: return "spatial"
        case .celtic: return "celtic"
        case .kiwenSuwi: return "kiwen_suwi"
        case .firi: return "firi"
        case .sashite: return "sashite"
        }
    }
}

private extension PieceColor {
    var assetCode: String {
        switch self {
        case .white: return "w"
        case .black: return "b"
        }
    }
}

private extension PieceType {
    var assetCode: String {
        switch self {
        case .king: return "K"
        case .queen: return "Q"
        case .rook: return "R"
        case .bishop: return "B"
        case .knight: return "N"
        case .pawn: return "P"
        }
    }

    func fallbackSymbol(for color: PieceColor) -> String {
        switch (self, color) {
        case (.king, .white): return "\u{2654}"
        case (.queen, .white): return "\u{2655}"
        case (.rook, .white): return "\u{2656}"
        case (.bishop, .white): return "\u{2657}"
        case (.knight, .white): return "\u{2658}"
        case (.pawn, .white): return "\u{2659}"
        case (.king, .black): return "\u{265A}"
        case (.queen, .black): return "\u{265B}"
        case (.rook, .black): return "\u{265C}"
        case (.bishop, .black): return "\u{265D}"
        case (.knight, .black): return "\u{265E}"
        case (.pawn, .black): return "\u{265F}"
        }
    }
}
