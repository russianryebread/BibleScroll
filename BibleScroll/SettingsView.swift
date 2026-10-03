import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: FeedStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Reading history") {
                    if store.history.isEmpty {
                        Text("Your viewed passages will appear here.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(store.history.suffix(15).reversed()) { entry in
                            Button {
                                store.jump(to: entry)
                                dismiss()
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
                        if store.history.count > 15 {
                            NavigationLink {
                                ReadingHistoryView { dismiss() }
                            } label: {
                                Label("See all history (\(store.history.count))", systemImage: "clock.arrow.circlepath")
                            }
                        }
                    }
                }

                Section {
                    Text("King James Version · 66 books · \(store.verseCount.formatted()) verses available offline")
                } header: {
                    Text("Scripture")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
