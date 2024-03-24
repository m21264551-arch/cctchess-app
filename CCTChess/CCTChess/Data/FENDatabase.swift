import Foundation
import Compression

final class FENDatabase: @unchecked Sendable {
    static let shared = FENDatabase()

    private let data: Data
    private let lineOffsets: [Int]

    var count: Int { lineOffsets.count }
    var isEmpty: Bool { lineOffsets.isEmpty }

    private init() {
        guard let url = Bundle.main.url(forResource: "lichess_fens", withExtension: "lzfse"),
              let compressed = try? Data(contentsOf: url),
              let decompressed = try? (compressed as NSData).decompressed(using: .lzfse) as Data else {
            self.data = Data()
            self.lineOffsets = []
            return
        }

        self.data = decompressed

        var offsets: [Int] = [0]
        offsets.reserveCapacity(1_000_000)
        for i in 0..<decompressed.count {
            if decompressed[i] == UInt8(ascii: "\n") && i + 1 < decompressed.count {
                offsets.append(i + 1)
            }
        }
        self.lineOffsets = offsets
    }

    func randomFEN() -> String? {
        guard !lineOffsets.isEmpty else { return nil }
        let idx = Int.random(in: 0..<lineOffsets.count)
        return fen(at: idx)
    }

    func randomFENs(_ count: Int) -> [String] {
        guard !lineOffsets.isEmpty else { return [] }
        var result: [String] = []
        result.reserveCapacity(count)
        for _ in 0..<count {
            let idx = Int.random(in: 0..<lineOffsets.count)
            if let fen = fen(at: idx) {
                result.append(fen)
            }
        }
        return result
    }

    private func fen(at index: Int) -> String? {
        let start = lineOffsets[index]
        var end = start
        while end < data.count && data[end] != UInt8(ascii: "\n") {
            end += 1
        }
        guard end > start else { return nil }
        return String(decoding: data[start..<end], as: UTF8.self)
    }
}
