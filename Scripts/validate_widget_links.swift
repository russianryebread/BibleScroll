import Foundation

// Compile with DailyVerse.swift and BibleLibrary.swift as main.swift.
// Place kjv.txt beside the executable and pass the daily-verses.json path.
let catalogURL = URL(fileURLWithPath: CommandLine.arguments[1])
let verses = try JSONDecoder().decode([DailyVerse].self, from: Data(contentsOf: catalogURL))

for verse in verses {
    let components = URLComponents(url: verse.appURL, resolvingAgainstBaseURL: false)!
    precondition(components.scheme == "biblescroll" && components.host == "verse")
    let reference = components.queryItems!.first { $0.name == "reference" }!.value!
    let key = BibleLibrary.shared.passageKey(for: reference)!
    let passage = BibleLibrary.shared.passage(for: key)!
    precondition(passage.reference == verse.reference)
    precondition(passage.text == verse.text)
    precondition(BibleLibrary.shared.chapter(for: key) != nil)
}
precondition(BibleLibrary.shared.passageKey(for: "Psalm 999:1") == nil)
precondition(BibleLibrary.shared.passageKey(for: "Unknown 1:1") == nil)
precondition(BibleLibrary.shared.passage(for: "PSA 23:1-2")!.reference == "Psalm 23:1–2")
print("All 31 widget links resolve to the exact bundled verse; invalid references rejected and passage ranges preserved.")
