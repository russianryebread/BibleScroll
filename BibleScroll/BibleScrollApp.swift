import SwiftUI

@main
struct BibleScrollApp: App {
    @StateObject private var store = FeedStore()
    @State private var showingSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                FeedView()
                    .environmentObject(store)
                    .task { await store.startIfNeeded() }

                if showingSplash {
                    SplashView()
                        .zIndex(1)
                }
            }
            .preferredColorScheme(.dark)
            .task {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                showingSplash = false
            }
        }
    }
}
