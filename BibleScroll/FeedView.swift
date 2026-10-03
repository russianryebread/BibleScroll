import SwiftUI
import UIKit

struct FeedView: View {
    @EnvironmentObject private var store: FeedStore
    @State private var showingSettings = false
    @State private var selectedChapter: Chapter?
    @State private var dragOffset: CGFloat = 0
    @State private var isSettling = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if !store.history.isEmpty {
                    ZStack {
                        if store.currentIndex > 0 {
                            page(for: store.history[store.currentIndex - 1], size: geometry.size)
                                .offset(y: -geometry.size.height + dragOffset)
                        }
                        if let entry = store.currentEntry {
                            page(for: entry, size: geometry.size)
                                .offset(y: dragOffset)
                        }
                        if let next = nextEntry {
                            page(for: next, size: geometry.size)
                                .offset(y: geometry.size.height + dragOffset)
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .contentShape(Rectangle())
                    .gesture(pageDrag(height: geometry.size.height))
                    .clipped()
                } else {
                    welcomePage
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.04, green: 0.10, blue: 0.13))
            .overlay(alignment: .topTrailing) {
                Button { showingSettings = true } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(.white.opacity(0.86))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Settings")
                .padding(.trailing, 14)
                .padding(.top, 8)
            }
            .overlay(alignment: .bottom) {
                if store.isLoading {
                    ProgressView()
                        .tint(.white)
                        .padding(.bottom, 60)
                        .accessibilityLabel("Loading next passage")
                }
            }
        }
        .ignoresSafeArea()
        .sheet(isPresented: $showingSettings) { SettingsView() }
        .sheet(item: $selectedChapter) { ChapterView(chapter: $0) }
        .statusBarHidden()
    }

    private var nextEntry: HistoryEntry? {
        if store.currentIndex + 1 < store.history.count {
            return store.history[store.currentIndex + 1]
        }
        return store.previewEntry
    }

    private func pageDrag(height: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                guard !isSettling else { return }
                let translation = value.translation.height
                if translation < 0, nextEntry != nil {
                    dragOffset = max(-height, translation)
                } else if translation > 0, store.currentIndex > 0 {
                    dragOffset = min(height, translation)
                }
            }
            .onEnded { value in
                guard !isSettling else { return }
                let projected = value.predictedEndTranslation.height
                let shouldAdvance = dragOffset < -height * 0.18 || projected < -height * 0.4
                let shouldGoBack = dragOffset > height * 0.18 || projected > height * 0.4
                if shouldAdvance, nextEntry != nil {
                    settle(to: -height, forward: true)
                } else if shouldGoBack, store.currentIndex > 0 {
                    settle(to: height, forward: false)
                } else {
                    withAnimation(.smooth(duration: 0.25)) { dragOffset = 0 }
                }
            }
    }

    private func settle(to destination: CGFloat, forward: Bool) {
        isSettling = true
        withAnimation(.easeOut(duration: 0.25)) { dragOffset = destination }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 250_000_000)
            if forward {
                await store.next()
            } else {
                store.previous()
            }
            var transaction = Transaction(animation: nil)
            transaction.disablesAnimations = true
            withTransaction(transaction) { dragOffset = 0 }
            isSettling = false
        }
    }

    private func page(for entry: HistoryEntry, size: CGSize) -> some View {
        let passage = store.passage(for: entry)
        let photo = store.photo(for: entry.photoURL)
        let availableWidth = min(size.width - 54, 520)
        let textHeight = passage.map { measuredHeight($0.text, width: availableWidth) } ?? 0
        let maxTextHeight = max(160, size.height * 0.53)
        let displayHeight = min(textHeight + 10, maxTextHeight)

        return ZStack {
            PhotoView(url: entry.photoURL, active: store.currentEntry?.id == entry.id)
                .frame(width: size.width, height: size.height)
                .id(entry.id)

            if let passage {
                VStack(spacing: 0) {
                    Spacer(minLength: 90)
                    VStack(spacing: 21) {
                        Text(passage.text)
                            .font(.custom("Georgia", size: 25, relativeTo: .title))
                            .lineSpacing(4)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color(red: 0.99, green: 0.97, blue: 0.92))
                            .minimumScaleFactor(0.65)
                            .lineLimit(30)
                            .frame(width: availableWidth, height: displayHeight)
                            .accessibilityLabel(passage.text)

                        Button {
                            selectedChapter = BibleLibrary.shared.chapter(for: passage.key)
                        } label: {
                            Text(passage.reference.uppercased() + "  ·  KJV")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .tracking(1.8)
                                .foregroundStyle(.white)
                        }
                        .accessibilityHint("Opens the full chapter")
                    }
                    .frame(maxWidth: .infinity)
                    Spacer(minLength: 90)
                }
            }

            VStack {
                Spacer()
                HStack(spacing: 3) {
                    if let photo,
                       let photographerURL = URL(string: photo.photographerURL),
                       let unsplashURL = URL(string: photo.unsplashURL) {
                        Text("Photo by")
                        Link(photo.photographer, destination: photographerURL)
                        Text("on")
                        Link("Unsplash", destination: unsplashURL)
                    }
                }
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.44))
                .padding(.horizontal, 22)
                .padding(.bottom, 36)
            }

            if let error = store.errorMessage, store.currentEntry?.id == entry.id {
                VStack {
                    Spacer()
                    Button {
                        Task { await store.loadNext() }
                    } label: {
                        Label(error, systemImage: "arrow.clockwise")
                            .font(.caption)
                            .padding(12)
                            .background(.black.opacity(0.65), in: Capsule())
                    }
                    .padding(.bottom, 78)
                }
            }
        }
        .frame(width: size.width, height: size.height)
        .clipped()
    }

    private var welcomePage: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.21, green: 0.34, blue: 0.35), Color(red: 0.03, green: 0.08, blue: 0.12)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Spacer()
                Text("Bible Scroll")
                    .font(.system(size: 42, weight: .regular, design: .serif))
                Text("A quiet moment in scripture.")
                    .font(.system(size: 16, design: .serif))
                    .foregroundStyle(.white.opacity(0.8))
                if store.isLoading {
                    ProgressView("Loading a passage…")
                        .tint(.white)
                } else {
                    Button("Load a passage") { Task { await store.loadNext() } }
                        .buttonStyle(.borderedProminent)
                }
                if let error = store.errorMessage {
                    Text(error).font(.caption).foregroundStyle(.white.opacity(0.8))
                }
                Spacer()
            }
            .padding(28)
        }
    }

    private func measuredHeight(_ text: String, width: CGFloat) -> CGFloat {
        let font = UIFontMetrics(forTextStyle: .title1).scaledFont(for: UIFont(name: "Georgia", size: 25)!)
        let bounds = (text as NSString).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        let lineCount = max(1, Int(ceil(bounds.height / font.lineHeight)))
        return ceil(bounds.height + CGFloat(lineCount - 1) * 4)
    }
}
