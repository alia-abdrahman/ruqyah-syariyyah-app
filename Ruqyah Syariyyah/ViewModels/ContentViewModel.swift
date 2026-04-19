import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
class ContentViewModel: ObservableObject {
    @Published var allVerses: [RuqyahVerse] = []
    @Published var collections: [Collection] = []
    @Published var groupsByCollection: [String: [VerseGroup]] = [:]
    @Published var favoriteVerseKeys: Set<String> = []
    @Published var searchQuery: String = ""
    @Published var isLoading: Bool = false
    @Published var language: Language = .english

    private var modelContext: ModelContext?

    init() {
        loadLanguage()
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        Task {
            await loadFavorites()
            await loadBookmarks()
        }
    }

    // MARK: - Load Content
    func loadContent() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let content = try await DataLoaderService.shared.loadAllContent()
            collections = content.collections
            allVerses = content.verses
            groupsByCollection = content.groupsByCollection
            print("Loaded \(collections.count) collections and \(allVerses.count) verses")
            scheduleDailyVerseNotification()
        } catch {
            print("Error loading content: \(error)")
            // Load sample data as fallback
            loadSampleData()
        }
    }

    private func loadSampleData() {
        collections = [
            Collection(
                id: "sample",
                name: "Sample Collection",
                description: "Sample verses for demonstration",
                icon: "book.fill",
                sortOrder: 0,
                groupCount: 1,
                totalVerseCount: 1
            )
        ]

        allVerses = [
            RuqyahVerse(
                arabicText: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
                englishTranslation: "In the name of Allah, the Most Gracious, the Most Merciful",
                malayTranslation: "Dengan nama Allah, Yang Maha Pemurah, lagi Maha Mengasihani",
                category: "Sample",
                group: "Bismillah",
                collection: "sample",
                reference: "Opening",
                audioPath: nil,
                verseNumber: "1",
                sortOrder: 0
            )
        ]

        groupsByCollection = [
            "sample": [
                VerseGroup(name: "Bismillah", collectionId: "sample", sortOrder: 0, verseCount: 1, arabicPreview: "بِسْمِ اللَّهِ")
            ]
        ]
        print("Loaded sample data as fallback")
    }

    // MARK: - Getters
    func getGroupsForCollection(_ collectionId: String) -> [VerseGroup] {
        groupsByCollection[collectionId] ?? []
    }

    func getVersesForGroup(_ collectionId: String, groupName: String) -> [RuqyahVerse] {
        allVerses
            .filter { $0.collection == collectionId && $0.group == groupName }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    func getVersesForCollection(_ collectionId: String) -> [RuqyahVerse] {
        allVerses.filter { $0.collection == collectionId }
    }

    var favoriteVerses: [RuqyahVerse] {
        allVerses.filter { favoriteVerseKeys.contains($0.uniqueKey) }
    }

    // MARK: - Daily Verse
    private var protectiveDhikrVerses: [RuqyahVerse] {
        allVerses.filter { $0.group.contains("Protective Dhikr") }
    }

    var dailyVerse: RuqyahVerse? {
        let verses = protectiveDhikrVerses
        guard !verses.isEmpty else { return nil }
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = dayOfYear % verses.count
        return verses[index]
    }

    func scheduleDailyVerseNotification() {
        guard StorageService.shared.reminderEnabled,
              let verse = dailyVerse else { return }

        let time = StorageService.shared.reminderTime
        let translation = verse.translation(for: language)
        NotificationService.shared.scheduleDailyVerseNotification(
            at: time,
            verseText: verse.arabicText,
            translation: translation
        )
    }

    // MARK: - Search
    var filteredVerses: [RuqyahVerse] {
        guard !searchQuery.isEmpty else { return allVerses }

        let query = searchQuery.lowercased()
        return allVerses.filter { verse in
            verse.arabicText.lowercased().contains(query) ||
            verse.englishTranslation.lowercased().contains(query) ||
            verse.malayTranslation.lowercased().contains(query) ||
            verse.group.lowercased().contains(query) ||
            (verse.collection?.lowercased().contains(query) ?? false) ||
            (verse.reference?.lowercased().contains(query) ?? false)
        }
    }

    func searchVerses(_ query: String) -> [RuqyahVerse] {
        guard !query.isEmpty else { return [] }

        let lowercasedQuery = query.lowercased()
        return allVerses.filter { verse in
            verse.arabicText.lowercased().contains(lowercasedQuery) ||
            verse.englishTranslation.lowercased().contains(lowercasedQuery) ||
            verse.malayTranslation.lowercased().contains(lowercasedQuery) ||
            verse.group.lowercased().contains(lowercasedQuery) ||
            (verse.reference?.lowercased().contains(lowercasedQuery) ?? false)
        }
    }

    // MARK: - Search Collections
    func searchCollections(_ query: String) -> [Collection] {
        guard !query.isEmpty else { return [] }

        let lowercasedQuery = query.lowercased()
        return collections.filter { collection in
            collection.name.lowercased().contains(lowercasedQuery) ||
            (collection.nameArabic?.lowercased().contains(lowercasedQuery) ?? false) ||
            (collection.description?.lowercased().contains(lowercasedQuery) ?? false)
        }
    }

    // MARK: - Search Groups (Surahs)
    func searchGroups(_ query: String) -> [(group: VerseGroup, collection: Collection)] {
        guard !query.isEmpty else { return [] }

        let lowercasedQuery = query.lowercased()
        var results: [(group: VerseGroup, collection: Collection)] = []

        for collection in collections {
            let groups = getGroupsForCollection(collection.id)
            for group in groups {
                if group.name.lowercased().contains(lowercasedQuery) ||
                   (group.arabicPreview?.lowercased().contains(lowercasedQuery) ?? false) {
                    results.append((group: group, collection: collection))
                }
            }
        }

        return results
    }

    // MARK: - Combined Search Results
    struct SearchResults {
        var collections: [Collection]
        var groups: [(group: VerseGroup, collection: Collection)]
        var verses: [RuqyahVerse]

        var totalCount: Int {
            collections.count + groups.count + verses.count
        }

        var isEmpty: Bool {
            collections.isEmpty && groups.isEmpty && verses.isEmpty
        }
    }

    func searchAll(_ query: String) -> SearchResults {
        return SearchResults(
            collections: searchCollections(query),
            groups: searchGroups(query),
            verses: searchVerses(query)
        )
    }

    // MARK: - Favorites
    func isFavorite(_ verse: RuqyahVerse) -> Bool {
        favoriteVerseKeys.contains(verse.uniqueKey)
    }

    func toggleFavorite(_ verse: RuqyahVerse) async {
        let key = verse.uniqueKey

        if favoriteVerseKeys.contains(key) {
            favoriteVerseKeys.remove(key)
            await removeFavorite(key)
        } else {
            favoriteVerseKeys.insert(key)
            await addFavorite(key)
        }
    }

    private func loadFavorites() async {
        guard let context = modelContext else { return }

        do {
            let descriptor = FetchDescriptor<FavoriteVerse>()
            let favorites = try context.fetch(descriptor)
            favoriteVerseKeys = Set(favorites.map { $0.verseKey })
        } catch {
            print("Error loading favorites: \(error)")
        }
    }

    private func addFavorite(_ key: String) async {
        guard let context = modelContext else { return }

        let favorite = FavoriteVerse(verseKey: key)
        context.insert(favorite)

        do {
            try context.save()
        } catch {
            print("Error saving favorite: \(error)")
        }
    }

    private func removeFavorite(_ key: String) async {
        guard let context = modelContext else { return }

        do {
            let descriptor = FetchDescriptor<FavoriteVerse>(
                predicate: #Predicate { $0.verseKey == key }
            )
            let favorites = try context.fetch(descriptor)
            for favorite in favorites {
                context.delete(favorite)
            }
            try context.save()
        } catch {
            print("Error removing favorite: \(error)")
        }
    }

    // MARK: - Last Read Position
    struct LastReadInfo {
        let collectionId: String
        let groupName: String?
        let collectionName: String
        let groupDisplayName: String?
        let mode: String
        let date: Date
    }

    var lastReadInfo: LastReadInfo? {
        guard let collectionId = StorageService.shared.lastReadCollectionId,
              let collectionName = StorageService.shared.lastReadCollectionName,
              let mode = StorageService.shared.lastReadMode,
              let date = StorageService.shared.lastReadDate else { return nil }

        return LastReadInfo(
            collectionId: collectionId,
            groupName: StorageService.shared.lastReadGroupName,
            collectionName: collectionName,
            groupDisplayName: StorageService.shared.lastReadGroupDisplayName,
            mode: mode,
            date: date
        )
    }

    func saveLastRead(collectionId: String, groupName: String?, collectionName: String, groupDisplayName: String?, mode: String) {
        StorageService.shared.lastReadCollectionId = collectionId
        StorageService.shared.lastReadGroupName = groupName
        StorageService.shared.lastReadCollectionName = collectionName
        StorageService.shared.lastReadGroupDisplayName = groupDisplayName
        StorageService.shared.lastReadMode = mode
        StorageService.shared.lastReadDate = Date()
        objectWillChange.send()
    }

    func clearLastRead() {
        StorageService.shared.lastReadCollectionId = nil
        StorageService.shared.lastReadGroupName = nil
        StorageService.shared.lastReadCollectionName = nil
        StorageService.shared.lastReadGroupDisplayName = nil
        StorageService.shared.lastReadMode = nil
        StorageService.shared.lastReadDate = nil
        objectWillChange.send()
    }

    // MARK: - Bookmarks
    @Published var bookmarkKeys: Set<String> = []

    func loadBookmarks() async {
        guard let context = modelContext else { return }

        do {
            let descriptor = FetchDescriptor<ReadingBookmark>()
            let bookmarks = try context.fetch(descriptor)
            bookmarkKeys = Set(bookmarks.map { $0.bookmarkKey })
        } catch {
            print("Error loading bookmarks: \(error)")
        }
    }

    var allBookmarks: [ReadingBookmark] {
        guard let context = modelContext else { return [] }

        do {
            let descriptor = FetchDescriptor<ReadingBookmark>(
                sortBy: [SortDescriptor(\.dateBookmarked, order: .reverse)]
            )
            return try context.fetch(descriptor)
        } catch {
            print("Error fetching bookmarks: \(error)")
            return []
        }
    }

    func isBookmarked(collectionId: String, groupName: String) -> Bool {
        bookmarkKeys.contains("\(collectionId)_\(groupName)")
    }

    func toggleBookmark(collectionId: String, groupName: String, collectionName: String, groupDisplayName: String) async {
        let key = "\(collectionId)_\(groupName)"

        if bookmarkKeys.contains(key) {
            bookmarkKeys.remove(key)
            await removeBookmark(key)
            // Clear "Continue Reading" if it matches the unbookmarked item
            if let lastRead = lastReadInfo,
               lastRead.collectionId == collectionId {
                clearLastRead()
            }
        } else {
            bookmarkKeys.insert(key)
            await addBookmark(collectionId: collectionId, groupName: groupName, collectionName: collectionName, groupDisplayName: groupDisplayName)
        }
    }

    private func addBookmark(collectionId: String, groupName: String, collectionName: String, groupDisplayName: String) async {
        guard let context = modelContext else { return }

        let bookmark = ReadingBookmark(collectionId: collectionId, groupName: groupName, collectionName: collectionName, groupDisplayName: groupDisplayName)
        context.insert(bookmark)

        do {
            try context.save()
        } catch {
            print("Error saving bookmark: \(error)")
        }
    }

    private func removeBookmark(_ key: String) async {
        guard let context = modelContext else { return }

        do {
            let descriptor = FetchDescriptor<ReadingBookmark>(
                predicate: #Predicate { $0.bookmarkKey == key }
            )
            let bookmarks = try context.fetch(descriptor)
            for bookmark in bookmarks {
                context.delete(bookmark)
            }
            try context.save()
        } catch {
            print("Error removing bookmark: \(error)")
        }
    }

    func deleteBookmark(_ bookmark: ReadingBookmark) async {
        guard let context = modelContext else { return }
        bookmarkKeys.remove(bookmark.bookmarkKey)
        context.delete(bookmark)
        do {
            try context.save()
        } catch {
            print("Error deleting bookmark: \(error)")
        }
        // Clear "Continue Reading" if it matches
        if let lastRead = lastReadInfo,
           lastRead.collectionId == bookmark.collectionId {
            clearLastRead()
        }
    }

    // MARK: - Language
    func loadLanguage() {
        language = StorageService.shared.language
    }

    func setLanguage(_ newLanguage: Language) {
        language = newLanguage
        StorageService.shared.language = newLanguage
    }

    func getTranslation(for verse: RuqyahVerse) -> String {
        verse.translation(for: language)
    }
}
