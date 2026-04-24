import SwiftUI

struct BoardView: View {
    let board: Board
    let theme: BoardTheme
    let flipped: Bool
    let selectedSquare: Square?
    let legalTargets: Set<Square>
    let moveFeedback: MoveFeedback?
    let onSquareTap: (Square) -> Void
    let onMoveAttempt: (Square, Square) -> Void

    @State private var dragSource: Square?
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false

    private func rankForRow(_ rowIndex: Int) -> Int {
        flipped ? rowIndex : 7 - rowIndex
    }

    private func fileForCol(_ colIndex: Int) -> Int {
        flipped ? 7 - colIndex : colIndex
    }

    var body: some View {
        GeometryReader { geometry in
            let boardSize = min(geometry.size.width, geometry.size.height)
            let squareSize = boardSize / 8

            ZStack(alignment: .topLeading) {
                VStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { rowIndex in
                        let rank = rankForRow(rowIndex)
                        HStack(spacing: 0) {
                            ForEach(0..<8, id: \.self) { colIndex in
                                let file = fileForCol(colIndex)
                                let square = Square(file: file, rank: rank)
                                let isLight = (file + rank) % 2 != 0
                                let isFeedbackSource = moveFeedback?.from == square
                                let isFeedbackDestination = moveFeedback?.to == square
                                SquareView(
                                    square: square,
                                    piece: board.piece(at: square),
                                    isLight: isLight,
                                    isSelected: selectedSquare == square,
                                    isLegalTarget: legalTargets.contains(square),
                                    feedbackColor: isFeedbackSource || isFeedbackDestination ? moveFeedback?.color : nil,
                                    isFeedbackDestination: isFeedbackDestination,
                                    rankLabel: colIndex == 0 ? "\(rank + 1)" : nil,
                                    fileLabel: rowIndex == 7 ? square.fileLabel : nil,
                                    size: squareSize,
                                    theme: theme,
                                    isDragSource: dragSource == square && isDragging
                                )
                                .onTapGesture {
                                    if !isDragging {
                                        onSquareTap(square)
                                    }
                                }
                            }
                        }
                    }
                }

                if isDragging, let source = dragSource, let piece = board.piece(at: source) {
                    let col = flipped ? 7 - source.file : source.file
                    let row = flipped ? source.rank : 7 - source.rank
                    let sourceX = CGFloat(col) * squareSize + squareSize / 2
                    let sourceY = CGFloat(row) * squareSize + squareSize / 2
                    PieceView(piece: piece, size: squareSize)
                        .position(x: sourceX + dragOffset.width, y: sourceY + dragOffset.height)
                        .allowsHitTesting(false)
                }
            }
            .frame(width: boardSize, height: boardSize)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(theme.boardBorder.opacity(0.9), lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.16), radius: 18, x: 0, y: 10)
            .animation(.easeOut(duration: 0.18), value: moveFeedback?.id)
            .gesture(
                DragGesture(minimumDistance: 5)
                    .onChanged { value in
                        if !isDragging {
                            let col = Int(value.startLocation.x / squareSize)
                            let row = Int(value.startLocation.y / squareSize)
                            let file = fileForCol(col)
                            let rank = rankForRow(row)
                            let square = Square(file: file, rank: rank)
                            if square.isValid, let piece = board.piece(at: square), piece.color == board.activeColor {
                                dragSource = square
                                isDragging = true
                            }
                        }
                        if isDragging {
                            dragOffset = value.translation
                        }
                    }
                    .onEnded { value in
                        if isDragging, let source = dragSource {
                            let dropX = value.startLocation.x + value.translation.width
                            let dropY = value.startLocation.y + value.translation.height
                            let col = Int(dropX / squareSize)
                            let row = Int(dropY / squareSize)
                            let file = fileForCol(col)
                            let rank = rankForRow(row)
                            let dest = Square(file: file, rank: rank)
                            if dest.isValid && dest != source {
                                onMoveAttempt(source, dest)
                            }
                        }
                        isDragging = false
                        dragSource = nil
                        dragOffset = .zero
                    }
            )
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .layoutPriority(1)
        .accessibilityLabel("Chess board")
    }
}
