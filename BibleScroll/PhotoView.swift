import SwiftUI

struct PhotoView: View {
    let url: String
    let active: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var moving = false
    @State private var loadedImage: (url: String, image: UIImage)?

    private var direction: CGFloat {
        let hash = url.utf8.reduce(UInt64(14695981039346656037)) { ($0 ^ UInt64($1)) &* 1099511628211 }
        return hash.isMultiple(of: 2) ? 1 : -1
    }

    var body: some View {
        GeometryReader { geometry in
            Group {
                if let image = loadedImage?.url == url ? loadedImage?.image : PhotoImageCache.shared.cached(url) {
                    Image(uiImage: image).resizable().scaledToFill()
                } else {
                    LinearGradient(colors: [.init(red: 0.16, green: 0.28, blue: 0.29), .init(red: 0.03, green: 0.08, blue: 0.12)], startPoint: .topLeading, endPoint: .bottomTrailing)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .scaleEffect(reduceMotion ? 1.02 : (moving ? 1.15 : 1.04))
            .offset(x: reduceMotion ? 0 : (moving ? 9 * direction : -9 * direction),
                    y: reduceMotion ? 0 : (moving ? -7 : 7))
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
            .overlay {
                LinearGradient(
                    stops: [
                        .init(color: .black.opacity(0.32), location: 0),
                        .init(color: .black.opacity(0.44), location: 0.43),
                        .init(color: .black.opacity(0.72), location: 1)
                    ], startPoint: .top, endPoint: .bottom
                )
            }
            .onAppear { startMotion() }
            .onChange(of: active) { _, _ in startMotion() }
            .onChange(of: url) { _, _ in startMotion() }
            .task(id: url) {
                loadedImage = await PhotoImageCache.shared.load(url).map { (url, $0) }
            }
        }
    }

    private func startMotion() {
        moving = false
        guard active && !reduceMotion else { return }
        withAnimation(.easeInOut(duration: 20)) { moving = true }
    }
}
