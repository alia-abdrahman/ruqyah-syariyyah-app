import Foundation
import AVFoundation
import Combine

@MainActor
class AudioService: ObservableObject {
    static let shared = AudioService()

    private var player: AVAudioPlayer?
    private var timer: Timer?

    @Published var isPlaying: Bool = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var currentTrackId: String?
    @Published var playbackSpeed: Float = 1.0

    private init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    // MARK: - Playback Controls
    func play(url: URL, trackId: String) {
        stop()

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.enableRate = true
            player?.rate = playbackSpeed
            player?.prepareToPlay()
            player?.play()

            currentTrackId = trackId
            duration = player?.duration ?? 0
            isPlaying = true

            startTimer()
        } catch {
            print("Failed to play audio: \(error)")
        }
    }

    func play(named fileName: String, trackId: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            print("Audio file not found: \(fileName)")
            return
        }
        play(url: url, trackId: trackId)
    }

    func pause() {
        player?.pause()
        isPlaying = false
        stopTimer()
    }

    func resume() {
        player?.play()
        isPlaying = true
        startTimer()
    }

    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
        currentTime = 0
        duration = 0
        currentTrackId = nil
        stopTimer()
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
        player?.currentTime = time
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
        player?.rate = speed
    }

    // MARK: - Timer
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateCurrentTime()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateCurrentTime() {
        guard let player = player else { return }
        currentTime = player.currentTime

        if !player.isPlaying && currentTime >= duration - 0.1 {
            // Playback finished
            isPlaying = false
            stopTimer()
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
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
