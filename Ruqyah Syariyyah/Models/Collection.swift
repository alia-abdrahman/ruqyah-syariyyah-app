import Foundation

struct Collection: Identifiable, Codable, Hashable {
    let id: String              // Folder name (e.g., "amalan-pendinding-diri")
    let name: String            // Display name
    let nameArabic: String?     // Arabic name
    let description: String?
    let icon: String?           // SF Symbol name or icon identifier
    let sortOrder: Int
    var groupCount: Int
    var totalVerseCount: Int

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case name
        case nameArabic
        case description
        case icon
        case sortOrder
    }

    init(
        id: String,
        name: String,
        nameArabic: String? = nil,
        description: String? = nil,
        icon: String? = nil,
        sortOrder: Int = 0,
        groupCount: Int = 0,
        totalVerseCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.nameArabic = nameArabic
        self.description = description
        self.icon = icon
        self.sortOrder = sortOrder
        self.groupCount = groupCount
        self.totalVerseCount = totalVerseCount
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // ID will be set externally when loading
        id = ""
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        nameArabic = try container.decodeIfPresent(String.self, forKey: .nameArabic)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        icon = try container.decodeIfPresent(String.self, forKey: .icon)
        sortOrder = try container.decodeIfPresent(Int.self, forKey: .sortOrder) ?? 0
        groupCount = 0
        totalVerseCount = 0
    }

    /// Create a collection from JSON with additional parameters
    static func fromJSON(_ data: Data, id: String, groupCount: Int, totalVerseCount: Int) throws -> Collection {
        let decoded = try JSONDecoder().decode(CollectionMetadata.self, from: data)
        return Collection(
            id: id,
            name: decoded.name ?? Collection.formatCollectionName(id),
            nameArabic: decoded.nameArabic,
            description: decoded.description,
            icon: decoded.icon,
            sortOrder: decoded.sortOrder ?? 0,
            groupCount: groupCount,
            totalVerseCount: totalVerseCount
        )
    }

    /// Create a collection from just the folder ID (no metadata file)
    static func fromId(_ id: String, groupCount: Int = 0, totalVerseCount: Int = 0) -> Collection {
        Collection(
            id: id,
            name: formatCollectionName(id),
            groupCount: groupCount,
            totalVerseCount: totalVerseCount
        )
    }

    /// Format folder name to display name
    /// e.g., "amalan-pendinding-diri" -> "Amalan Pendinding Diri"
    static func formatCollectionName(_ folderId: String) -> String {
        folderId
            .split(separator: "-")
            .map { word in
                word.isEmpty ? "" : word.prefix(1).uppercased() + word.dropFirst()
            }
            .joined(separator: " ")
    }

    // MARK: - Icon Mapping
    var sfSymbol: String {
        switch icon {
        case "shield": return "shield.fill"
        case "heart": return "heart.fill"
        case "book": return "book.fill"
        case "moon": return "moon.fill"
        case "sun": return "sun.max.fill"
        case "star": return "star.fill"
        case "home": return "house.fill"
        default: return "book.closed.fill"
        }
    }

    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Collection, rhs: Collection) -> Bool {
        lhs.id == rhs.id
    }
}

// Helper struct for JSON decoding
private struct CollectionMetadata: Codable {
    let name: String?
    let nameArabic: String?
    let description: String?
    let icon: String?
    let sortOrder: Int?
}
