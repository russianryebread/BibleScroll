import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: FeedStore
    @Environment(\.dismiss) private var dismiss
    @State private var enteredKey = ""
    @State private var savedKey = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    SecureField("Unsplash access key", text: $enteredKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    Button(savedKey ? "Saved" : "Save access key") {
                        Task {
                            await store.setAccessKey(enteredKey)
                            savedKey = true
                        }
                    }
                    .disabled(enteredKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    Link("Create an Unsplash access key", destination: URL(string: "https://unsplash.com/developers")!)
                } header: {
                    Text("Photos")
                } footer: {
                    Text("The app keeps your access key on this device and requests at most 40 new photos per hour before reusing its photo pool. Use the Access Key, not the Secret Key.")
                }

                Section("Reading history") {
                    if store.history.isEmpty {
                        Text("Your viewed passages will appear here.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(store.history.reversed()) { entry in
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
        .onAppear { enteredKey = store.accessKey }
    }
}
