import SwiftUI

struct CCTPhaseIndicator: View {
    let currentPhase: CCTCategory
    let checksCount: Int
    let capturesCount: Int
    let threatsCount: Int
    let checksFound: Int
    let capturesFound: Int
    let threatsFound: Int
    let checksComplete: Bool
    let capturesComplete: Bool
    let threatsComplete: Bool
    let checksGivenUp: Bool
    let capturesGivenUp: Bool
    let threatsGivenUp: Bool
    let hideCounts: Bool

    var body: some View {
        HStack(spacing: 8) {
            phaseChip(
                phase: .check,
                total: checksCount,
                found: checksFound,
                isCurrent: currentPhase == .check,
                isComplete: checksComplete,
                isGivenUp: checksGivenUp
            )
            phaseChip(
                phase: .capture,
                total: capturesCount,
                found: capturesFound,
                isCurrent: currentPhase == .capture,
                isComplete: capturesComplete,
                isGivenUp: capturesGivenUp
            )
            phaseChip(
                phase: .threat,
                total: threatsCount,
                found: threatsFound,
                isCurrent: currentPhase == .threat,
                isComplete: threatsComplete,
                isGivenUp: threatsGivenUp
            )
        }
        .padding(8)
        .background(AppTheme.surface.opacity(0.78), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(AppTheme.cardStroke, lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private func phaseChip(phase: CCTCategory, total: Int, found: Int, isCurrent: Bool, isComplete: Bool, isGivenUp: Bool) -> some View {
        let statusColor = isGivenUp ? AppTheme.danger : (isComplete ? AppTheme.success : phase.color)

        VStack(spacing: 5) {
            HStack(spacing: 5) {
                Image(systemName: phaseIcon(phase: phase, isComplete: isComplete, isGivenUp: isGivenUp))
                    .font(.caption.weight(.bold))
                Text(phase.rawValue)
                    .font(.caption.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }

            Text(countText(found: found, total: total))
                .font(.caption2.monospacedDigit().weight(.semibold))
                .foregroundStyle(isCurrent || isComplete || isGivenUp ? statusColor : AppTheme.mutedInk)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 58)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(phaseBackground(statusColor: statusColor, isCurrent: isCurrent, isComplete: isComplete, isGivenUp: isGivenUp))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(isCurrent || isComplete || isGivenUp ? statusColor.opacity(0.55) : Color.black.opacity(0.06), lineWidth: 1)
        )
        .foregroundStyle(isCurrent || isComplete || isGivenUp ? statusColor : AppTheme.ink)
        .accessibilityLabel("\(phase.rawValue), \(countText(found: found, total: total))\(isCurrent ? ", current" : "")\(isComplete ? ", complete" : "")\(isGivenUp ? ", missed" : "")")
    }

    private func countText(found: Int, total: Int) -> String {
        hideCounts ? "\(found) found" : "\(found)/\(total)"
    }

    private func phaseIcon(phase: CCTCategory, isComplete: Bool, isGivenUp: Bool) -> String {
        if isGivenUp { return "xmark.circle.fill" }
        if isComplete { return "checkmark.circle.fill" }
        return phase.systemImage
    }

    private func phaseBackground(statusColor: Color, isCurrent: Bool, isComplete: Bool, isGivenUp: Bool) -> Color {
        if isCurrent || isComplete || isGivenUp {
            return statusColor.opacity(isCurrent ? 0.14 : 0.12)
        }
        return Color.white.opacity(0.54)
    }
}
