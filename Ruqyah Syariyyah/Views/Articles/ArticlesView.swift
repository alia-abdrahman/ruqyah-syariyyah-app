import SwiftUI

struct ArticlesView: View {
    @StateObject private var viewModel = ArticlesViewModel()
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    GradientHeader(
                        title: "Articles",
                        subtitle: "Learn about spiritual healing"
                    ) {
                        SearchBar(text: $viewModel.searchQuery, placeholder: "Search articles...")
                            .padding(.top, 8)
                    }
                    .frame(height: 200)

                    VStack(spacing: AppConstants.spacingMedium) {
                        // Category Filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppConstants.spacingSmall) {
                                ForEach(viewModel.categories, id: \.self) { category in
                                    Button {
                                        viewModel.selectedCategory = category
                                    } label: {
                                        Text(category)
                                            .font(.bodySmall)
                                            .foregroundColor(viewModel.selectedCategory == category ? .white : .textSecondary)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(viewModel.selectedCategory == category ? Color.primaryGreen : Color.adaptiveSurface(colorScheme))
                                            .cornerRadius(AppConstants.radiusSmall)
                                    }
                                }
                            }
                            .padding(.horizontal, AppConstants.spacingMedium)
                        }

                        // Articles List
                        if viewModel.filteredArticles.isEmpty {
                            ContentUnavailableView(
                                "No Articles",
                                systemImage: "doc.text",
                                description: Text("Check back later for new content")
                            )
                            .frame(height: 200)
                        } else {
                            LazyVStack(spacing: AppConstants.spacingMedium) {
                                ForEach(viewModel.filteredArticles) { article in
                                    NavigationLink(destination: ArticleDetailView(article: article, viewModel: viewModel)) {
                                        ArticleCard(article: article, isBookmarked: viewModel.isBookmarked(article))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, AppConstants.spacingMedium)
                        }
                    }
                    .padding(.top, AppConstants.spacingMedium)
                    .padding(.bottom, AppConstants.spacingXLarge)
                }
            }
            .background(Color.adaptiveBackground(colorScheme))
            .ignoresSafeArea(edges: .top)
        }
    }
}

// MARK: - Article Card
struct ArticleCard: View {
    let article: Article
    let isBookmarked: Bool

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.spacingSmall) {
            HStack {
                Text(article.category)
                    .font(.caption)
                    .foregroundColor(.primaryGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.primaryGreen.opacity(0.1))
                    .cornerRadius(4)

                Spacer()

                if isBookmarked {
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(.accentGold)
                }
            }

            Text(article.title)
                .font(.headingSmall)
                .foregroundColor(.adaptiveText(colorScheme))
                .lineLimit(2)

            Text(article.content)
                .font(.bodySmall)
                .foregroundColor(.textSecondary)
                .lineLimit(3)

            if let date = article.formattedDate {
                Text(date)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .padding(.top, 4)
            }
        }
        .padding(AppConstants.spacingMedium)
        .background(Color.adaptiveSurface(colorScheme))
        .cornerRadius(AppConstants.radiusLarge)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    ArticlesView()
}
