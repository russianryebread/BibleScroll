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
    @Environment(\.widgetFamily) private var family
    let entry: DailyVerseEntry

    var body: some View {
        Group {
            if family == .accessoryRectangular {
                lockScreenVerse
            } else {
                homeScreenVerse
            }
        }
        .containerBackground(for: .widget) {
            if family != .accessoryRectangular {
                Color(red: 0.07, green: 0.13, blue: 0.15)
            }
        }
        .widgetURL(entry.verse.appURL)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(entry.verse.text) \(entry.verse.reference), King James Version")
    }

    private var lockScreenVerse: some View {
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
    }

    private var homeScreenVerse: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Daily verse", systemImage: "book")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
            Spacer(minLength: 0)
            Text(entry.verse.text)
                .font(.system(size: family == .systemSmall ? 17 : 21, design: .serif))
                .foregroundStyle(Color(red: 0.99, green: 0.97, blue: 0.92))
                .lineLimit(family == .systemSmall ? 5 : 4)
                .minimumScaleFactor(0.75)
                .fixedSize(horizontal: false, vertical: false)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer(minLength: 0)
            Text("\(entry.verse.reference) · KJV")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
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
        .supportedFamilies([.accessoryRectangular, .systemSmall, .systemMedium])
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
        DailyVerseWidgetView(entry: DailyVerseEntry(date: .now, verse: .sample))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        DailyVerseWidgetView(entry: DailyVerseEntry(
            date: .now,
            verse: DailyVerse(reference: "Proverbs 3:5", text: "Trust in the LORD with all thine heart; and lean not unto thine own understanding.")
        ))
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
