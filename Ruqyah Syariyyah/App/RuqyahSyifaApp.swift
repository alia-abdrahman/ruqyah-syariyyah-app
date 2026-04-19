import SwiftUI
import SwiftData

@main
struct RuqyahSyifaApp: App {
    @StateObject private var contentViewModel = ContentViewModel()
    @StateObject private var trackingViewModel = TrackingViewModel()
    @StateObject private var audioPlayerViewModel = AudioPlayerViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            FavoriteVerse.self,
            SessionRecord.self,
            ReadingBookmark.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @State private var showSplash: Bool = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()
                    .environmentObject(contentViewModel)
                    .environmentObject(trackingViewModel)
                    .environmentObject(audioPlayerViewModel)
                    .environmentObject(settingsViewModel)
                    .preferredColorScheme(settingsViewModel.colorScheme)

                if showSplash {
                    SplashView(isActive: $showSplash)
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
