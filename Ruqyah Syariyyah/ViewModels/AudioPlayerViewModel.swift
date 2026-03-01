import Foundation
import SwiftUI
import Combine

@MainActor
class AudioPlayerViewModel: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var currentVerse: RuqyahVerse?
    @Published var playbackSpeed: Float = 1.0
    @Published var showMiniPlayer: Bool = false
    @Published var isLoading: Bool = false
    @Published var error: String?

    private let audioService = AudioService.shared
    private let quranAudioService = QuranAudioService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupBindings()
        setupPlaybackEndedObserver()
    }

    private func setupBindings() {
        audioService.$isPlaying
            .receive(on: DispatchQueue.main)
            .assign(to: &$isPlaying)

        audioService.$currentTime
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentTime)

        audioService.$duration
            .receive(on: DispatchQueue.main)
            .assign(to: &$duration)

        audioService.$playbackSpeed
            .receive(on: DispatchQueue.main)
            .assign(to: &$playbackSpeed)

        audioService.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoading)

        audioService.$error
            .receive(on: DispatchQueue.main)
            .assign(to: &$error)
    }

    private func setupPlaybackEndedObserver() {
        NotificationCenter.default.addObserver(
            forName: .audioPlaybackEnded,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handlePlaybackEnded()
            }
        }
    }

    private func handlePlaybackEnded() {
        // Auto-play next verse only if autoPlayNext is enabled (e.g., Play All mode)
        if autoPlayNext && hasNext {
            playNext()
        } else {
            // Stop and hide mini player when single verse finishes
            showMiniPlayer = false
            currentVerse = nil
        }
    }

    // MARK: - Playback Controls
    func playVerse(_ verse: RuqyahVerse) {
        isLoading = true
        currentVerse = verse
        showMiniPlayer = true
        error = nil

        Task {
            do {
                // Try to fetch audio from Quran.com API using the reference
                if let reference = verse.reference {
                    let audioURL = try await quranAudioService.fetchAudioURL(reference: reference)
                    audioService.playRemote(url: audioURL, trackId: verse.uniqueKey)
                } else {
                    // Fallback to local audio if available
                    if let audioPath = verse.audioPath {
                        let fileName = URL(string: audioPath)?.lastPathComponent ?? audioPath
                        audioService.play(named: fileName, trackId: verse.uniqueKey)
                    } else {
                        error = "No audio available for this verse"
                        isLoading = false
                    }
                }
            } catch {
                // Fallback to local audio on API error
                if let audioPath = verse.audioPath {
                    let fileName = URL(string: audioPath)?.lastPathComponent ?? audioPath
                    audioService.play(named: fileName, trackId: verse.uniqueKey)
                } else {
                    self.error = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }

    func togglePlayPause() {
        audioService.togglePlayPause()
    }

    func pause() {
        audioService.pause()
    }

    func resume() {
        audioService.resume()
    }

    func stop() {
        audioService.stop()
        currentVerse = nil
        showMiniPlayer = false
    }

    func seek(to time: Double) {
        audioService.seek(to: time)
    }

    func seekForward() {
        audioService.seekForward(seconds: 10)
    }

    func seekBackward() {
        audioService.seekBackward(seconds: 10)
    }

    func setPlaybackSpeed(_ speed: Float) {
        audioService.setPlaybackSpeed(speed)
    }

    // MARK: - Playlist Support
    var verses: [RuqyahVerse] = []
    var currentIndex: Int = 0
    var autoPlayNext: Bool = false

    func setPlaylist(_ verses: [RuqyahVerse], startIndex: Int = 0, autoPlay: Bool = false) {
        self.verses = verses
        self.currentIndex = startIndex
        self.autoPlayNext = autoPlay
    }

    /// Play a single verse without auto-advancing to next
    func playSingleVerse(_ verse: RuqyahVerse) {
        autoPlayNext = false
        verses = []
        currentIndex = 0
        playVerse(verse)
    }

    func playNext() {
        guard !verses.isEmpty else { return }
        if currentIndex < verses.count - 1 {
            currentIndex += 1
            playVerse(verses[currentIndex])
        }
    }

    func playPrevious() {
        guard !verses.isEmpty else { return }
        if currentIndex > 0 {
            currentIndex -= 1
            playVerse(verses[currentIndex])
        }
    }

    var hasNext: Bool {
        !verses.isEmpty && currentIndex < verses.count - 1
    }

    var hasPrevious: Bool {
        !verses.isEmpty && currentIndex > 0
    }

    // MARK: - Formatting
    var currentTimeFormatted: String {
        audioService.currentTimeFormatted
    }

    var durationFormatted: String {
        audioService.durationFormatted
    }

    var remainingTimeFormatted: String {
        audioService.remainingTimeFormatted
    }

    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }
}
