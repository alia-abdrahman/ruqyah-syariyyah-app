import Foundation
import SwiftUI
import Combine

@MainActor
class ArticlesViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var selectedCategory: String = "All"
    @Published var searchQuery: String = ""
    @Published var isLoading: Bool = false
    @Published var bookmarkedArticleIds: Set<String> = []

    var categories: [String] {
        var cats = Set(articles.map { $0.category })
        cats.insert("All")
        return ["All"] + Array(cats.filter { $0 != "All" }).sorted()
    }

    var filteredArticles: [Article] {
        var filtered = articles

        if selectedCategory != "All" {
            filtered = filtered.filter { $0.category == selectedCategory }
        }

        if !searchQuery.isEmpty {
            let query = searchQuery.lowercased()
            filtered = filtered.filter {
                $0.title.lowercased().contains(query) ||
                $0.content.lowercased().contains(query)
            }
        }

        return filtered
    }

    var bookmarkedArticles: [Article] {
        articles.filter { bookmarkedArticleIds.contains($0.id) }
    }

    init() {
        loadArticles()
    }

    // MARK: - Load Articles
    func loadArticles() {
        isLoading = true
        defer { isLoading = false }

        guard let url = Bundle.main.url(forResource: "articles", withExtension: "json", subdirectory: "Data"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Article].self, from: data) else {
            // Load sample articles if no JSON file
            articles = sampleArticles
            return
        }

        articles = decoded
    }

    // MARK: - Bookmarks
    func isBookmarked(_ article: Article) -> Bool {
        bookmarkedArticleIds.contains(article.id)
    }

    func toggleBookmark(_ article: Article) {
        if bookmarkedArticleIds.contains(article.id) {
            bookmarkedArticleIds.remove(article.id)
        } else {
            bookmarkedArticleIds.insert(article.id)
        }
    }

    // MARK: - Sample Data
    private var sampleArticles: [Article] {
        // Create specific dates for articles
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"

        let date1 = dateFormatter.date(from: "01 Jan 2024") ?? Date()
        let date2 = dateFormatter.date(from: "15 Jan 2024") ?? Date()
        let date3 = dateFormatter.date(from: "22 Jan 2024") ?? Date()

        return [
            Article(
                id: "1",
                title: "What is Ruqyah?",
                content: "Ruqyah is an Islamic practice of healing through the recitation of Quran and supplications. It is a means of seeking cure and protection from Allah. The practice involves reciting specific verses from the Quran and authentic duas (supplications) from the Sunnah. It has been practiced since the time of Prophet Muhammad (peace be upon him) and is considered a legitimate form of treatment for spiritual and physical ailments.",
                language: "en",
                category: "Basics",
                publishedDate: date1
            ),
            Article(
                id: "2",
                title: "Benefits of Regular Ruqyah",
                content: "Regular practice of Ruqyah brings numerous spiritual and psychological benefits: strengthening connection with Allah, protection from evil eye and envy, spiritual peace and tranquility, increased faith and reliance on Allah, and mental clarity. The consistent recitation of Quranic verses provides a shield of protection and helps maintain spiritual wellbeing.",
                language: "en",
                category: "Benefits",
                publishedDate: date2
            ),
            Article(
                id: "3",
                title: "How to Perform Self-Ruqyah",
                content: "Self-Ruqyah is the practice of performing spiritual healing on oneself. Start with purification (wudu), find a quiet place, recite Al-Fatihah, Ayatul Kursi, and the last three surahs of the Quran. Blow gently over your hands and wipe them over your body. Maintain sincerity and trust in Allah as the ultimate healer. This can be done regularly for protection and healing.",
                language: "en",
                category: "Basics",
                publishedDate: date3
            ),
            Article(
                id: "4",
                title: "Protection Through Morning Adhkar",
                content: "Morning remembrance (adhkar) provides a shield of protection throughout the day. The Prophet (peace be upon him) encouraged reciting specific supplications after Fajr prayer. These include Ayatul Kursi, the last verses of Surah Al-Baqarah, and various authentic duas. Consistent practice strengthens spiritual immunity and brings peace to the heart.",
                language: "en",
                category: "Benefits",
                publishedDate: Date()
            )
        ]
    }
}
