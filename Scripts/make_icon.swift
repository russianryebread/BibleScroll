import AppKit

// Generate the app and splash assets from the supplied icon artwork.
let source = URL(fileURLWithPath: "icon.png")
guard let artwork = NSImage(contentsOf: source) else {
    fatalError("Missing icon.png in the repository root")
}

func writeIcon(size: CGFloat, cornerRadius: CGFloat, to destination: String) throws {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    NSGraphicsContext.current?.imageInterpolation = .high
    NSColor.clear.setFill()
    NSRect(x: 0, y: 0, width: size, height: size).fill()

    let bounds = NSRect(x: 0, y: 0, width: size, height: size)
    if cornerRadius > 0 {
        NSBezierPath(roundedRect: bounds, xRadius: cornerRadius, yRadius: cornerRadius).addClip()
    }
    artwork.draw(in: bounds, from: .zero, operation: .copy, fraction: 1)
    image.unlockFocus()

    let bitmap = NSBitmapImageRep(data: image.tiffRepresentation!)!
    let png = bitmap.representation(using: .png, properties: [:])!
    try png.write(to: URL(fileURLWithPath: destination))
}

try writeIcon(size: 1024, cornerRadius: 0,
              to: "BibleScroll/Assets.xcassets/AppIcon.appiconset/AppIcon.png")
try writeIcon(size: 512, cornerRadius: 115,
              to: "BibleScroll/Assets.xcassets/BrandIcon.imageset/BrandIcon.png")
