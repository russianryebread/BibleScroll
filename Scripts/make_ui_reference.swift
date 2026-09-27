import AppKit

let canvas = NSSize(width: 1600, height: 900)
let image = NSImage(size: canvas)
image.lockFocus()

func color(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> NSColor {
    NSColor(calibratedRed: r, green: g, blue: b, alpha: a)
}

func rounded(_ rect: NSRect, radius: CGFloat, fill: NSColor) {
    fill.setFill()
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius).fill()
}

func text(_ value: String, in rect: NSRect, font: NSFont, color ink: NSColor, alignment: NSTextAlignment = .left, tracking: CGFloat = 0) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = alignment
    paragraph.lineSpacing = 5
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: ink,
        .paragraphStyle: paragraph,
        .kern: tracking
    ]
    (value as NSString).draw(in: rect, withAttributes: attributes)
}

let background = color(0.92, 0.94, 0.93)
background.setFill()
NSRect(origin: .zero, size: canvas).fill()

let phoneWidth: CGFloat = 365
let phoneHeight: CGFloat = 745
let phoneY: CGFloat = 86
let feed = NSRect(x: 320, y: phoneY, width: phoneWidth, height: phoneHeight)
let history = NSRect(x: 915, y: phoneY, width: phoneWidth, height: phoneHeight)

text("FEED", in: NSRect(x: feed.minX, y: 846, width: phoneWidth, height: 30), font: .systemFont(ofSize: 17, weight: .semibold), color: color(0.19, 0.28, 0.27), alignment: .center, tracking: 2)
text("SETTINGS  /  HISTORY", in: NSRect(x: history.minX, y: 846, width: phoneWidth, height: 30), font: .systemFont(ofSize: 17, weight: .semibold), color: color(0.19, 0.28, 0.27), alignment: .center, tracking: 2)

NSGraphicsContext.saveGraphicsState()
NSBezierPath(roundedRect: feed, xRadius: 36, yRadius: 36).addClip()
NSGradient(starting: color(0.73, 0.78, 0.68), ending: color(0.02, 0.11, 0.15))!.draw(in: feed, angle: -78)

let distant = NSBezierPath()
distant.move(to: NSPoint(x: feed.minX, y: feed.minY + 260))
distant.line(to: NSPoint(x: feed.minX + 80, y: feed.minY + 500))
distant.line(to: NSPoint(x: feed.minX + 145, y: feed.minY + 340))
distant.line(to: NSPoint(x: feed.minX + 245, y: feed.minY + 560))
distant.line(to: NSPoint(x: feed.maxX, y: feed.minY + 320))
distant.line(to: NSPoint(x: feed.maxX, y: feed.minY))
distant.line(to: NSPoint(x: feed.minX, y: feed.minY))
distant.close()
color(0.25, 0.38, 0.35, 0.72).setFill()
distant.fill()

let near = NSBezierPath()
near.move(to: NSPoint(x: feed.minX, y: feed.minY + 165))
near.line(to: NSPoint(x: feed.minX + 85, y: feed.minY + 295))
near.line(to: NSPoint(x: feed.minX + 190, y: feed.minY + 210))
near.line(to: NSPoint(x: feed.maxX, y: feed.minY + 380))
near.line(to: NSPoint(x: feed.maxX, y: feed.minY))
near.line(to: NSPoint(x: feed.minX, y: feed.minY))
near.close()
color(0.07, 0.19, 0.20, 0.76).setFill()
near.fill()

NSGradient(starting: color(0.04, 0.10, 0.11, 0.35), ending: color(0.02, 0.06, 0.08, 0.82))!.draw(in: feed, angle: 90)
NSGraphicsContext.restoreGraphicsState()

let ivory = color(0.98, 0.97, 0.92)
text("⚙", in: NSRect(x: feed.maxX - 54, y: feed.maxY - 67, width: 34, height: 36), font: .systemFont(ofSize: 27), color: ivory, alignment: .center)
text("SCRIPTURE FOR THIS MOMENT", in: NSRect(x: feed.minX + 15, y: feed.minY + 550, width: feed.width - 30, height: 28), font: .systemFont(ofSize: 10, weight: .semibold), color: ivory, alignment: .center, tracking: 2.3)
text("The LORD is my shepherd;\nI shall not want.\n\nHe maketh me to lie down\nin green pastures: he leadeth\nme beside the still waters.", in: NSRect(x: feed.minX + 24, y: feed.minY + 317, width: feed.width - 48, height: 220), font: NSFont(name: "Georgia", size: 25)!, color: ivory, alignment: .center)
text("PSALM 23:1–2  ·  KJV", in: NSRect(x: feed.minX + 20, y: feed.minY + 243, width: feed.width - 40, height: 25), font: .systemFont(ofSize: 12, weight: .semibold), color: ivory, alignment: .center, tracking: 1.8)
text("Photo by [name] on Unsplash", in: NSRect(x: feed.minX + 21, y: feed.minY + 38, width: 290, height: 20), font: .systemFont(ofSize: 10), color: ivory)
text("↑", in: NSRect(x: feed.maxX - 37, y: feed.minY + 34, width: 20, height: 24), font: .systemFont(ofSize: 22), color: ivory)
rounded(NSRect(x: feed.midX - 54, y: feed.minY + 10, width: 108, height: 4), radius: 2, fill: ivory)

rounded(history, radius: 36, fill: color(0.075, 0.12, 0.13))
text("SETTINGS", in: NSRect(x: history.minX + 24, y: history.maxY - 69, width: 140, height: 22), font: .systemFont(ofSize: 11, weight: .semibold), color: color(0.69, 0.77, 0.74), tracking: 1.9)
text("Done", in: NSRect(x: history.maxX - 74, y: history.maxY - 70, width: 50, height: 22), font: .systemFont(ofSize: 13, weight: .medium), color: color(0.85, 0.91, 0.88), alignment: .right)
text("Reading history", in: NSRect(x: history.minX + 24, y: history.maxY - 143, width: history.width - 48, height: 45), font: NSFont(name: "Georgia", size: 30)!, color: ivory)
text("Return to a passage and its original photo.", in: NSRect(x: history.minX + 24, y: history.maxY - 173, width: history.width - 48, height: 25), font: .systemFont(ofSize: 12), color: color(0.64, 0.72, 0.69))

let rows = ["Psalm 23:1–2", "John 1:4–5", "Isaiah 40:30–31", "Matthew 6:28–29"]
let times = ["KJV", "KJV", "KJV", "KJV"]
for index in rows.indices {
    let y = history.maxY - 257 - CGFloat(index) * 84
    color(0.19, 0.27, 0.27).setStroke()
    let rule = NSBezierPath()
    rule.move(to: NSPoint(x: history.minX + 20, y: y + 76))
    rule.line(to: NSPoint(x: history.maxX - 20, y: y + 76))
    rule.lineWidth = 1
    rule.stroke()
    let thumb = NSRect(x: history.minX + 24, y: y + 11, width: 49, height: 56)
    rounded(thumb, radius: 6, fill: [color(0.58, 0.67, 0.56), color(0.50, 0.58, 0.66), color(0.48, 0.48, 0.60), color(0.62, 0.65, 0.47)][index])
    text(rows[index], in: NSRect(x: history.minX + 91, y: y + 39, width: 225, height: 25), font: NSFont(name: "Georgia", size: 18)!, color: ivory)
    text(times[index], in: NSRect(x: history.minX + 91, y: y + 17, width: 200, height: 20), font: .systemFont(ofSize: 11), color: color(0.64, 0.72, 0.69))
    text("›", in: NSRect(x: history.maxX - 33, y: y + 23, width: 20, height: 30), font: .systemFont(ofSize: 25), color: color(0.64, 0.72, 0.69))
}
text("Bible text is available offline. Photos need a\nconnection unless already cached.", in: NSRect(x: history.minX + 24, y: history.minY + 105, width: history.width - 48, height: 48), font: .systemFont(ofSize: 11), color: color(0.64, 0.72, 0.69))
rounded(NSRect(x: history.midX - 54, y: history.minY + 10, width: 108, height: 4), radius: 2, fill: ivory)

image.unlockFocus()
let bitmap = NSBitmapImageRep(data: image.tiffRepresentation!)!
let png = bitmap.representation(using: .png, properties: [:])!
try png.write(to: URL(fileURLWithPath: "docs/ui-reference.png"))
