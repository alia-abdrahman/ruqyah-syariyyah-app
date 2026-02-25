import SwiftUI
import SwiftData

struct MainTabView: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    @EnvironmentObject var trackingViewModel: TrackingViewModel
    @EnvironmentObject var audioPlayerViewModel: AudioPlayerViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.modelContext) private var modelContext

    @State private var selectedTab: Tab = .library
    @State private var showWelcome: Bool = false

    enum Tab: String, CaseIterable {
        case library = "Library"
        case tracking = "Tracking"
        case articles = "Articles"

        var icon: String {
            switch self {
            case .library: return "text.book.closed.fill"
            case .tracking: return "calendar"
            case .articles: return "doc.text.fill"
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                LibraryView()
                    .tag(Tab.library)
                    .tabItem {
                        Label(Tab.library.rawValue, systemImage: Tab.library.icon)
                    }

                TrackingView()
                    .tag(Tab.tracking)
                    .tabItem {
                        Label(Tab.tracking.rawValue, systemImage: Tab.tracking.icon)
                    }

                ArticlesView()
                    .tag(Tab.articles)
                    .tabItem {
                        Label(Tab.articles.rawValue, systemImage: Tab.articles.icon)
                    }
            }
            .tint(.primaryGreen)

            // Mini Player
            if audioPlayerViewModel.showMiniPlayer {
                MiniPlayerView()
                    .padding(.bottom, 50) // Above tab bar
            }
        }
        .onAppear {
            setupViewModels()
            checkFirstRun()
        }
        .fullScreenCover(isPresented: $showWelcome) {
            WelcomeView(isPresented: $showWelcome)
        }
    }

    private func setupViewModels() {
        contentViewModel.setModelContext(modelContext)
        trackingViewModel.setModelContext(modelContext)

        Task {
            await contentViewModel.loadContent()
        }
    }

    private func checkFirstRun() {
        if StorageService.shared.isFirstRun {
            showWelcome = true
            StorageService.shared.isFirstRun = false
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(ContentViewModel())
        .environmentObject(TrackingViewModel())
        .environmentObject(AudioPlayerViewModel())
        .environmentObject(SettingsViewModel())
        .modelContainer(for: [FavoriteVerse.self, SessionRecord.self])
}
