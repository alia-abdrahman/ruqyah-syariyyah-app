import Foundation

/// Service to fetch audio from Quran.com API
class QuranAudioService {
    static let shared = QuranAudioService()

    private let baseURL = "https://api.quran.com/api/v4"
    private let defaultReciterId = 7 // Mishari Rashid al-Afasy

    // Cache for audio URLs to avoid repeated API calls
    private var audioURLCache: [String: URL] = [:]

    private init() {}

    // MARK: - Surah Name to Number Mapping
    private let surahNameToNumber: [String: Int] = [
        "al-fatihah": 1,
        "al-baqarah": 2,
        "ali-imran": 3,
        "an-nisa": 4,
        "al-maidah": 5,
        "al-anam": 6,
        "al-araf": 7,
        "al-anfal": 8,
        "at-tawbah": 9,
        "yunus": 10,
        "hud": 11,
        "yusuf": 12,
        "ar-rad": 13,
        "ibrahim": 14,
        "al-hijr": 15,
        "an-nahl": 16,
        "al-isra": 17,
        "al-kahf": 18,
        "maryam": 19,
        "ta-ha": 20,
        "al-anbiya": 21,
        "al-hajj": 22,
        "al-muminun": 23,
        "an-nur": 24,
        "al-furqan": 25,
        "ash-shuara": 26,
        "an-naml": 27,
        "al-qasas": 28,
        "al-ankabut": 29,
        "ar-rum": 30,
        "luqman": 31,
        "as-sajdah": 32,
        "al-ahzab": 33,
        "saba": 34,
        "fatir": 35,
        "ya-sin": 36,
        "as-saffat": 37,
        "sad": 38,
        "az-zumar": 39,
        "ghafir": 40,
        "fussilat": 41,
        "ash-shura": 42,
        "az-zukhruf": 43,
        "ad-dukhan": 44,
        "al-jathiyah": 45,
        "al-ahqaf": 46,
        "muhammad": 47,
        "al-fath": 48,
        "al-hujurat": 49,
        "qaf": 50,
        "adh-dhariyat": 51,
        "at-tur": 52,
        "an-najm": 53,
        "al-qamar": 54,
        "ar-rahman": 55,
        "al-waqiah": 56,
        "al-hadid": 57,
        "al-mujadilah": 58,
        "al-hashr": 59,
        "al-mumtahanah": 60,
        "as-saff": 61,
        "al-jumuah": 62,
        "al-munafiqun": 63,
        "at-taghabun": 64,
        "at-talaq": 65,
        "at-tahrim": 66,
        "al-mulk": 67,
        "al-qalam": 68,
        "al-haqqah": 69,
        "al-maarij": 70,
        "nuh": 71,
        "al-jinn": 72,
        "al-muzzammil": 73,
        "al-muddathir": 74,
        "al-qiyamah": 75,
        "al-insan": 76,
        "al-mursalat": 77,
        "an-naba": 78,
        "an-naziat": 79,
        "abasa": 80,
        "at-takwir": 81,
        "al-infitar": 82,
        "al-mutaffifin": 83,
        "al-inshiqaq": 84,
        "al-buruj": 85,
        "at-tariq": 86,
        "al-ala": 87,
        "al-ghashiyah": 88,
        "al-fajr": 89,
        "al-balad": 90,
        "ash-shams": 91,
        "al-layl": 92,
        "ad-duhaa": 93,
        "ash-sharh": 94,
        "at-tin": 95,
        "al-alaq": 96,
        "al-qadr": 97,
        "al-bayyinah": 98,
        "az-zalzalah": 99,
        "al-adiyat": 100,
        "al-qariah": 101,
        "at-takathur": 102,
        "al-asr": 103,
        "al-humazah": 104,
        "al-fil": 105,
        "quraysh": 106,
        "al-maun": 107,
        "al-kawthar": 108,
        "al-kafirun": 109,
        "an-nasr": 110,
        "al-masad": 111,
        "al-ikhlas": 112,
        "al-falaq": 113,
        "an-nas": 114
    ]

    // MARK: - Parse Reference to Verse Key
    /// Parses a reference like "Al-Fatihah 1:5" to verse key "1:5"
    func parseVerseKey(from reference: String?) -> String? {
        guard let reference = reference else { return nil }

        // Pattern: "Surah Name Chapter:Verse" e.g., "Al-Fatihah 1:5" or "Al-Baqarah 2:255"
        let pattern = #"([A-Za-z\-']+)\s+(\d+):(\d+)"#

        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: reference, options: [], range: NSRange(reference.startIndex..., in: reference)) else {
            return nil
        }

        guard let surahRange = Range(match.range(at: 1), in: reference),
              let chapterRange = Range(match.range(at: 2), in: reference),
              let verseRange = Range(match.range(at: 3), in: reference) else {
            return nil
        }

        let surahName = String(reference[surahRange]).lowercased()
        let chapter = String(reference[chapterRange])
        let verse = String(reference[verseRange])

        // Verify chapter number matches surah name (optional validation)
        if let expectedChapter = surahNameToNumber[surahName], String(expectedChapter) == chapter {
            return "\(chapter):\(verse)"
        }

        // If surah name doesn't match exactly, still return the verse key from the reference
        return "\(chapter):\(verse)"
    }

    // MARK: - Fetch Audio URL
    /// Fetches audio URL for a specific verse from Quran.com API
    func fetchAudioURL(verseKey: String, reciterId: Int? = nil) async throws -> URL {
        // Check cache first
        let cacheKey = "\(reciterId ?? defaultReciterId)_\(verseKey)"
        if let cachedURL = audioURLCache[cacheKey] {
            return cachedURL
        }

        let reciter = reciterId ?? defaultReciterId
        let urlString = "\(baseURL)/recitations/\(reciter)/by_ayah/\(verseKey)"

        guard let url = URL(string: urlString) else {
            throw QuranAudioError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw QuranAudioError.apiError
        }

        let audioResponse = try JSONDecoder().decode(AudioResponse.self, from: data)

        guard let audioFile = audioResponse.audioFiles.first,
              let audioURL = URL(string: "https://verses.quran.com/\(audioFile.url)") else {
            throw QuranAudioError.noAudioFound
        }

        // Cache the URL
        audioURLCache[cacheKey] = audioURL

        return audioURL
    }

    /// Fetches audio URL using reference string (e.g., "Al-Fatihah 1:1")
    func fetchAudioURL(reference: String, reciterId: Int? = nil) async throws -> URL {
        guard let verseKey = parseVerseKey(from: reference) else {
            throw QuranAudioError.invalidReference
        }
        return try await fetchAudioURL(verseKey: verseKey, reciterId: reciterId)
    }

    // MARK: - Batch Fetch Audio URLs
    /// Fetches audio URLs for multiple verses
    func fetchAudioURLs(verseKeys: [String], reciterId: Int? = nil) async throws -> [String: URL] {
        var results: [String: URL] = [:]

        for verseKey in verseKeys {
            do {
                let url = try await fetchAudioURL(verseKey: verseKey, reciterId: reciterId)
                results[verseKey] = url
            } catch {
                print("Failed to fetch audio for \(verseKey): \(error)")
            }
        }

        return results
    }

    // MARK: - Clear Cache
    func clearCache() {
        audioURLCache.removeAll()
    }
}

// MARK: - Response Models
struct AudioResponse: Codable {
    let audioFiles: [AudioFile]

    enum CodingKeys: String, CodingKey {
        case audioFiles = "audio_files"
    }
}

struct AudioFile: Codable {
    let verseKey: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case verseKey = "verse_key"
        case url
    }
}

// MARK: - Errors
enum QuranAudioError: Error, LocalizedError {
    case invalidURL
    case apiError
    case noAudioFound
    case invalidReference

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .apiError:
            return "Failed to fetch from Quran.com API"
        case .noAudioFound:
            return "No audio file found for this verse"
        case .invalidReference:
            return "Could not parse verse reference"
        }
    }
}
