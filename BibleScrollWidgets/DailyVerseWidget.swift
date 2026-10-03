import SwiftUI
import WidgetKit

struct DailyVerseEntry: TimelineEntry {
    let date: Date
    let verse: DailyVerse
}

struct DailyVerseProvider: TimelineProvider {
    func placeholder(in context: Context) -> DailyVerseEntry {
        DailyVerseEntry(date: .now, verse: .sample)
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyVerseEntry) -> Void) {
        let now = Date()
        completion(DailyVerseEntry(date: now, verse: DailyVerseSchedule.bundled().verse(on: now)))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyVerseEntry>) -> Void) {
        let schedule = DailyVerseSchedule.bundled()
        // Queue a week of local midnights so rotation doesn't require opening the app.
        let entries = schedule.dates(startingAt: .now).map {
            DailyVerseEntry(date: $0, verse: schedule.verse(on: $0))
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

struct DailyVerseWidgetView: View {
    let entry: DailyVerseEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(entry.verse.text)
                .font(.system(size: 13, weight: .regular, design: .serif))
                .lineLimit(3)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("\(entry.verse.reference) · KJV")
                .font(.system(size: 10, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .containerBackground(.clear, for: .widget)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(entry.verse.text) \(entry.verse.reference), King James Version")
    }
}

@main
struct DailyVerseWidget: Widget {
    let kind = "BibleScrollDailyVerse"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailyVerseProvider()) { entry in
            DailyVerseWidgetView(entry: entry)
        }
        .configurationDisplayName("Daily Bible Verse")
        .description("A single KJV verse for each day, available offline.")
        .supportedFamilies([.accessoryRectangular])
    }
}

struct DailyVerseWidgetPreviews: PreviewProvider {
    static var previews: some View {
        DailyVerseWidgetView(entry: DailyVerseEntry(date: .now, verse: .sample))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        DailyVerseWidgetView(entry: DailyVerseEntry(
            date: .now,
            verse: DailyVerse(reference: "Proverbs 3:5", text: "Trust in the LORD with all thine heart; and lean not unto thine own understanding.")
        ))
        .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
