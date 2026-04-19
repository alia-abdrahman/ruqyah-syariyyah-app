import SwiftUI

struct BookmarksView: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var selectedBookmark: ReadingBookmark?

    var bookmarks: [ReadingBookmark] {
        contentViewModel.allBookmarks
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            GradientHeader(
                title: "Bookmarks",
                subtitle: "\(bookmarks.count) saved",
                showBackButton: true
            )

            // Content
            ScrollView {
                if bookmarks.isEmpty {
                    emptyState
                } else {
                    LazyVStack(spacing: AppConstants.spacingMedium) {
                        Color.clear.frame(height: 1).id("scrollTop")

                        ForEach(bookmarks, id: \.bookmarkKey) { bookmark in
                            Button {
                                selectedBookmark = bookmark
                            } label: {
                                bookmarkRow(bookmark)
                            }
                            .buttonStyle(.plain)
                            .bounceOnTap()
                            .contextMenu {
                                Button(role: .destructive) {
                                    Task {
                                        await contentViewModel.deleteBookmark(bookmark)
                                    }
                                } label: {
                                    Label("Remove Bookmark", systemImage: "bookmark.slash")
                                }
                            }
                        }

                        // End of list
                        VStack(spacing: 6) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 18))
                                .foregroundColor(.textSecondary.opacity(0.4))
                            Text("You've reached the end")
                                .font(.poppins(12, weight: .regular))
                                .foregroundColor(.textSecondary.opacity(0.4))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, AppConstants.spacingMedium)
                        .padding(.bottom, 80)
                        .id("scrollBottom")
                    }
                    .padding(.horizontal, AppConstants.spacingMedium)
                    .padding(.top, 32)
                    .padding(.bottom, AppConstants.spacingXLarge)
                }
            }
            .withScrollButtons()
        }
        .background(Color.adaptiveBackground(colorScheme))
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .fontWeight(.semibold)
                        Text("Back")
                            .font(.poppins(16, weight: .regular))
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .fullScreenCover(item: $selectedBookmark) { bookmark in
            let verses = contentViewModel.getVersesForGroup(bookmark.collectionId, groupName: bookmark.groupName)
            MushafView(verses: verses)
        }
    }

    // MARK: - Bookmark Row
    private func bookmarkRow(_ bookmark: ReadingBookmark) -> some View {
        HStack(spacing: AppConstants.spacingMedium) {
            // Bookmark icon
            ZStack {
                Circle()
                    .fill(Color.primaryGreen)
                    .frame(width: 44, height: 44)

                Image(systemName: "bookmark.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
            }

            // Name and collection
            VStack(alignment: .leading, spacing: 2) {
                Text(bookmark.groupDisplayName)
                    .font(.poppins(16, weight: .semibold))
                    .foregroundColor(.adaptiveText(colorScheme))
                    .lineLimit(1)

                Text(bookmark.collectionName)
                    .font(.poppins(13, weight: .regular))
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
            }
            .layoutPriority(1)

            Spacer()

            // Date
            Text(formattedDate(bookmark.dateBookmarked))
                .font(.poppins(11, weight: .regular))
                .foregroundColor(.textSecondary)

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(AppConstants.spacingMedium)
        .background(Color.adaptiveSurface(colorScheme))
        .cornerRadius(AppConstants.radiusLarge)
        .shadow(color: .black.opacity(0.06), radius: 5, x: 0, y: 3)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: AppConstants.spacingMedium) {
            Spacer()
                .frame(height: 60)

            ZStack {
                Circle()
                    .fill(Color.primaryGreen.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "bookmark")
                    .font(.system(size: 40))
                    .foregroundColor(.primaryGreen)
            }

            Text("No Bookmarks Yet")
                .font(.poppins(20, weight: .semibold))
                .foregroundColor(.adaptiveText(colorScheme))

            Text("Tap the bookmark icon while reading\nto save your place")
                .font(.poppins(14, weight: .regular))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, AppConstants.spacingLarge)
    }

    // MARK: - Helpers
    private func formattedDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    NavigationStack {
        BookmarksView()
    }
    .environmentObject(ContentViewModel())
    .environmentObject(SettingsViewModel())
}
