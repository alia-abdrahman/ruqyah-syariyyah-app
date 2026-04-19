import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    @EnvironmentObject var trackingViewModel: TrackingViewModel
    @Environment(\.colorScheme) private var colorScheme

    @State private var searchText: String = ""
    @State private var showContinueReading: Bool = false
    @State private var showCoffeeBanner: Bool = false

    // Show once per app session
    private static var hasShownCoffeeBanner: Bool = false

    private let columns = [
        GridItem(.flexible(), spacing: AppConstants.spacingMedium),
        GridItem(.flexible(), spacing: AppConstants.spacingMedium)
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Static Header
                GradientHeader(
                    title: "Library",
                    subtitle: "Words of protection and healing",
                    style: .plain,
                    trailingContent: {
                        HStack(spacing: 10) {
                            NavigationLink(destination: FavouritesView()) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.primaryGreen)
                                    .frame(width: 36, height: 36)
                                    .background(Color.primaryGreen.opacity(0.1))
                                    .clipShape(Circle())
                            }

                            NavigationLink(destination: BookmarksView()) {
                                Image(systemName: "bookmark.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.primaryGreen)
                                    .frame(width: 36, height: 36)
                                    .background(Color.primaryGreen.opacity(0.1))
                                    .clipShape(Circle())
                            }
                        }
                    }
                )

                ScrollViewReader { proxy in
                ScrollView {
                VStack(spacing: AppConstants.spacingMedium) {
                    // Buy Me a Coffee Banner
                    if showCoffeeBanner {
                        Link(destination: URL(string: "https://buymeacoffee.com/codedancoffee")!) {
                            HStack(spacing: 10) {
                                Text("☕")
                                    .font(.system(size: 20))

                                Text("If you love this app, buy me a coffee!")
                                    .font(.poppins(13, weight: .medium))
                                    .foregroundColor(.white)
                                    .lineLimit(1)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [Color(red: 0.6, green: 0.4, blue: 0.2), Color(red: 0.45, green: 0.28, blue: 0.12)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(30)
                            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, AppConstants.spacingMedium)
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .opacity
                        ))
                    }

                    // Search Bar
                    SearchBar(text: $searchText, placeholder: "Search verses...")
                        .padding(.horizontal, AppConstants.spacingMedium)

                    // Daily Verse Card
                    if searchText.isEmpty, let verse = contentViewModel.dailyVerse {
                        NavigationLink(destination: VerseDetailView(verse: verse)) {
                            dailyVerseCard(verse: verse)
                        }
                        .buttonStyle(.plain)
                        .bounceOnTap()
                        .padding(.horizontal, AppConstants.spacingMedium)
                    }

                    // Start Healing Journey Card
                    if searchText.isEmpty {
                        healingJourneyCard(proxy: proxy)
                            .padding(.horizontal, AppConstants.spacingMedium)
                    }

                    // Collections Header
                    if searchText.isEmpty {
                        Text("Collections")
                            .font(.poppins(24, weight: .bold))
                            .foregroundColor(.adaptiveText(colorScheme))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, AppConstants.spacingMedium)
                            .padding(.top, AppConstants.spacingSmall)
                            .id("collections")
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
                .padding(.bottom, 80)
            }
            .withScrollButtons()
            }
            }
            .background(Color.adaptiveBackground(colorScheme))
            .ignoresSafeArea(edges: .top)
            .onAppear {
                if !LibraryView.hasShownCoffeeBanner {
                    LibraryView.hasShownCoffeeBanner = true
                    withAnimation(.easeOut(duration: 0.4).delay(1.0)) {
                        showCoffeeBanner = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 9.0) {
                        withAnimation(.easeIn(duration: 0.3)) {
                            showCoffeeBanner = false
                        }
                    }
                }
            }
            .overlay(alignment: .bottom) {
                if let lastRead = contentViewModel.lastReadInfo {
                    Button {
                        showContinueReading = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "book.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.primaryGreen)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Continue Reading")
                                    .font(.poppins(11, weight: .regular))
                                    .foregroundColor(.primaryGreen.opacity(0.7))
                                Text(lastRead.groupDisplayName ?? lastRead.collectionName ?? "")
                                    .font(.poppins(14, weight: .semibold))
                                    .foregroundColor(.primaryGreen)
                                    .lineLimit(1)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.primaryGreen.opacity(0.5))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color.adaptiveSurface(colorScheme))
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.primaryGreen.opacity(0.3), lineWidth: 1.5)
                        )
                        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
                    }
                    .padding(.leading, 20)
                    .padding(.trailing, 62)
                    .padding(.bottom, 8)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .fullScreenCover(isPresented: $showContinueReading) {
                if let lastRead = contentViewModel.lastReadInfo,
                   let groupName = lastRead.groupName {
                    if lastRead.mode == "collection",
                       let collection = contentViewModel.collections.first(where: { $0.id == lastRead.collectionId }) {
                        CollectionMushafView(collection: collection)
                    } else {
                        let verses = contentViewModel.getVersesForGroup(lastRead.collectionId, groupName: groupName)
                        MushafView(verses: verses)
                    }
                }
            }
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

    // MARK: - Healing Journey Card
    private func healingJourneyCard(proxy: ScrollViewProxy) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text(timeBasedGreeting)
                    .font(.poppins(17, weight: .bold))
                    .foregroundColor(.adaptiveText(colorScheme))

                Text("Begin your spiritual healing with the words of the Quran.")
                    .font(.poppins(13, weight: .regular))
                    .foregroundColor(.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.5)) {
                    proxy.scrollTo("collections", anchor: .top)
                }
            } label: {
                Text("Start Session")
                    .font(.poppins(13, weight: .semibold))
                    .foregroundColor(.adaptiveText(colorScheme))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.adaptiveText(colorScheme).opacity(0.3), lineWidth: 1.5)
                    )
            }
        }
        .padding(AppConstants.spacingMedium)
        .background(Color.adaptiveMint(colorScheme))
        .cornerRadius(AppConstants.radiusLarge)
    }

    // MARK: - Daily Verse Card
    private func dailyVerseCard(verse: RuqyahVerse) -> some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .medium))
                    Text("Verse of the Day")
                        .font(.poppins(14, weight: .semibold))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.white)

            // Arabic text preview
            Text(verse.arabicText)
                .font(.amiriQuran(26))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)

            // Translation preview
            Text(verse.translation(for: contentViewModel.language))
                .font(.poppins(13, weight: .regular))
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(3)
                .multilineTextAlignment(.center)

            // Reference
            if let reference = verse.reference {
                Text(reference)
                    .font(.poppins(12, weight: .medium))
                    .foregroundColor(.white.opacity(0.65))
            }
        }
        .padding(20)
        .background(Color.verseCardGradient)
        .cornerRadius(20)
    }

    // MARK: - Continue Reading Card
    private func continueReadingCard(lastRead: ContentViewModel.LastReadInfo) -> some View {
        HStack(spacing: 14) {
            // Book icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.primaryGreen.opacity(0.1))
                    .frame(width: 50, height: 50)

                Image(systemName: "book.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.primaryGreen)
            }

            // Text
            VStack(alignment: .leading, spacing: 3) {
                Text("Continue Reading")
                    .font(.poppins(11, weight: .medium))
                    .foregroundColor(.primaryGreen)

                Text(lastRead.groupDisplayName ?? lastRead.collectionName)
                    .font(.poppins(15, weight: .semibold))
                    .foregroundColor(.adaptiveText(colorScheme))
                    .lineLimit(1)

                Text(relativeTime(from: lastRead.date))
                    .font(.poppins(11, weight: .regular))
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primaryGreen.opacity(0.6))
        }
        .padding(AppConstants.spacingMedium)
        .background(Color.adaptiveSurface(colorScheme))
        .cornerRadius(AppConstants.radiusLarge)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.radiusLarge)
                .stroke(Color.primaryGreen.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 5, x: 0, y: 3)
    }

    private func relativeTime(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)

        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) min ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return days == 1 ? "Yesterday" : "\(days) days ago"
        }
    }

    // MARK: - Collections Grid
    private var collectionsGrid: some View {
        LazyVGrid(columns: columns, spacing: AppConstants.spacingMedium) {
            ForEach(contentViewModel.collections) { collection in
                NavigationLink(destination: CollectionDetailView(collection: collection)) {
                    CollectionCard(collection: collection)
                }
                .buttonStyle(.plain)
                .bounceOnTap()
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
                            .bounceOnTap()
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
                            .bounceOnTap()
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
                            .bounceOnTap()
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
