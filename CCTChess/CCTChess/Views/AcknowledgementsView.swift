import SwiftUI

struct AcknowledgementsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Lichess Open Database", systemImage: "archivebox.fill")
                        .font(.headline)
                        .foregroundStyle(AppTheme.ink)

                    Text("Puzzle positions are bundled from Lichess database exports, released under Creative Commons CC0.")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)

                    Link("database.lichess.org", destination: URL(string: "https://database.lichess.org/")!)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.accent)
                }
                .appCard()

                VStack(alignment: .leading, spacing: 10) {
                    Label("Chess Piece Artwork", systemImage: "crown.fill")
                        .font(.headline)
                        .foregroundStyle(AppTheme.ink)

                    Text("Piece styles use freely licensed artwork from Lichess piece sets and Sashite chess assets. The SVG originals were converted to PNG for this app.")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Chessnut by Alexis Luengas: Apache 2.0")
                        Text("RhosGFX: CC0 1.0")
                        Text("Fantasy, Spatial, and Celtic by Maurizio Monge: MIT")
                        Text("Kiwen Suwi by neverRare: CC BY 4.0")
                        Text("Firi by James Faure: CC BY 4.0")
                        Text("Sashite chess assets: CC0 1.0")
                    }
                    .font(.caption)
                    .foregroundStyle(AppTheme.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)

                    Link("Lichess COPYING.md", destination: URL(string: "https://github.com/lichess-org/lila/blob/master/COPYING.md")!)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.accent)

                    Link("Sashite chess assets", destination: URL(string: "https://sashite.dev/assets/chess/")!)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.accent)
                }
                .appCard()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
        }
        .appScreenBackground()
        .navigationTitle("Acknowledgements")
        .navigationBarTitleDisplayMode(.inline)
        .tint(AppTheme.accent)
    }
}
