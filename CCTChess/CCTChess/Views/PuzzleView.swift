import SwiftUI
import SwiftData

struct PuzzleView: View {
    @AppStorage("boardTheme") private var themeName: String = BoardTheme.classic.rawValue
    @AppStorage("hideCounts") private var hideCounts: Bool = false
    @Environment(\.modelContext) private var modelContext
    @Query private var ratings: [CCTRating]
    @State private var viewModel: PuzzleViewModel
    @State private var showResults = false
    @State private var boardFlipped: Bool
    @State private var ratingChange: Double = 0

    private var theme: BoardTheme {
        BoardTheme(rawValue: themeName) ?? .classic
    }

    private var rating: CCTRating {
        if let existing = ratings.first { return existing }
        let newRating = CCTRating()
        modelContext.insert(newRating)
        return newRating
    }

    init(puzzle: Puzzle) {
        let vm = PuzzleViewModel(puzzle: puzzle)
        self._viewModel = State(initialValue: vm)
        self._boardFlipped = State(initialValue: vm.board.activeColor == .black)
    }

    private func loadNextPuzzle() {
        showResults = false
        ratingChange = 0
        let next = PuzzleStore.randomPuzzle(targetCCTRange: rating.targetCCTRange)
        let vm = PuzzleViewModel(puzzle: next)
        viewModel = vm
        boardFlipped = vm.board.activeColor == .black
    }

    var body: some View {
        ZStack(alignment: .top) {
            if showResults {
                resultsContent
            } else {
                puzzleContent
            }

            if viewModel.showingPhaseComplete {
                phaseCompleteBanner
                    .padding(.top, 12)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(2)
            }
        }
        .appScreenBackground()
        .animation(.easeInOut(duration: 0.25), value: showResults)
        .navigationBarTitleDisplayMode(.inline)
        .tint(AppTheme.accent)
        .task(id: viewModel.puzzle.id) {
            viewModel.prepareCurrentPhase()
        }
        .onChange(of: viewModel.allPhasesComplete) { _, complete in
            if complete {
                let ratingBefore = rating.rating
                let attempt = viewModel.buildAttempt()
                attempt.ratingBefore = ratingBefore
                rating.update(accuracy: attempt.overallAccuracy, puzzleDifficulty: viewModel.puzzle.cctCount)
                attempt.ratingAfter = rating.rating
                ratingChange = attempt.ratingChange
                modelContext.insert(attempt)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showResults = true
                }
            }
        }
    }

    // MARK: - Puzzle Content

    private var puzzleContent: some View {
        GeometryReader { geometry in
            let boardSize = max(0, min(geometry.size.width - 32, geometry.size.height * 0.52))

            VStack(spacing: 12) {
                puzzleHeader

                CCTPhaseIndicator(
                    currentPhase: viewModel.currentPhase,
                    checksCount: viewModel.analysis.checks.count,
                    capturesCount: viewModel.analysis.captures.count,
                    threatsCount: viewModel.analysis.threats.count,
                    checksFound: viewModel.foundChecks.count,
                    capturesFound: viewModel.foundCaptures.count,
                    threatsFound: viewModel.foundThreats.count,
                    checksComplete: viewModel.checksComplete,
                    capturesComplete: viewModel.capturesComplete,
                    threatsComplete: viewModel.threatsComplete,
                    checksGivenUp: viewModel.checksGivenUp,
                    capturesGivenUp: viewModel.capturesGivenUp,
                    threatsGivenUp: viewModel.threatsGivenUp,
                    hideCounts: hideCounts
                )

                boardSection(size: boardSize)

                foundMovesPanel

                phaseActionPanel

                Spacer(minLength: 0)
            }
            .padding(.top, 10)
            .padding(.bottom, 16)
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
        }
    }

    private func boardSection(size: CGFloat) -> some View {
        ZStack(alignment: .bottom) {
            BoardView(
                board: viewModel.board,
                theme: theme,
                flipped: boardFlipped,
                selectedSquare: viewModel.selectedSquare,
                legalTargets: viewModel.legalTargets,
                moveFeedback: viewModel.moveFeedback,
                onSquareTap: { square in
                    viewModel.selectSquare(square)
                },
                onMoveAttempt: { from, to in
                    viewModel.attemptMove(from: from, to: to)
                }
            )

            if let feedback = viewModel.moveFeedback {
                moveFeedbackPill(feedback)
                    .padding(.bottom, 10)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .frame(width: size, height: size)
        .animation(.easeOut(duration: 0.18), value: viewModel.moveFeedback?.id)
        .padding(.horizontal, 16)
    }

    private var puzzleHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 10) {
                Label("Step \(phaseIndex) of 3", systemImage: viewModel.currentPhase.systemImage)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(viewModel.currentPhase.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(viewModel.currentPhase.color.opacity(0.12), in: Capsule())

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        boardFlipped.toggle()
                    }
                } label: {
                    Label("Flip", systemImage: "arrow.up.arrow.down")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(SecondaryActionButtonStyle())
                .accessibilityLabel("Flip board")
            }

            Text(viewModel.puzzle.title)
                .font(.headline.weight(.bold))
                .foregroundStyle(AppTheme.ink)
                .lineLimit(2)

            HStack(spacing: 12) {
                HStack(spacing: 7) {
                    Circle()
                        .fill(viewModel.board.activeColor == .white ? Color.white : Color.black)
                        .overlay(Circle().strokeBorder(Color.black.opacity(0.22), lineWidth: 1))
                        .frame(width: 18, height: 18)
                    Text("\(activeSideName) to move")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.ink)
                }

                Spacer()

                Label("\(viewModel.analysis.totalMoves) motifs", systemImage: "square.grid.3x3.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.mutedInk)
            }
        }
        .appCard(padding: 14)
        .padding(.horizontal, 16)
    }

    private var phaseIndex: Int {
        switch viewModel.currentPhase {
        case .check: return 1
        case .capture: return 2
        case .threat: return 3
        }
    }

    private var activeSideName: String {
        viewModel.board.activeColor == .white ? "White" : "Black"
    }

    private var phaseActionPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: viewModel.currentPhase.systemImage)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(viewModel.currentPhase.color)
                    .frame(width: 38, height: 38)
                    .background(viewModel.currentPhase.color.opacity(0.12), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text("Find every \(viewModel.currentPhase.singularName.lowercased())")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppTheme.ink)
                    Text(phaseGuidance)
                        .font(.caption)
                        .foregroundStyle(AppTheme.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                if viewModel.currentPhaseHasUnfoundMoves {
                    Button {
                        withAnimation {
                            viewModel.handleGiveUpAction()
                        }
                    } label: {
                        Label(viewModel.giveUpActionTitle, systemImage: viewModel.giveUpActionSystemImage)
                            .font(.caption.weight(.bold))
                            .frame(minHeight: 42)
                            .padding(.horizontal, 14)
                            .background(giveUpActionBackground, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .foregroundStyle(giveUpActionForeground)
                    }
                    .accessibilityHint(viewModel.showingGiveUpConfirmation ? "Records the remaining moves as missed and moves on" : "Shows a confirmation before recording missed moves")
                }
            }

            ProgressView(value: currentPhaseProgress)
                .tint(viewModel.currentPhase.color)
                .accessibilityLabel("Current category progress")
                .accessibilityValue(viewModel.progressText(hideCounts: hideCounts))
        }
        .appCard(padding: 14)
        .padding(.horizontal, 16)
    }

    private var currentPhaseProgress: Double {
        let total = viewModel.currentPhaseExpectedMoves.count
        guard total > 0 else { return 1 }
        return Double(viewModel.currentPhaseFoundKeys.count) / Double(total)
    }

    private var phaseGuidance: String {
        if viewModel.showingGiveUpConfirmation {
            return "Recording misses will move on and count the remaining \(viewModel.currentPhase.rawValue.lowercased()) as missed."
        }
        if viewModel.selectedSquare != nil {
            return "Choose a highlighted destination or tap again to clear selection."
        }
        return hideCounts ? "\(viewModel.currentPhaseFoundKeys.count) found. Tap or drag a legal move." : "\(viewModel.progressText(hideCounts: hideCounts)) found. Only this category counts right now."
    }

    // MARK: - Results Content

    private var resultsContent: some View {
        ResultsView(viewModel: viewModel, ratingChange: ratingChange, onNewPuzzle: loadNextPuzzle)
    }

    @ViewBuilder
    private var foundMovesPanel: some View {
        let foundChecks = viewModel.foundMoves(for: .check)
        let foundCaptures = viewModel.foundMoves(for: .capture)
        let foundThreats = viewModel.foundMoves(for: .threat)
        if !foundChecks.isEmpty || !foundCaptures.isEmpty || !foundThreats.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(AppTheme.success)
                    Text("Found so far")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.mutedInk)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        foundMoveChips(category: .check, moves: foundChecks)
                        foundMoveChips(category: .capture, moves: foundCaptures)
                        foundMoveChips(category: .threat, moves: foundThreats)
                    }
                    .padding(.vertical, 1)
                }
            }
            .appCard(padding: 12)
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private func foundMoveChips(category: CCTCategory, moves: [Move]) -> some View {
        ForEach(moves, id: \.key) { move in
            HStack(spacing: 5) {
                Image(systemName: category.systemImage)
                    .font(.caption2)
                Text("\(category.singularName) \(move.notation)")
                    .font(.caption.bold())
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(category.color.opacity(0.14), in: Capsule())
            .foregroundStyle(category.color)
            .overlay(
                Capsule()
                    .strokeBorder(category.color.opacity(0.35), lineWidth: 1)
            )
            .accessibilityLabel("\(category.singularName) \(move.notation)")
        }
    }

    private var giveUpActionBackground: Color {
        viewModel.showingGiveUpConfirmation ? AppTheme.warning : Color.white.opacity(0.7)
    }

    private var giveUpActionForeground: Color {
        viewModel.showingGiveUpConfirmation ? .white : AppTheme.mutedInk
    }

    private func moveFeedbackPill(_ feedback: MoveFeedback) -> some View {
        Label {
            Text(feedback.title)
                .font(.caption.bold())
            Text(feedback.notation)
                .font(.caption2.monospaced())
                .foregroundStyle(.secondary)
        } icon: {
            Image(systemName: feedback.systemImage)
                .foregroundStyle(feedback.color)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.regularMaterial, in: Capsule())
        .overlay(
            Capsule()
                .strokeBorder(feedback.color.opacity(0.55), lineWidth: 1)
        )
        .shadow(color: AppTheme.shadow, radius: 10, x: 0, y: 5)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Phase Complete Banner

    private var phaseCompleteBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundStyle(AppTheme.success)

            VStack(alignment: .leading, spacing: 3) {
                Text("Nice scan")
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)
                Text("All \(viewModel.completedPhaseName.lowercased()) found. \(phaseCompleteNextText)")
                    .font(.caption)
                    .foregroundStyle(AppTheme.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .appCard(padding: 14)
        .padding(.horizontal, 28)
    }

    private var phaseCompleteNextText: String {
        if viewModel.currentPhase != .threat || !viewModel.threatsComplete {
            return "Moving to \(nextPhaseName.lowercased())."
        }
        return "Opening results."
    }

    private var nextPhaseName: String {
        switch viewModel.currentPhase {
        case .check: return CCTCategory.capture.rawValue
        case .capture: return CCTCategory.threat.rawValue
        case .threat: return "Results"
        }
    }
}
