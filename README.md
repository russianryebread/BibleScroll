# Bible Scroll

A native iPhone scripture feed built with SwiftUI. Each page combines two or three consecutive KJV verses with a portrait photo from Unsplash. A swipe slides the whole scene vertically. Longer passages scroll within their page first, then a continued swipe past the text edge moves to the next or previous scene. Scrolling back returns to the same passage and photo; Settings contains the complete ordered history.

The agreed behavior, implementation map, remaining checks, and UI image are in [docs/PLAN.md](docs/PLAN.md).

## Open and run

1. Install Xcode 16 or later and [XcodeGen](https://github.com/yonaskolb/XcodeGen).
2. Run `xcodegen generate` in this directory, then open `BibleScroll.xcodeproj`.
3. Set your development team in Xcode and run on an iPhone or iPhone simulator (iOS 17 or later).
4. In the app, tap the gear and enter your Unsplash **Access Key**. Create one at [Unsplash Developers](https://unsplash.com/developers). The Secret Key is not used.

The app uses Unsplash's public `Client-ID` authentication. The access key is stored in the iOS Keychain. Photo request timestamps, photo credit metadata, and the ordered history are stored in Application Support. Each history entry contains only the passage key and photo URL (plus a local stable ID). When 40 photo requests have been attempted within a rolling hour, further passages reuse photos from the local pool. This limit applies to one installation; a public release with a shared API key would need a central rate budget.

The KJV source is bundled, so passage text is available offline. Previously loaded photos may be available from the system URL cache; new photos require a connection.

## Bible text

`BibleScroll/Resources/kjv.txt` is the 66-book King James (Authorized) Version from [eBible.org](https://ebible.org/eng-kjv2006/), downloaded as `eng-kjv2006_usfm.zip` on 2026-09-27 and converted with `Scripts/import_kjv.py`. The conversion strips USFM tags, Strong's number metadata, footnotes, and section headings while retaining verse wording. eBible marks this edition public domain outside the UK and notes a UK printing restriction in its [copyright statement](https://ebible.org/eng-kjv2006/copyright.htm).
