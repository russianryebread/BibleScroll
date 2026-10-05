import Foundation
import SwiftUI

@MainActor
final class FeedStore: ObservableObject {
    @Published private(set) var history: [HistoryEntry]
    @Published private(set) var currentIndex: Int
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var previewEntry: HistoryEntry?

    private var state: SavedState
    private let bible = BibleLibrary.shared
    private let unsplash = UnsplashClient()
    private let accessKey = AppConfiguration.unsplashAccessKey.trimmingCharacters(in: .whitespacesAndNewlines)
    private var remoteRemaining: Int?
    private var hasStarted = false
    private var navigationVersion = 0
    private var preparedNext: Task<HistoryEntry?, Never>?

    init() {
        #if DEBUG
        let loaded: SavedState
        if ProcessInfo.processInfo.arguments.contains("-UITestLongHistory") {
            loaded = SavedState(
                history: (0..<17).map { index in
                    HistoryEntry(
                        passageKey: index.isMultiple(of: 2) ? "PSA 23:1-2" : "JHN 1:4-5",
                        photoURL: "https://invalid.example/\(index).jpg"
                    )
                },
                currentIndex: 16
            )
        } else if ProcessInfo.processInfo.arguments.contains("-UITestHistory") {
            loaded = SavedState(
                history: [
                    HistoryEntry(passageKey: "PSA 23:1-2", photoURL: "https://invalid.example/one.jpg"),
                    HistoryEntry(passageKey: "JHN 1:4-5", photoURL: "https://invalid.example/two.jpg")
                ],
                currentIndex: 1
            )
        } else {
            loaded = StateFile.load()
        }
        #else
        let loaded = StateFile.load()
        #endif
        state = loaded
        history = loaded.history
        currentIndex = min(max(loaded.currentIndex, 0), max(loaded.history.count - 1, 0))
    }

    var currentEntry: HistoryEntry? {
        history.indices.contains(currentIndex) ? history[currentIndex] : nil
    }

    var currentPassage: Passage? {
        currentEntry.flatMap { bible.passage(for: $0.passageKey) }
    }

    private var hasAccessKey: Bool { !accessKey.isEmpty }
    var verseCount: Int { bible.verseCount }

    func photo(for url: String) -> PhotoRecord? {
        state.photos.first { $0.url == url }
    }

    func passage(for entry: HistoryEntry) -> Passage? {
        bible.passage(for: entry.passageKey)
    }

    func startIfNeeded() async {
        guard !hasStarted else { return }
        hasStarted = true
        if history.isEmpty {
            await loadNext()
        } else if !history.isEmpty && currentIndex >= history.count - 2 {
            prepareNext()
        }
    }

    func previous() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        persist()
    }

    func next() async {
        if currentIndex + 1 < history.count {
            currentIndex += 1
            persist()
            if currentIndex >= history.count - 2 { prepareNext() }
            return
        }
        await loadNext()
    }

    func jump(to entry: HistoryEntry) {
        guard let index = history.firstIndex(where: { $0.id == entry.id }) else { return }
        currentIndex = index
        persist()
        if currentIndex >= history.count - 2 { prepareNext() }
    }

    @discardableResult
    func openVerse(from url: URL) -> Bool {
        guard url.scheme == "biblescroll", url.host == "verse",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let reference = components.queryItems?.first(where: { $0.name == "reference" })?.value,
              let key = bible.passageKey(for: reference) else { return false }
        navigationVersion += 1
        errorMessage = nil
        if let entry = history.last(where: { $0.passageKey == key }) {
            jump(to: entry)
        } else {
            // Show scripture immediately, even offline or before any photos have loaded.
            let photoURL = currentEntry?.photoURL ?? state.photos.first?.url ?? ""
            history.append(HistoryEntry(passageKey: key, photoURL: photoURL))
            currentIndex = history.count - 1
            persist()
            prepareNext()
        }
        return true
    }

    func loadNext() async {
        guard !isLoading else { return }
        let version = navigationVersion
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let entry: HistoryEntry
            if let pending = preparedNext, let result = await pending.value {
                entry = result
            } else {
                let recent = Set(history.suffix(80).map(\.passageKey))
                guard let key = bible.randomKey(excluding: recent) else {
                    errorMessage = "The bundled KJV could not be read."
                    return
                }
                let photo = try await nextPhoto()
                entry = HistoryEntry(passageKey: key, photoURL: photo.url)
            }
            preparedNext = nil
            previewEntry = nil
            state.history.append(entry)
            state.currentIndex = version == navigationVersion ? state.history.count - 1 : currentIndex
            errorMessage = nil
            history = state.history
            currentIndex = state.currentIndex
            StateFile.save(state)
            prepareNext()
        } catch {
            guard version == navigationVersion else { return }
            preparedNext = nil
            previewEntry = nil
            errorMessage = error.localizedDescription
        }
    }

    private func prepareNext() {
        guard preparedNext == nil, hasAccessKey || !state.photos.isEmpty else { return }
        preparedNext = Task { [weak self] in
            guard let self else { return nil }
            let recent = Set(self.history.suffix(80).map(\.passageKey))
            guard let key = self.bible.randomKey(excluding: recent) else {
                self.preparedNext = nil
                self.errorMessage = "The bundled KJV could not be read."
                return nil
            }
            do {
                let photo = try await self.nextPhoto()
                let entry = HistoryEntry(passageKey: key, photoURL: photo.url)
                self.previewEntry = entry
                Task { await PhotoImageCache.shared.load(photo.url) }
                return entry
            } catch {
                self.preparedNext = nil
                self.errorMessage = error.localizedDescription
                return nil
            }
        }
    }

    private func nextPhoto() async throws -> PhotoRecord {
        let now = Date()
        state.requestTimes.removeAll { now.timeIntervalSince($0) >= 3600 }
        let shouldRecycle = state.requestTimes.count >= 40 || (remoteRemaining.map { $0 <= 10 } ?? false)
        if !shouldRecycle && hasAccessKey {
            // Count attempts, including failed ones, so retries cannot exceed our hourly budget.
            state.requestTimes.append(now)
            StateFile.save(state)
            do {
                let (photo, remaining) = try await unsplash.randomPortrait(accessKey: accessKey)
                remoteRemaining = remaining
                if !state.photos.contains(where: { $0.url == photo.url }) { state.photos.append(photo) }
                return photo
            } catch {
                if let recycled = recycledPhoto() { return recycled }
                throw error
            }
        }
        if let recycled = recycledPhoto() { return recycled }
        if !hasAccessKey { throw PhotoError.missingKey }
        throw PhotoError.rateLimited
    }

    private func recycledPhoto() -> PhotoRecord? {
        let recentURLs = Set(history.suffix(3).map(\.photoURL))
        let choices = state.photos.filter { !recentURLs.contains($0.url) }
        return (choices.isEmpty ? state.photos : choices).randomElement()
    }

    private func persist() {
        state.history = history
        state.currentIndex = currentIndex
        StateFile.save(state)
    }
}
