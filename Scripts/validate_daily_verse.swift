import Foundation

// Run with DailyVerse.swift compiled alongside this file as main.swift.
let catalogURL = URL(fileURLWithPath: CommandLine.arguments[1])
let verses = try JSONDecoder().decode([DailyVerse].self, from: Data(contentsOf: catalogURL))
precondition(verses.count == 31)
precondition(Set(verses.map(\.reference)).count == verses.count)
precondition(verses.allSatisfy { !$0.text.isEmpty && $0.text.count <= 85 })

for zone in ["America/Denver", "Pacific/Auckland", "Asia/Kolkata", "UTC"] {
    let schedule = DailyVerseSchedule(verses: verses, timeZone: TimeZone(identifier: zone)!)
    let calendar = schedule.calendar
    // Include both DST transitions, leap day, and year rollover.
    for components in [
        DateComponents(year: 2026, month: 3, day: 7, hour: 12),
        DateComponents(year: 2026, month: 10, day: 31, hour: 12),
        DateComponents(year: 2028, month: 2, day: 28, hour: 12),
        DateComponents(year: 2026, month: 12, day: 31, hour: 12)
    ] {
        let start = calendar.date(from: components)!
        let dates = schedule.dates(startingAt: start)
        precondition(dates.count == 8 && dates[0] == start)
        for index in 1..<dates.count {
            let previous = dates[index - 1]
            let next = dates[index]
            precondition(next > previous)
            precondition(calendar.component(.hour, from: next) == 0)
            precondition(schedule.verse(on: previous) != schedule.verse(on: next))
            precondition(schedule.verse(on: next.addingTimeInterval(-1)) == schedule.verse(on: previous))
            precondition(schedule.verse(on: next.addingTimeInterval(3600)) == schedule.verse(on: next))
        }
        let cycle = (0..<31).map {
            schedule.verse(on: calendar.date(byAdding: .day, value: $0, to: start)!).reference
        }
        precondition(Set(cycle).count == 31)
    }
}
precondition(DailyVerseSchedule(verses: []).verse(on: .now) == .sample)
print("Daily verse checks passed: catalog, stable daily selection, midnight rotation, DST, leap day, year rollover, and fallback.")
