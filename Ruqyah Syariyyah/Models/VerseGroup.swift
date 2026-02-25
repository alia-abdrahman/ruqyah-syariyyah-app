import Foundation

struct VerseGroup: Identifiable, Codable, Hashable {
    var id: String { "\(collectionId)_\(name)" }

    let name: String            // Display name
    let collectionId: String    // Parent collection folder name
    let sortOrder: Int
    var verseCount: Int
    let arabicPreview: String?  // First verse Arabic text for preview

    init(
        name: String,
        collectionId: String,
        sortOrder: Int = 0,
        verseCount: Int = 0,
        arabicPreview: String? = nil
    ) {
        self.name = name
        self.collectionId = collectionId
        self.sortOrder = sortOrder
        self.verseCount = verseCount
        self.arabicPreview = arabicPreview
    }

    /// Create from filename and collection
    static func fromFile(
        filename: String,
        collectionId: String,
        sortOrder: Int = 0,
        verseCount: Int = 0,
        arabicPreview: String? = nil
    ) -> VerseGroup {
        let cleanName = filename.replacingOccurrences(of: ".json", with: "")
        return VerseGroup(
            name: formatGroupName(cleanName),
            collectionId: collectionId,
            sortOrder: sortOrder,
            verseCount: verseCount,
            arabicPreview: arabicPreview
        )
    }

    /// Format filename to display name
    /// e.g., "surah_al_fatihah" or "surah-al-fatihah" -> "Surah Al-Fatihah"
    static func formatGroupName(_ fileId: String) -> String {
        // Replace underscores with hyphens for consistent processing
        let normalized = fileId.replacingOccurrences(of: "_", with: "-")
        let words = normalized.split(separator: "-")
        var formattedWords: [String] = []

        var i = 0
        while i < words.count {
            let word = String(words[i])
            guard !word.isEmpty else {
                i += 1
                continue
            }

            // Handle "al" prefix - join with next word using hyphen
            if word.lowercased() == "al" && i + 1 < words.count {
                let nextWord = String(words[i + 1])
                let capitalizedWord = word.prefix(1).uppercased() + word.dropFirst().lowercased()
                let capitalizedNext = nextWord.isEmpty ? "" : nextWord.prefix(1).uppercased() + nextWord.dropFirst().lowercased()
                formattedWords.append("\(capitalizedWord)-\(capitalizedNext)")
                i += 2 // Skip next word as we've already processed it
            } else {
                formattedWords.append(word.prefix(1).uppercased() + word.dropFirst().lowercased())
                i += 1
            }
        }

        return formattedWords.joined(separator: " ")
    }

    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(collectionId)
        hasher.combine(name)
    }

    static func == (lhs: VerseGroup, rhs: VerseGroup) -> Bool {
        lhs.collectionId == rhs.collectionId && lhs.name == rhs.name
    }
}
