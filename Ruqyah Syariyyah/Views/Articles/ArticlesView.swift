import SwiftUI

struct ArticlesView: View {
    @StateObject private var viewModel = ArticlesViewModel()
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Static Header
                GradientHeader(
                    title: "Articles",
                    subtitle: "Learn and expand your knowledge"
                )

                // Scrollable Content
                ScrollView {
                    VStack(alignment: .leading, spacing: AppConstants.spacingMedium) {
                        // Category Filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppConstants.spacingSmall) {
                                ForEach(viewModel.categories, id: \.self) { category in
                                    Button {
                                        viewModel.selectedCategory = category
                                    } label: {
                                        Text(category)
                                            .font(.poppins(14, weight: .medium))
                                            .foregroundColor(viewModel.selectedCategory == category ? .white : .textSecondary)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(viewModel.selectedCategory == category ? Color.primaryGreen : Color.clear)
                                            .cornerRadius(20)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(viewModel.selectedCategory == category ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, AppConstants.spacingMedium)
                        }
                        .padding(.top, AppConstants.spacingMedium)

                        // Latest Articles Title
                        Text("Latest Articles")
                            .font(.headingSmall)
                            .foregroundColor(.adaptiveText(colorScheme))
                            .padding(.horizontal, AppConstants.spacingMedium)
                            .padding(.top, AppConstants.spacingSmall)

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
                                        ArticleCard(
                                            article: article,
                                            isBookmarked: viewModel.isBookmarked(article),
                                            onBookmarkTap: {
                                                viewModel.toggleBookmark(article)
                                            }
                                        )
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
    var onBookmarkTap: (() -> Void)? = nil

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: AppConstants.spacingMedium) {
                // Document Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.primaryGreen.opacity(0.15))
                        .frame(width: 50, height: 50)

                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.primaryGreen)
                }

                VStack(alignment: .leading, spacing: 4) {
                    // Title
                    Text(article.title)
                        .font(.poppins(17, weight: .semibold))
                        .foregroundColor(.adaptiveText(colorScheme))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    // Category and Date
                    HStack(spacing: 8) {
                        Text(article.category)
                            .font(.poppins(12, weight: .medium))
                            .foregroundColor(.primaryGreen)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.primaryGreen.opacity(0.1))
                            .cornerRadius(4)

                        if let date = article.formattedDate {
                            Text(date)
                                .font(.poppins(12, weight: .regular))
                                .foregroundColor(.textSecondary)
                        }
                    }
                }

                Spacer()

                // Bookmark Button
                Button {
                    onBookmarkTap?()
                } label: {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 20))
                        .foregroundColor(isBookmarked ? .primaryGreen : .gray.opacity(0.4))
                }
            }

            // Description
            Text(article.content)
                .font(.poppins(14, weight: .regular))
                .foregroundColor(.textSecondary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .padding(.top, 12)

            // Read More
            HStack {
                Spacer()
                HStack(spacing: 4) {
                    Text("Read more")
                        .font(.poppins(14, weight: .medium))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.primaryGreen)
            }
            .padding(.top, 12)
        }
        .padding(AppConstants.spacingMedium)
        .background(Color.adaptiveSurface(colorScheme))
        .cornerRadius(AppConstants.radiusLarge)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.radiusLarge)
                .stroke(Color.primaryGreen.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    ArticlesView()
}
