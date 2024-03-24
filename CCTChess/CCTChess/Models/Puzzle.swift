import Foundation

struct Puzzle: Identifiable, Codable, Sendable {
    let id: String
    let fen: String
    let cctCount: Int

    var title: String {
        "\(cctCount) move\(cctCount == 1 ? "" : "s") to find"
    }
}
