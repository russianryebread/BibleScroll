import Foundation

struct Passage: Identifiable {
    let key: String
    let reference: String
    let text: String
    var id: String { key }
}

struct Chapter: Identifiable {
    struct Verse: Identifiable {
        let number: Int
        let text: String
        var id: Int { number }
    }

    let key: String
    let reference: String
    let verses: [Verse]
    var id: String { key }
}

final class BibleLibrary {
    static let shared = BibleLibrary()

    private struct Verse {
        let book: String
        let chapter: Int
        let number: Int
        let text: String
    }

    private let bookNames: [String: String] = [
        "GEN":"Genesis", "EXO":"Exodus", "LEV":"Leviticus", "NUM":"Numbers", "DEU":"Deuteronomy",
        "JOS":"Joshua", "JDG":"Judges", "RUT":"Ruth", "1SA":"1 Samuel", "2SA":"2 Samuel",
        "1KI":"1 Kings", "2KI":"2 Kings", "1CH":"1 Chronicles", "2CH":"2 Chronicles", "EZR":"Ezra",
        "NEH":"Nehemiah", "EST":"Esther", "JOB":"Job", "PSA":"Psalm", "PRO":"Proverbs",
        "ECC":"Ecclesiastes", "SOL":"Song of Solomon", "ISA":"Isaiah", "JER":"Jeremiah", "LAM":"Lamentations",
        "EZE":"Ezekiel", "DAN":"Daniel", "HOS":"Hosea", "JOE":"Joel", "AMO":"Amos",
        "OBA":"Obadiah", "JON":"Jonah", "MIC":"Micah", "NAH":"Nahum", "HAB":"Habakkuk",
        "ZEP":"Zephaniah", "HAG":"Haggai", "ZEC":"Zechariah", "MAL":"Malachi", "MAT":"Matthew",
        "MAR":"Mark", "LUK":"Luke", "JOH":"John", "ACT":"Acts", "ROM":"Romans",
        "1CO":"1 Corinthians", "2CO":"2 Corinthians", "GAL":"Galatians", "EPH":"Ephesians", "PHI":"Philippians",
        "COL":"Colossians", "1TH":"1 Thessalonians", "2TH":"2 Thessalonians", "1TI":"1 Timothy", "2TI":"2 Timothy",
        "TIT":"Titus", "PHM":"Philemon", "HEB":"Hebrews", "JAM":"James", "1PE":"1 Peter",
        "2PE":"2 Peter", "1JO":"1 John", "2JO":"2 John", "3JO":"3 John", "JUD":"Jude", "REV":"Revelation"
    ]

    private var chapters: [String: [Verse]] = [:]
    private var candidates: [String] = []

    private init() {
        guard let url = Bundle.main.url(forResource: "kjv", withExtension: "txt"),
              let source = try? String(contentsOf: url, encoding: .utf8) else { return }
        for line in source.split(whereSeparator: \.isNewline) {
            let pieces = line.split(separator: " ", maxSplits: 2)
            guard pieces.count == 3 else { continue }
            let address = pieces[1].split(separator: ":")
            guard address.count == 2,
                  let chapter = Int(address[0]), let number = Int(address[1]) else { continue }
            let book = String(pieces[0])
            let chapterKey = "\(book) \(chapter)"
            let cleaned = String(pieces[2]).replacingOccurrences(of: "¶ ", with: "")
            chapters[chapterKey, default: []].append(Verse(book: book, chapter: chapter, number: number, text: cleaned))
        }
        for (chapterKey, verses) in chapters {
            guard verses.count >= 2 else { continue }
            for start in 0..<(verses.count - 1) {
                for length in 2...min(3, verses.count - start) {
                    let slice = verses[start..<(start + length)]
                    guard zip(slice, slice.dropFirst()).allSatisfy({ pair in pair.1.number == pair.0.number + 1 }) else { continue }
                    let characterCount = slice.reduce(0) { $0 + $1.text.count }
                    guard characterCount >= 55 && characterCount <= 700 else { continue }
                    candidates.append("\(chapterKey):\(slice.first!.number)-\(slice.last!.number)")
                }
            }
        }
    }

    var verseCount: Int { chapters.values.reduce(0) { $0 + $1.count } }

    func randomKey(excluding recent: Set<String>) -> String? {
        guard !candidates.isEmpty else { return nil }
        for _ in 0..<30 {
            let key = candidates.randomElement()!
            if !recent.contains(key) { return key }
        }
        return candidates.first { !recent.contains($0) } ?? candidates.randomElement()
    }

    func passage(for key: String) -> Passage? {
        guard let colon = key.lastIndex(of: ":") else { return nil }
        let chapterKey = String(key[..<colon])
        let bounds = key[key.index(after: colon)...].split(separator: "-")
        guard bounds.count == 2, let start = Int(bounds[0]), let end = Int(bounds[1]),
              let verses = chapters[chapterKey], start <= end else { return nil }
        let selected = verses.filter { $0.number >= start && $0.number <= end }
        guard selected.count == end - start + 1, let first = selected.first,
              let bookName = bookNames[first.book] else { return nil }
        let reference = "\(bookName) \(first.chapter):\(start)–\(end)"
        return Passage(key: key, reference: reference, text: selected.map(\.text).joined(separator: " "))
    }

    func chapter(for passageKey: String) -> Chapter? {
        guard let colon = passageKey.lastIndex(of: ":") else { return nil }
        let key = String(passageKey[..<colon])
        guard let verses = chapters[key]?.sorted(by: { $0.number < $1.number }),
              let first = verses.first,
              let bookName = bookNames[first.book] else { return nil }
        return Chapter(
            key: key,
            reference: "\(bookName) \(first.chapter)",
            verses: verses.map { Chapter.Verse(number: $0.number, text: $0.text) }
        )
    }
}
