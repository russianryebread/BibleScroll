import SwiftUI
import UIKit

struct FeedView: View {
    @EnvironmentObject private var store: FeedStore
    @State private var showingSettings = false
    @State private var selectedChapter: Chapter?
    @State private var pageDirection: PageDirection = .up

    private enum PageDirection { case up, down }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let entry = store.currentEntry,
                   let passage = store.currentPassage {
                    readingPage(entry: entry, passage: passage, size: geometry.size)
                        .id(entry.id)
                        .transition(pageTransition)
                } else {
                    welcomePage
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
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

    private func readingPage(entry: HistoryEntry, passage: Passage, size: CGSize) -> some View {
        let photo = store.photo(for: entry.photoURL)
        let availableWidth = min(size.width - 54, 520)
        let textHeight = measuredHeight(passage.text, width: availableWidth)
        let maxTextHeight = max(160, size.height * 0.53)
        let displayHeight = min(textHeight + 10, maxTextHeight)

        return ZStack {
            PhotoView(url: entry.photoURL, active: true)
                .id(entry.id)
                .contentShape(Rectangle())
                .gesture(backgroundSwipe)

            VStack(spacing: 0) {
                Spacer(minLength: 90)
                VStack(spacing: 21) {
//                    Text("SCRIPTURE FOR THIS MOMENT")
//                        .font(.system(size: 10, weight: .semibold, design: .rounded))
//                        .tracking(2.7)
//                        .foregroundStyle(.white.opacity(0.82))

                    PassageTextView(
                        text: passage.text,
                        onNext: moveNext,
                        onPrevious: movePrevious
                    )
                    .id(entry.id)
                    .frame(width: availableWidth, height: displayHeight)

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

            if let error = store.errorMessage {
                VStack {
                    Spacer()
                    Button {
                        moveNext()
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
        .accessibilityAction(named: "Next passage") { moveNext() }
        .accessibilityAction(named: "Previous passage") { movePrevious() }
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
                if store.hasAccessKey {
                    Button("Load a passage") { Task { await store.loadNext() } }
                        .buttonStyle(.borderedProminent)
                } else {
                    Button("Add Unsplash access key") { showingSettings = true }
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

    private var backgroundSwipe: some Gesture {
        DragGesture(minimumDistance: 35)
            .onEnded { value in
                if value.translation.height < -65 {
                    moveNext()
                } else if value.translation.height > 65 {
                    movePrevious()
                }
            }
    }

    private var pageTransition: AnyTransition {
        if pageDirection == .up {
            return .asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top))
        }
        return .asymmetric(insertion: .move(edge: .top), removal: .move(edge: .bottom))
    }

    private func moveNext() {
        pageDirection = .up
        Task { await store.next() }
    }

    private func movePrevious() {
        pageDirection = .down
        store.previous()
    }

    private func measuredHeight(_ text: String, width: CGFloat) -> CGFloat {
        let font = UIFontMetrics(forTextStyle: .title1).scaledFont(for: UIFont(name: "Georgia", size: 25)!)
        let bounds = (text as NSString).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        return ceil(bounds.height)
    }
}
