# Bible Scroll

A native iPhone scripture feed built with SwiftUI. Each page combines two or three consecutive KJV verses with a portrait photo from Unsplash. A swipe slides the whole scene vertically. Longer passages scroll within their page first, then a continued swipe past the text edge moves to the next or previous scene. Scrolling back returns to the same passage and photo; Settings contains the complete ordered history.

The agreed behavior, implementation map, remaining checks, and UI image are in [docs/PLAN.md](docs/PLAN.md).

## Open and run

1. Install Xcode 16 or later and [XcodeGen](https://github.com/yonaskolb/XcodeGen).
2. Run `xcodegen generate` in this directory, then open `BibleScroll.xcodeproj`.
3. Set your development team in Xcode and run on an iPhone or iPhone simulator (iOS 17 or later).
4. Before distributing a build, set the app owner's Unsplash **Access Key** in `BibleScroll/AppConfiguration.swift`. Users do not enter a key; the feed loads automatically. The Secret Key is not used.

The app uses Unsplash's public `Client-ID` authentication with an Access Key embedded in the app. Photo request timestamps, photo credit metadata, and the ordered history are stored in Application Support. Each history entry contains only the passage key and photo URL (plus a local stable ID). When 40 photo requests have been attempted within a rolling hour, further passages reuse photos from the local pool. This limit applies to one installation; the shared key's Unsplash quota applies across all users.

The KJV source is bundled, so passage text is available offline. Previously loaded photos may be available from the system URL cache; new photos require a connection.

## Daily verse widgets

Long-press the iPhone Lock Screen, choose **Customize → Lock Screen → Add Widgets**, then select **Bible Scroll → Daily Bible Verse**. The rectangular widget shows one complete KJV verse and its reference. It rotates through 31 short verses, works offline, and schedules changes at local midnight with a week of entries prepared ahead. iOS controls the actual refresh time, so an update may appear shortly after midnight. Widget content is independent of feed history.

For the unlocked Home Screen, long-press an empty area, choose **Edit → Add Widget**, and find **Bible Scroll → Daily Bible Verse**. Choose the small square or medium rectangle. Both show the same daily verse as the Lock Screen widget, with a quiet dark background and serif text. They also support Today View.

Open the newly installed app once before adding its widget. The Lock Screen version belongs in the rectangular widget area **below the clock**; the inline area above the clock is not supported. If multiple development copies of Bible Scroll are installed, open the copy that Xcode just ran.

The widget extension is embedded automatically when building the app. Its verse catalog is copied from the bundled KJV, with wording preserved. Preview it in Xcode using `BibleScrollWidgets/DailyVerseWidget.swift`.

Run `sh Scripts/validate_daily_verse.sh` to check daily selection, local midnight transitions, daylight saving changes, leap day, and year rollover.

The app and widget share `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in `project.yml`. After building, run `python3 Scripts/validate_app_bundle.py /path/to/BibleScroll.app` to verify both bundles contain matching, nonempty installation version metadata.

## Bible text source

`BibleScroll/Resources/kjv.txt` is the 66-book King James (Authorized) Version from [eBible.org](https://ebible.org/eng-kjv2006/), downloaded as `eng-kjv2006_usfm.zip` on 2026-09-27 and converted with `Scripts/import_kjv.py`. The conversion strips USFM tags, Strong's number metadata, footnotes, and section headings while retaining verse wording. eBible marks this edition public domain outside the UK and notes a UK printing restriction in its [copyright statement](https://ebible.org/eng-kjv2006/copyright.htm).
