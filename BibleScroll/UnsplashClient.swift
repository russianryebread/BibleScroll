import Foundation

enum PhotoError: LocalizedError {
    case missingKey
    case badResponse
    case rateLimited

    var errorDescription: String? {
        switch self {
        case .missingKey: "Add an Unsplash access key in Settings to begin."
        case .badResponse: "The next photo could not be loaded. Try again."
        case .rateLimited: "Unsplash is temporarily rate limiting photo requests."
        }
    }
}

struct UnsplashClient {
    private struct Response: Decodable {
        struct URLs: Decodable { let regular: String }
        struct User: Decodable {
            struct Links: Decodable { let html: String }
            let name: String
            let links: Links
        }
        struct Links: Decodable { let html: String }
        let urls: URLs
        let user: User
        let links: Links
    }

    func randomPortrait(accessKey: String) async throws -> (PhotoRecord, Int?) {
        guard !accessKey.isEmpty else { throw PhotoError.missingKey }
        var components = URLComponents(string: "https://api.unsplash.com/photos/random")!
        components.queryItems = [
            URLQueryItem(name: "orientation", value: "portrait"),
            URLQueryItem(name: "query", value: "nature landscape"),
            URLQueryItem(name: "content_filter", value: "high")
        ]
        var request = URLRequest(url: components.url!)
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        request.setValue("v1", forHTTPHeaderField: "Accept-Version")
        request.timeoutInterval = 20
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw PhotoError.badResponse }
        if http.statusCode == 403 || http.statusCode == 429 { throw PhotoError.rateLimited }
        guard (200...299).contains(http.statusCode),
              let photo = try? JSONDecoder().decode(Response.self, from: data) else { throw PhotoError.badResponse }
        let record = PhotoRecord(
            url: photo.urls.regular,
            photographer: photo.user.name,
            photographerURL: tracked(photo.user.links.html),
            unsplashURL: tracked(photo.links.html)
        )
        let remaining = http.value(forHTTPHeaderField: "X-Ratelimit-Remaining").flatMap(Int.init)
        return (record, remaining)
    }

    private func tracked(_ string: String) -> String {
        guard var components = URLComponents(string: string) else { return string }
        var items = components.queryItems ?? []
        items.removeAll { $0.name == "utm_source" || $0.name == "utm_medium" }
        items.append(URLQueryItem(name: "utm_source", value: "BibleScroll"))
        items.append(URLQueryItem(name: "utm_medium", value: "referral"))
        components.queryItems = items
        return components.url?.absoluteString ?? string
    }
}
