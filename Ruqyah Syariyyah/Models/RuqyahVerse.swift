import Foundation

struct RuqyahVerse: Identifiable, Codable, Hashable {
    var id: String { uniqueKey }

    let arabicText: String
    let englishTranslation: String
    let malayTranslation: String
    let category: String
    let group: String
    let collection: String?
    let reference: String?
    let audioPath: String?
    let verseNumber: String?
    let sortOrder: Int
    let recommendedRepetitions: Int?

    // Computed unique key for identification
    var uniqueKey: String {
        if let collection = collection {
            return "\(collection)_\(group)_\(sortOrder)"
        }
        return "\(category)_\(group)_\(sortOrder)"
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case arabicText
        case englishTranslation
        case malayTranslation
        case category
        case group
        case collection
        case reference
        case audioPath
        case verseNumber
        case sortOrder
        case recommendedRepetitions
    }

    init(
        arabicText: String,
        englishTranslation: String,
        malayTranslation: String,
        category: String = "",
        group: String,
        collection: String? = nil,
        reference: String? = nil,
        audioPath: String? = nil,
        verseNumber: String? = nil,
        sortOrder: Int = 0,
        recommendedRepetitions: Int? = nil
    ) {
        self.arabicText = arabicText
        self.englishTranslation = englishTranslation
        self.malayTranslation = malayTranslation
        self.category = category
        self.group = group
        self.collection = collection
        self.reference = reference
        self.audioPath = audioPath
        self.verseNumber = verseNumber
        self.sortOrder = sortOrder
        self.recommendedRepetitions = recommendedRepetitions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        arabicText = try container.decode(String.self, forKey: .arabicText)
        englishTranslation = try container.decode(String.self, forKey: .englishTranslation)
        malayTranslation = try container.decode(String.self, forKey: .malayTranslation)
        category = try container.decodeIfPresent(String.self, forKey: .category) ?? ""
        group = try container.decodeIfPresent(String.self, forKey: .group) ?? "Uncategorized"
        collection = try container.decodeIfPresent(String.self, forKey: .collection)
        reference = try container.decodeIfPresent(String.self, forKey: .reference)
        audioPath = try container.decodeIfPresent(String.self, forKey: .audioPath)
        verseNumber = try container.decodeIfPresent(String.self, forKey: .verseNumber)
        sortOrder = try container.decodeIfPresent(Int.self, forKey: .sortOrder) ?? 0
        recommendedRepetitions = try container.decodeIfPresent(Int.self, forKey: .recommendedRepetitions)
    }

    // MARK: - Translation Helper
    func translation(for language: Language) -> String {
        switch language {
        case .english:
            return englishTranslation
        case .malay:
            return malayTranslation
        }
    }

    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(uniqueKey)
    }

    static func == (lhs: RuqyahVerse, rhs: RuqyahVerse) -> Bool {
        lhs.uniqueKey == rhs.uniqueKey
    }
}
