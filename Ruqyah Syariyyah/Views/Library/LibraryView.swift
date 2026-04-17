import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    @EnvironmentObject var trackingViewModel: TrackingViewModel
    @Environment(\.colorScheme) private var colorScheme

    @State private var searchText: String = ""
    @State private var bouncingCardId: String?

    private let columns = [
        GridItem(.flexible(), spacing: AppConstants.spacingMedium),
        GridItem(.flexible(), spacing: AppConstants.spacingMedium)
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Static Header with Favourites Button
                GradientHeader(
                    title: "Library",
                    subtitle: timeBasedGreeting,
                    trailingContent: {
                        NavigationLink(destination: FavouritesView()) {
                            HStack(spacing: 6) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 14, weight: .medium))
                                Text("Favourites")
                                    .font(.poppins(13, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(20)
                        }
                    }
                )

                // Scrollable Content
                ScrollView {
                    VStack(spacing: AppConstants.spacingMedium) {
                        // Search Bar
                        SearchBar(text: $searchText, placeholder: "Search verses...")
                            .padding(.horizontal, AppConstants.spacingMedium)

                        // Welcome Banner
                        welcomeBanner
                            .padding(.horizontal, AppConstants.spacingMedium)

                        // Collections Header
                        if searchText.isEmpty {
                            Text("Collections")
                                .font(.headingSmall)
                                .foregroundColor(.adaptiveText(colorScheme))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, AppConstants.spacingMedium)
                        }

                        if contentViewModel.isLoading {
                            ProgressView()
                                .frame(height: 200)
                        } else if !searchText.isEmpty {
                            searchResultsSection
                        } else {
                            collectionsGrid
                        }
                    }
                    .padding(.top, AppConstants.spacingMedium)
                }
            }
            .background(Color.adaptiveBackground(colorScheme))
            .ignoresSafeArea(edges: .top)
        }
    }

    // MARK: - Time-Based Greeting
    private var timeBasedGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 3..<12:
            return "Assalamualaikum, good morning"
        case 12..<15:
            return "Assalamualaikum, good afternoon"
        case 15..<18:
            return "Assalamualaikum, good evening"
        case 18..<21:
            return "Assalamualaikum, have a blessed evening"
        default:
            return "Assalamualaikum, peace be upon you"
        }
    }

    // MARK: - Contextual Welcome Banner
    private var welcomeBannerContent: (message: String, icon: String) {
        let streak = trackingViewModel.currentStreak
        let totalSessions = trackingViewModel.totalSessions

        if totalSessions == 0 {
            return (
                "Begin your spiritual healing journey with the holy verses of the Quran. Start your first session today.",
                "sparkles"
            )
        } else if streak >= 7 {
            return (
                "MashaAllah! \(streak) days of consistency. Your dedication to spiritual healing is truly inspiring.",
                "star.fill"
            )
        } else if streak >= 3 {
            return (
                "Alhamdulillah, \(streak) days in a row! Keep up your beautiful practice of spiritual healing.",
                "flame.fill"
            )
        } else if streak >= 1 {
            return (
                "Welcome back! You practised today. Every recitation brings you closer to healing and peace.",
                "heart.fill"
            )
        } else {
            return (
                "Your healing journey continues. Pick up where you left off — every verse recited counts.",
                "arrow.counterclockwise"
            )
        }
    }

    private var welcomeBanner: some View {
        let content = welcomeBannerContent

        return HStack(spacing: 16) {
            Text(content.message)
                .font(.poppins(16, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 70, height: 70)

                Image(systemName: content.icon)
                    .font(.system(size: 28, weight: .regular))
                    .foregroundColor(.white)
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color.primaryGreen, Color.primaryGreenDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }

    // MARK: - Collections Grid
    private var collectionsGrid: some View {
        LazyVGrid(columns: columns, spacing: AppConstants.spacingMedium) {
            ForEach(contentViewModel.collections) { collection in
                NavigationLink(destination: CollectionDetailView(collection: collection)) {
                    CollectionCard(collection: collection)
                        .scaleEffect(bouncingCardId == collection.id ? 0.88 : 1.0)
                        .animation(.interpolatingSpring(stiffness: 600, damping: 10), value: bouncingCardId)
                }
                .buttonStyle(.plain)
                .simultaneousGesture(
                    TapGesture()
                        .onEnded {
                            bouncingCardId = collection.id
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                bouncingCardId = nil
                            }
                        }
                )
            }
        }
        .padding(.horizontal, AppConstants.spacingMedium)
        .padding(.bottom, AppConstants.spacingXLarge)
    }

    // MARK: - Search Results
    private var searchResultsSection: some View {
        let results = contentViewModel.searchAll(searchText)

        return VStack(alignment: .leading, spacing: AppConstants.spacingMedium) {
            Text("\(results.totalCount) results")
                .font(.bodySmall)
                .foregroundColor(.textSecondary)
                .padding(.horizontal, AppConstants.spacingMedium)

            if results.isEmpty {
                ContentUnavailableView(
                    "No Results",
                    systemImage: "magnifyingglass",
                    description: Text("Try a different search term")
                )
                .frame(height: 200)
            } else {
                LazyVStack(spacing: AppConstants.spacingMedium) {
                    // Collections Results
                    if !results.collections.isEmpty {
                        Text("Collections")
                            .font(.poppins(14, weight: .semibold))
                            .foregroundColor(.textSecondary)
                            .padding(.horizontal, AppConstants.spacingMedium)

                        ForEach(results.collections) { collection in
                            NavigationLink(destination: CollectionDetailView(collection: collection)) {
                                SearchCollectionRow(collection: collection)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Groups/Surahs Results
                    if !results.groups.isEmpty {
                        Text("Surahs")
                            .font(.poppins(14, weight: .semibold))
                            .foregroundColor(.textSecondary)
                            .padding(.horizontal, AppConstants.spacingMedium)
                            .padding(.top, results.collections.isEmpty ? 0 : AppConstants.spacingSmall)

                        ForEach(results.groups, id: \.group.id) { item in
                            NavigationLink(destination: GroupDetailView(group: item.group)) {
                                SearchGroupRow(group: item.group, collectionName: item.collection.name)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Verses Results
                    if !results.verses.isEmpty {
                        Text("Verses")
                            .font(.poppins(14, weight: .semibold))
                            .foregroundColor(.textSecondary)
                            .padding(.horizontal, AppConstants.spacingMedium)
                            .padding(.top, (results.collections.isEmpty && results.groups.isEmpty) ? 0 : AppConstants.spacingSmall)

                        ForEach(results.verses) { verse in
                            NavigationLink(destination: VerseDetailView(verse: verse)) {
                                CompactVerseCard(
                                    verse: verse,
                                    isFavorite: contentViewModel.isFavorite(verse)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, AppConstants.spacingMedium)
            }
        }
        .padding(.bottom, AppConstants.spacingXLarge)
    }

}

// MARK: - Search Collection Row
struct SearchCollectionRow: View {
    let collection: Collection
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: AppConstants.spacingMedium) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.primaryGreen.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: collection.sfSymbol)
                    .font(.system(size: 18))
                    .foregroundColor(.primaryGreen)
            }

            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(collection.name)
                    .font(.poppins(15, weight: .semibold))
                    .foregroundColor(.adaptiveText(colorScheme))

                HStack(spacing: AppConstants.spacingSmall) {
                    Label("\(collection.groupCount) groups", systemImage: "folder")
                    Label("\(collection.totalVerseCount) verses", systemImage: "text.quote")
                }
                .font(.poppins(12, weight: .regular))
                .foregroundColor(.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(AppConstants.spacingMedium)
        .background(Color.adaptiveSurface(colorScheme))
        .cornerRadius(AppConstants.radiusMedium)
    }
}

// MARK: - Search Group Row
struct SearchGroupRow: View {
    let group: VerseGroup
    let collectionName: String
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: AppConstants.spacingMedium) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.primaryGreen)
                    .frame(width: 44, height: 44)

                Image(systemName: "book.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
            }

            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(group.name)
                    .font(.poppins(15, weight: .semibold))
                    .foregroundColor(.adaptiveText(colorScheme))

                Text("\(collectionName) • \(group.verseCount) verses")
                    .font(.poppins(12, weight: .regular))
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            // Arabic preview
            if let preview = group.arabicPreview {
                Text(preview)
                    .font(.amiriQuran(14))
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
                    .frame(maxWidth: 80, alignment: .trailing)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(AppConstants.spacingMedium)
        .background(Color.adaptiveSurface(colorScheme))
        .cornerRadius(AppConstants.radiusMedium)
    }
}

#Preview {
    LibraryView()
        .environmentObject(ContentViewModel())
        .environmentObject(TrackingViewModel())
        .environmentObject(SettingsViewModel())
        .environmentObject(AudioPlayerViewModel())
}
