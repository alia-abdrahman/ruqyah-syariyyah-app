import Foundation
import AVFoundation
import Combine

@MainActor
class AudioService: ObservableObject {
    static let shared = AudioService()

    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?
    private var statusObserver: NSKeyValueObservation?
    private var durationObserver: NSKeyValueObservation?

    @Published var isPlaying: Bool = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var currentTrackId: String?
    @Published var playbackSpeed: Float = 1.0
    @Published var isLoading: Bool = false
    @Published var error: String?

    private init() {
        setupAudioSession()
        setupNotifications()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handlePlaybackEnded()
            }
        }
    }

    // MARK: - Play from Remote URL (Streaming)
    func playRemote(url: URL, trackId: String) {
        stop()
        isLoading = true
        error = nil

        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        player?.rate = playbackSpeed

        currentTrackId = trackId

        // Observe player item status
        statusObserver = playerItem?.observe(\.status, options: [.new]) { [weak self] item, _ in
            Task { @MainActor in
                self?.handleStatusChange(item.status)
            }
        }

        // Observe duration
        durationObserver = playerItem?.observe(\.duration, options: [.new]) { [weak self] item, _ in
            Task { @MainActor in
                let seconds = CMTimeGetSeconds(item.duration)
                if !seconds.isNaN && seconds.isFinite {
                    self?.duration = seconds
                }
            }
        }

        setupTimeObserver()
    }

    private func handleStatusChange(_ status: AVPlayerItem.Status) {
        switch status {
        case .readyToPlay:
            isLoading = false
            player?.play()
            isPlaying = true
        case .failed:
            isLoading = false
            isPlaying = false
            error = playerItem?.error?.localizedDescription ?? "Failed to load audio"
        case .unknown:
            break
        @unknown default:
            break
        }
    }

    private func handlePlaybackEnded() {
        isPlaying = false
        currentTime = 0
        player?.seek(to: .zero)

        // Post notification for playlist handling
        NotificationCenter.default.post(name: .audioPlaybackEnded, object: nil)
    }

    // MARK: - Play from Local File
    func play(url: URL, trackId: String) {
        playRemote(url: url, trackId: trackId)
    }

    func play(named fileName: String, trackId: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            print("Audio file not found: \(fileName)")
            return
        }
        playRemote(url: url, trackId: trackId)
    }

    // MARK: - Playback Controls
    func pause() {
        player?.pause()
        isPlaying = false
    }

    func resume() {
        player?.play()
        isPlaying = true
    }

    func stop() {
        player?.pause()
        player = nil
        playerItem = nil
        isPlaying = false
        currentTime = 0
        duration = 0
        currentTrackId = nil
        isLoading = false
        error = nil
        removeTimeObserver()
        statusObserver?.invalidate()
        durationObserver?.invalidate()
    }

    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            resume()
        }
    }

    // MARK: - Seek
    func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime)
        currentTime = time
    }

    func seekForward(seconds: Double = 10) {
        let newTime = min(currentTime + seconds, duration)
        seek(to: newTime)
    }

    func seekBackward(seconds: Double = 10) {
        let newTime = max(currentTime - seconds, 0)
        seek(to: newTime)
    }

    // MARK: - Playback Speed
    func setPlaybackSpeed(_ speed: Float) {
        playbackSpeed = speed
        player?.rate = isPlaying ? speed : 0
    }

    // MARK: - Time Observer
    private func setupTimeObserver() {
        removeTimeObserver()

        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            Task { @MainActor in
                let seconds = CMTimeGetSeconds(time)
                if !seconds.isNaN && seconds.isFinite {
                    self?.currentTime = seconds
                }
            }
        }
    }

    private func removeTimeObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }

    // MARK: - Formatting
    var currentTimeFormatted: String {
        formatTime(currentTime)
    }

    var durationFormatted: String {
        formatTime(duration)
    }

    var remainingTimeFormatted: String {
        formatTime(duration - currentTime)
    }

    private func formatTime(_ time: Double) -> String {
        guard !time.isNaN && time.isFinite else { return "0:00" }
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let audioPlaybackEnded = Notification.Name("audioPlaybackEnded")
}
