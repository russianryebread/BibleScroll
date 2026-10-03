import Foundation

struct DailyVerse: Codable, Equatable {
    let reference: String
    let text: String

    static let sample = DailyVerse(
        reference: "Psalm 23:1",
        text: "The LORD is my shepherd; I shall not want."
    )
}

struct DailyVerseSchedule {
    let verses: [DailyVerse]
    var calendar: Calendar

    init(verses: [DailyVerse], timeZone: TimeZone = .current) {
        self.verses = verses.isEmpty ? [.sample] : verses
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        self.calendar = calendar
    }

    static func bundled() -> DailyVerseSchedule {
        let verses: [DailyVerse]
        if let url = Bundle.main.url(forResource: "daily-verses", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([DailyVerse].self, from: data),
           decoded.allSatisfy({ !$0.reference.isEmpty && !$0.text.isEmpty }) {
            verses = decoded
        } else {
            verses = [.sample]
        }
        return DailyVerseSchedule(verses: verses)
    }

    func verse(on date: Date) -> DailyVerse {
        // Calendar days keep the selection stable across refreshes and DST changes.
        let anchor = calendar.date(from: DateComponents(year: 2020, month: 1, day: 1))!
        let day = calendar.dateComponents([.day], from: anchor, to: calendar.startOfDay(for: date)).day!
        let index = ((day % verses.count) + verses.count) % verses.count
        return verses[index]
    }

    func dates(startingAt date: Date, days: Int = 7) -> [Date] {
        let midnight = calendar.startOfDay(for: date)
        return [date] + (1...max(1, days)).compactMap {
            calendar.date(byAdding: .day, value: $0, to: midnight)
        }
    }
}
