import Foundation
import UIKit

@MainActor
final class PhotoImageCache {
    static let shared = PhotoImageCache()
    private let images = NSCache<NSString, UIImage>()

    func cached(_ url: String) -> UIImage? {
        images.object(forKey: url as NSString)
    }

    @discardableResult
    func load(_ url: String) async -> UIImage? {
        if let cached = cached(url) { return cached }
        guard let address = URL(string: url),
              let (data, _) = try? await URLSession.shared.data(from: address),
              let image = UIImage(data: data) else { return nil }
        images.setObject(image, forKey: url as NSString)
        return image
    }
}
