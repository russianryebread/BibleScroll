import AppKit

let size = NSSize(width: 1024, height: 1024)
let image = NSImage(size: size)
image.lockFocus()

let bounds = NSRect(origin: .zero, size: size)
let gradient = NSGradient(starting: NSColor(calibratedRed: 0.17, green: 0.32, blue: 0.33, alpha: 1), ending: NSColor(calibratedRed: 0.025, green: 0.10, blue: 0.13, alpha: 1))!
gradient.draw(in: bounds, angle: -75)

let B = "B" as NSString
let font = NSFont(name: "Georgia", size: 570) ?? NSFont.systemFont(ofSize: 570, weight: .regular)
let attributes: [NSAttributedString.Key: Any] = [
    .font: font,
    .foregroundColor: NSColor(calibratedRed: 0.98, green: 0.96, blue: 0.88, alpha: 1)
]
let textSize = B.size(withAttributes: attributes)
B.draw(at: NSPoint(x: (1024 - textSize.width) / 2, y: (1024 - textSize.height) / 2 + 16), withAttributes: attributes)

image.unlockFocus()
let bitmap = NSBitmapImageRep(data: image.tiffRepresentation!)!
let png = bitmap.representation(using: .png, properties: [:])!
try png.write(to: URL(fileURLWithPath: "BibleScroll/Assets.xcassets/AppIcon.appiconset/AppIcon.png"))
