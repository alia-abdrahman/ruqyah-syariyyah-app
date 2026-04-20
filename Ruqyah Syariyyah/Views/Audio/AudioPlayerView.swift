import SwiftUI

struct AudioPlayerView: View {
    @EnvironmentObject var audioPlayerViewModel: AudioPlayerViewModel
    @EnvironmentObject var contentViewModel: ContentViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var showSpeedPicker: Bool = false
    @State private var showRepeatPicker: Bool = false

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header
                ZStack(alignment: .bottom) {
                    LinearGradient(
                        colors: [.primaryGreen, .primaryGreenDark],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    if let verse = audioPlayerViewModel.currentVerse {
                        VStack(spacing: AppConstants.spacingMedium) {
                            if let number = verse.verseNumber {
                                Text(number.arabicToWesternNumerals)
                                    .font(.poppins(18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(Circle())
                            }

                            Text(verse.group)
                                .font(.headingSmall)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            if let reference = verse.reference {
                                Text(reference)
                                    .font(.bodySmall)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
                .frame(height: 180 + geometry.safeAreaInsets.top)

                // Verse Content
                ScrollView {
                    if let verse = audioPlayerViewModel.currentVerse {
                        VStack(spacing: AppConstants.spacingLarge) {
                            Text(verse.arabicText)
                                .font(.arabicText(size: settingsViewModel.arabicTextSize))
                                .foregroundColor(.adaptiveText(colorScheme))
                                .multilineTextAlignment(.center)
                                .lineSpacing(16)
                                .padding()

                            Divider()

                            Text(verse.translation(for: contentViewModel.language))
                                .font(.bodyLarge)
                                .foregroundColor(.adaptiveSecondaryText(colorScheme))
                                .multilineTextAlignment(.center)
                                .lineSpacing(8)
                                .padding(.horizontal)
                        }
                        .padding(.vertical, AppConstants.spacingLarge)
                    }
                }

                // Player Controls
                VStack(spacing: AppConstants.spacingMedium) {
                    // Progress Bar
                    VStack(spacing: 4) {
                        Slider(
                            value: Binding(
                                get: { audioPlayerViewModel.currentTime },
                                set: { audioPlayerViewModel.seek(to: $0) }
                            ),
                            in: 0...max(audioPlayerViewModel.duration, 1)
                        )
                        .tint(.primaryGreen)

                        HStack {
                            Text(audioPlayerViewModel.currentTimeFormatted)
                            Spacer()
                            Text("-\(audioPlayerViewModel.remainingTimeFormatted)")
                        }
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    }
                    .padding(.horizontal)

                    // Repeat Status
                    if audioPlayerViewModel.repeatCount > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "repeat")
                                .font(.system(size: 12))
                            Text("Repeat \(audioPlayerViewModel.currentRepeat + 1) of \(audioPlayerViewModel.repeatCount)")
                                .font(.poppins(13, weight: .medium))
                        }
                        .foregroundColor(.primaryGreen)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 14)
                        .background(Color.primaryGreen.opacity(0.1))
                        .cornerRadius(20)
                    }

                    // Main Transport Controls
                    HStack(spacing: AppConstants.spacingXLarge) {
                        // Previous
                        Button {
                            audioPlayerViewModel.playPrevious()
                        } label: {
                            Image(systemName: "backward.fill")
                                .font(.title2)
                                .foregroundColor(audioPlayerViewModel.hasPrevious ? .adaptiveText(colorScheme) : .textSecondary.opacity(0.3))
                        }
                        .disabled(!audioPlayerViewModel.hasPrevious)

                        // Rewind
                        Button {
                            audioPlayerViewModel.seekBackward()
                        } label: {
                            Image(systemName: "gobackward.10")
                                .font(.title2)
                                .foregroundColor(.adaptiveText(colorScheme))
                        }

                        // Play/Pause
                        Button {
                            audioPlayerViewModel.togglePlayPause()
                        } label: {
                            Image(systemName: audioPlayerViewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 64))
                                .foregroundColor(.primaryGreen)
                        }

                        // Forward
                        Button {
                            audioPlayerViewModel.seekForward()
                        } label: {
                            Image(systemName: "goforward.10")
                                .font(.title2)
                                .foregroundColor(.adaptiveText(colorScheme))
                        }

                        // Next
                        Button {
                            audioPlayerViewModel.playNext()
                        } label: {
                            Image(systemName: "forward.fill")
                                .font(.title2)
                                .foregroundColor(audioPlayerViewModel.hasNext ? .adaptiveText(colorScheme) : .textSecondary.opacity(0.3))
                        }
                        .disabled(!audioPlayerViewModel.hasNext)
                    }

                    // Speed & Repeat Row
                    HStack {
                        Button {
                            showSpeedPicker = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "speedometer")
                                    .font(.system(size: 14))
                                Text("\(String(format: "%.1f", audioPlayerViewModel.playbackSpeed))×")
                                    .font(.poppins(13, weight: .medium))
                            }
                            .foregroundColor(.textSecondary)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 14)
                            .background(Color.textSecondary.opacity(0.1))
                            .cornerRadius(20)
                        }

                        Spacer()

                        Button {
                            showRepeatPicker = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "repeat")
                                    .font(.system(size: 14))
                                Text(audioPlayerViewModel.repeatCount > 0 ? "\(audioPlayerViewModel.repeatCount)×" : "Off")
                                    .font(.poppins(13, weight: .medium))
                            }
                            .foregroundColor(audioPlayerViewModel.repeatCount > 0 ? .primaryGreen : .textSecondary)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 14)
                            .background(
                                audioPlayerViewModel.repeatCount > 0
                                    ? Color.primaryGreen.opacity(0.1)
                                    : Color.textSecondary.opacity(0.1)
                            )
                            .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, AppConstants.spacingLarge)
                }
                .padding()
                .background(Color.adaptiveSurface(colorScheme))
            }
            .background(Color.adaptiveBackground(colorScheme))
            .ignoresSafeArea(edges: .top)
            }  // GeometryReader
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.down")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        audioPlayerViewModel.stop()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .confirmationDialog("Playback Speed", isPresented: $showSpeedPicker) {
                ForEach(AppConstants.playbackSpeedOptions, id: \.self) { speed in
                    Button("\(String(format: "%.1f", speed))x") {
                        audioPlayerViewModel.setPlaybackSpeed(speed)
                    }
                }
            }
            .confirmationDialog("Repeat Verse", isPresented: $showRepeatPicker) {
                ForEach(AppConstants.repeatCountOptions, id: \.self) { count in
                    Button(count == 0 ? "Off" : "\(count)×") {
                        audioPlayerViewModel.setRepeatCount(count)
                    }
                }
            } message: {
                Text("Auto-repeat this verse during playback")
            }
        }
    }
}

#Preview {
    AudioPlayerView()
        .environmentObject(AudioPlayerViewModel())
        .environmentObject(ContentViewModel())
        .environmentObject(SettingsViewModel())
}
