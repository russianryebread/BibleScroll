import SwiftUI

struct ReadingHistoryView: View {
    @EnvironmentObject private var store: FeedStore
    let onSelect: () -> Void

    var body: some View {
        List {
            ForEach(store.history.reversed()) { entry in
                Button {
                    store.jump(to: entry)
                    onSelect()
                } label: {
                    HStack(spacing: 13) {
                        AsyncImage(url: URL(string: entry.photoURL)) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Color.gray.opacity(0.25)
                        }
                        .frame(width: 45, height: 55)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        Text(store.passage(for: entry)?.reference ?? entry.passageKey)
                            .font(.system(size: 17, design: .serif))
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Reading history")
    }
}
