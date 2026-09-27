import Foundation

struct HistoryEntry: Codable, Identifiable, Equatable {
    let id: UUID
    let passageKey: String
    let photoURL: String

    init(passageKey: String, photoURL: String) {
        self.id = UUID()
        self.passageKey = passageKey
        self.photoURL = photoURL
    }
}

struct PhotoRecord: Codable, Equatable {
    let url: String
    let photographer: String
    let photographerURL: String
    let unsplashURL: String
}

struct SavedState: Codable {
    var history: [HistoryEntry] = []
    var currentIndex: Int = 0
    var photos: [PhotoRecord] = []
    var requestTimes: [Date] = []
}

enum StateFile {
    private static var url: URL {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent("BibleScroll", isDirectory: true)
            .appendingPathComponent("feed.json")
    }

    static func load() -> SavedState {
        guard let data = try? Data(contentsOf: url),
              let state = try? JSONDecoder().decode(SavedState.self, from: data) else {
            return SavedState()
        }
        return state
    }

    static func save(_ state: SavedState) {
        let directory = url.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        guard let data = try? JSONEncoder().encode(state) else { return }
        try? data.write(to: url, options: .atomic)
    }
}
