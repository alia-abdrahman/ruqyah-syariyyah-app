import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    @ObservedObject var viewModel: ArticlesViewModel

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppConstants.spacingLarge) {
                // Header
                VStack(alignment: .leading, spacing: AppConstants.spacingSmall) {
                    HStack {
                        Text(article.category)
                            .font(.bodySmall)
                            .foregroundColor(.primaryGreen)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.primaryGreen.opacity(0.1))
                            .cornerRadius(AppConstants.radiusSmall)

                        Spacer()

                        Button {
                            viewModel.toggleBookmark(article)
                        } label: {
                            Image(systemName: viewModel.isBookmarked(article) ? "bookmark.fill" : "bookmark")
                                .font(.title3)
                                .foregroundColor(viewModel.isBookmarked(article) ? .accentGold : .textSecondary)
                        }
                    }

                    Text(article.title)
                        .font(.headingMedium)
                        .foregroundColor(.adaptiveText(colorScheme))

                    if let date = article.formattedDate {
                        Text(date)
                            .font(.bodySmall)
                            .foregroundColor(.textSecondary)
                    }
                }

                Divider()

                // Content
                Text(article.content)
                    .font(.bodyLarge)
                    .foregroundColor(.adaptiveText(colorScheme))
                    .lineSpacing(8)
            }
            .padding(AppConstants.spacingLarge)
        }
        .background(Color.adaptiveBackground(colorScheme))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    shareArticle()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }

    private func shareArticle() {
        let text = """
        \(article.title)

        \(article.content)

        - Ruqyah Syar'iyyah App
        """

        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

#Preview {
    NavigationStack {
        ArticleDetailView(
            article: Article(
                title: "Understanding Ruqyah",
                content: "Sample content here...",
                category: "Education"
            ),
            viewModel: ArticlesViewModel()
        )
    }
}
