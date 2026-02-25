import Foundation

struct Article: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let content: String
    let language: String
    let category: String
    let publishedDate: Date?
    var isBookmarked: Bool

    init(
        id: String = UUID().uuidString,
        title: String,
        content: String,
        language: String = "en",
        category: String = "General",
        publishedDate: Date? = nil,
        isBookmarked: Bool = false
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.language = language
        self.category = category
        self.publishedDate = publishedDate
        self.isBookmarked = isBookmarked
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case language
        case category
        case publishedDate
        case isBookmarked
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        language = try container.decodeIfPresent(String.self, forKey: .language) ?? "en"
        category = try container.decodeIfPresent(String.self, forKey: .category) ?? "General"
        publishedDate = try container.decodeIfPresent(Date.self, forKey: .publishedDate)
        isBookmarked = try container.decodeIfPresent(Bool.self, forKey: .isBookmarked) ?? false
    }

    var formattedDate: String? {
        guard let date = publishedDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
