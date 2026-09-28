import SwiftUI

struct ChapterView: View {
    let chapter: Chapter

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 18) {
                    ForEach(chapter.verses) { verse in
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Text(verse.number.formatted())
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                                .frame(width: 26, alignment: .trailing)
                            Text(verse.text)
                                .font(.system(size: 20, design: .serif))
                                .lineSpacing(6)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 24)
            }
            .navigationTitle(chapter.reference)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
