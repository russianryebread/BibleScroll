import SwiftUI

@main
struct BibleScrollApp: App {
    @StateObject private var store = FeedStore()

    var body: some Scene {
        WindowGroup {
            FeedView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
                .task { await store.startIfNeeded() }
        }
    }
}
