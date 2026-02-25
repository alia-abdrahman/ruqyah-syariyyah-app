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
