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
        // Handle special cases with custom display names
        let specialNames: [String: String] = [
            "surah_al_baqarah_1_5": "Surah Al-Baqarah (1-5)",
            "surah_al_baqarah_284_286": "Surah Al-Baqarah (284-286)",
            "ayat_al_kursi": "Ayat Al-Kursi",
            "pendinding_diri_surah_al_fatihah": "Surah Al-Fatihah",
            "pendinding_kediaman_surah_al_fatihah": "Surah Al-Fatihah",
            "pendinding_kediaman_ayat_al_kursi": "Ayat Al-Kursi",
            "pendinding_kediaman_surah_yasin_1_9": "Surah Yasin (1-9)",
            "pendinding_kediaman_surah_taha_111": "Surah Taha (111)",
            "pendinding_kediaman_zikir_shahatil_wujuh": "Dhikr for Protection",
            "zikir_doa_pendinding": "Zikir & Doa Pendinding",
            "surah_al_anbiya_87": "Surah Al-Anbiya' (87)",
            "surah_al_mukminun_97_98": "Surah Al-Mu'minun (97-98)",
            "amalan_kendiri_surah_al_fatihah": "Surah Al-Fatihah",
            "amalan_kendiri_surah_al_baqarah_255_257": "Surah Al-Baqarah (255-257)",
            "amalan_kendiri_surah_al_hasyr_21_24": "Surah Al-Hasyr (21-24)",
            "amalan_kendiri_surah_al_mukminun_115_118": "Surah Al-Mu'minun (115-118)",
            // Amalan Pendinding Diri with sort order prefixes
            "pendinding_diri_01_surah_al_fatihah": "Surah Al-Fatihah",
            "pendinding_diri_02_surah_al_baqarah_1_5": "Surah Al-Baqarah (1-5)",
            "pendinding_diri_03_ayat_al_kursi": "Ayat Al-Kursi",
            "pendinding_diri_04_surah_al_baqarah_284_286": "Surah Al-Baqarah (284-286)",
            "pendinding_diri_05_surah_al_ikhlas": "Surah Al-Ikhlas",
            "pendinding_diri_06_surah_al_falaq": "Surah Al-Falaq",
            "pendinding_diri_07_surah_an_nas": "Surah An-Nas",
            "pendinding_diri_08_zikir_doa_pendinding": "Zikir & Doa Pendinding",
            "pendinding_diri_09_surah_al_anbiya_87": "Surah Al-Anbiya' (87)",
            "pendinding_diri_10_surah_al_mukminun_97_98": "Surah Al-Mu'minun (97-98)"
        ]

        if let specialName = specialNames[fileId] {
            return specialName
        }

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

            // Skip numeric suffixes (like version numbers)
            if let _ = Int(word) {
                i += 1
                continue
            }

            // Handle "al" or "an" prefix - join with next word using hyphen
            if (word.lowercased() == "al" || word.lowercased() == "an") && i + 1 < words.count {
                let nextWord = String(words[i + 1])
                // Skip if next word is a number
                if let _ = Int(nextWord) {
                    formattedWords.append(word.prefix(1).uppercased() + word.dropFirst().lowercased())
                    i += 1
                } else {
                    let capitalizedWord = word.prefix(1).uppercased() + word.dropFirst().lowercased()
                    let capitalizedNext = nextWord.isEmpty ? "" : nextWord.prefix(1).uppercased() + nextWord.dropFirst().lowercased()
                    formattedWords.append("\(capitalizedWord)-\(capitalizedNext)")
                    i += 2 // Skip next word as we've already processed it
                }
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
