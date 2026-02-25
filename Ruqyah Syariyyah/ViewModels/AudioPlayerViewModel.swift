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

    private let audioService = AudioService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupBindings()
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
    }

    // MARK: - Playback Controls
    func playVerse(_ verse: RuqyahVerse) {
        guard let audioPath = verse.audioPath else { return }

        isLoading = true
        currentVerse = verse
        showMiniPlayer = true

        // Convert Flutter asset path to actual file name
        let fileName = URL(string: audioPath)?.lastPathComponent ?? audioPath
        audioService.play(named: fileName, trackId: verse.uniqueKey)
        isLoading = false
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

    func setPlaylist(_ verses: [RuqyahVerse], startIndex: Int = 0) {
        self.verses = verses
        self.currentIndex = startIndex
    }

    func playNext() {
        guard !verses.isEmpty else { return }
        currentIndex = (currentIndex + 1) % verses.count
        playVerse(verses[currentIndex])
    }

    func playPrevious() {
        guard !verses.isEmpty else { return }
        currentIndex = currentIndex > 0 ? currentIndex - 1 : verses.count - 1
        playVerse(verses[currentIndex])
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
