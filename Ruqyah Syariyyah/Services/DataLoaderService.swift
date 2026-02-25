import Foundation

actor DataLoaderService {
    static let shared = DataLoaderService()

    private init() {}

    // MARK: - Load All Collections and Verses
    func loadAllContent() async throws -> (collections: [Collection], verses: [RuqyahVerse], groupsByCollection: [String: [VerseGroup]]) {
        var allVerses: [RuqyahVerse] = []
        var collections: [Collection] = []
        var groupsByCollection: [String: [VerseGroup]] = [:]

        // Find all JSON files in the bundle
        guard let allJSONFiles = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) else {
            print("No JSON files found in bundle")
            throw DataLoaderError.resourceNotFound
        }

        print("Found \(allJSONFiles.count) JSON files in bundle")

        // Separate collection metadata files from verse files
        let collectionFiles = allJSONFiles.filter { $0.lastPathComponent.contains("_collection.json") }
        let verseFiles = allJSONFiles.filter {
            !$0.lastPathComponent.contains("_collection.json") &&
            !$0.lastPathComponent.contains("articles")
        }

        print("Collection files: \(collectionFiles.map { $0.lastPathComponent })")
        print("Verse files: \(verseFiles.map { $0.lastPathComponent })")

        // Group verse files by collection (based on naming convention)
        var verseFilesByCollection: [String: [URL]] = [:]

        for verseFile in verseFiles {
            let collectionId = inferCollectionId(from: verseFile.lastPathComponent)
            if verseFilesByCollection[collectionId] == nil {
                verseFilesByCollection[collectionId] = []
            }
            verseFilesByCollection[collectionId]?.append(verseFile)
        }

        // Process each collection
        for (collectionId, files) in verseFilesByCollection {
            var groups: [VerseGroup] = []
            var collectionVerseCount = 0
            var sortOrder = 0

            // Load collection metadata if exists
            let collectionFile = collectionFiles.first {
                $0.lastPathComponent.contains(collectionId.replacingOccurrences(of: "-", with: "_"))
            }
            var collectionMetadata: Data?
            if let file = collectionFile {
                collectionMetadata = try? Data(contentsOf: file)
            }

            // Sort files for consistent ordering
            let sortedFiles = files.sorted { $0.lastPathComponent < $1.lastPathComponent }

            for fileURL in sortedFiles {
                let filename = fileURL.deletingPathExtension().lastPathComponent
                let groupName = VerseGroup.formatGroupName(filename)

                do {
                    let data = try Data(contentsOf: fileURL)
                    let versesData = try JSONDecoder().decode([VerseJSONData].self, from: data)

                    var arabicPreview: String?
                    for (index, verseData) in versesData.enumerated() {
                        if index == 0 {
                            arabicPreview = verseData.arabicText
                        }

                        let verse = RuqyahVerse(
                            arabicText: verseData.arabicText,
                            englishTranslation: verseData.englishTranslation,
                            malayTranslation: verseData.malayTranslation,
                            category: "",
                            group: groupName,
                            collection: collectionId,
                            reference: verseData.reference,
                            audioPath: verseData.audioPath,
                            verseNumber: verseData.verseNumber,
                            sortOrder: index
                        )
                        allVerses.append(verse)
                    }

                    let group = VerseGroup(
                        name: groupName,
                        collectionId: collectionId,
                        sortOrder: sortOrder,
                        verseCount: versesData.count,
                        arabicPreview: arabicPreview
                    )
                    groups.append(group)
                    collectionVerseCount += versesData.count
                    sortOrder += 1

                } catch {
                    print("Error loading file \(fileURL): \(error)")
                }
            }

            groupsByCollection[collectionId] = groups

            // Create collection
            if let metadata = collectionMetadata {
                if let collection = try? Collection.fromJSON(
                    metadata,
                    id: collectionId,
                    groupCount: groups.count,
                    totalVerseCount: collectionVerseCount
                ) {
                    collections.append(collection)
                }
            } else {
                let collection = Collection.fromId(
                    collectionId,
                    groupCount: groups.count,
                    totalVerseCount: collectionVerseCount
                )
                collections.append(collection)
            }
        }

        // Sort collections by sortOrder
        collections.sort { $0.sortOrder < $1.sortOrder }

        print("Loaded \(collections.count) collections with \(allVerses.count) verses")
        return (collections, allVerses, groupsByCollection)
    }

    // Infer collection ID from filename
    // e.g., "amalan_kendiri_1.json" -> "amalan-kendiri"
    // e.g., "pendinding_diri_surah_al_fatihah.json" -> "amalan-pendinding-diri"
    private func inferCollectionId(from filename: String) -> String {
        let name = filename.replacingOccurrences(of: ".json", with: "")

        // Map known prefixes to collection IDs
        if name.hasPrefix("amalan_kendiri") {
            return "amalan-kendiri"
        } else if name.hasPrefix("pendinding_diri") || name.contains("pendinding_diri") {
            return "amalan-pendinding-diri"
        } else if name.hasPrefix("pendinding_kediaman") || name.contains("pendinding_kediaman") {
            return "amalan-pendinding-kediaman"
        } else if name.hasPrefix("surah_al_ikhlas") {
            return "amalan-pendinding-diri"
        }

        // Default: convert underscores to dashes and take first two parts
        let parts = name.split(separator: "_")
        if parts.count >= 2 {
            return "\(parts[0])-\(parts[1])"
        }
        return name.replacingOccurrences(of: "_", with: "-")
    }
}

// MARK: - Helper Types
private struct VerseJSONData: Codable {
    let arabicText: String
    let englishTranslation: String
    let malayTranslation: String
    let reference: String?
    let audioPath: String?
    let verseNumber: String?
}

// MARK: - Errors
enum DataLoaderError: Error, LocalizedError {
    case resourceNotFound
    case failedToReadDirectory
    case failedToParseJSON

    var errorDescription: String? {
        switch self {
        case .resourceNotFound:
            return "Could not find verse data resources"
        case .failedToReadDirectory:
            return "Failed to read verses directory"
        case .failedToParseJSON:
            return "Failed to parse verse JSON data"
        }
    }
}
