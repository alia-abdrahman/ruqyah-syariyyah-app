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
        [
            Article(
                id: "1",
                title: "Understanding Ruqyah Syar'iyyah",
                content: """
                Ruqyah Syar'iyyah is the Islamic practice of spiritual healing through recitation of Quranic verses and authentic supplications from the Sunnah.

                The word 'Ruqyah' comes from the Arabic root that means to recite protective words or prayers. It has been practiced since the time of the Prophet Muhammad (peace be upon him) and is considered a form of treatment for spiritual ailments.

                Key principles of authentic Ruqyah:
                1. Must be from the Quran or authentic supplications
                2. Must be in Arabic or understood by the practitioner
                3. Must be believed to be a means of cure, not the cure itself
                4. Must not contain any shirk (associating partners with Allah)

                The Prophet (peace be upon him) encouraged the use of Ruqyah and practiced it himself.
                """,
                language: "en",
                category: "Education",
                publishedDate: Date()
            ),
            Article(
                id: "2",
                title: "Benefits of Daily Adhkar",
                content: """
                Daily remembrance of Allah (Adhkar) provides protection and spiritual benefits for the believer.

                Morning and evening adhkar are particularly important as they provide a shield of protection throughout the day and night.

                Some key benefits include:
                - Protection from evil eye and envy
                - Spiritual peace and tranquility
                - Strengthening of faith
                - Connection with Allah

                The Prophet (peace be upon him) was consistent in his daily adhkar and encouraged his companions to be likewise.
                """,
                language: "en",
                category: "Practice",
                publishedDate: Date().addingTimeInterval(-86400)
            ),
            Article(
                id: "3",
                title: "The Power of Surah Al-Fatihah",
                content: """
                Surah Al-Fatihah is known as the greatest surah in the Quran and is also called 'The Healer' (Ash-Shifa).

                The Prophet (peace be upon him) said: "By Him in whose hand my soul is, nothing like it has been revealed in the Torah, the Gospel, the Psalms, or the Quran."

                This surah is particularly powerful for Ruqyah because:
                - It praises Allah and acknowledges His sovereignty
                - It asks for guidance to the straight path
                - It was used by the companions for healing

                Reciting Al-Fatihah regularly provides spiritual protection and healing.
                """,
                language: "en",
                category: "Quran",
                publishedDate: Date().addingTimeInterval(-172800)
            )
        ]
    }
}
