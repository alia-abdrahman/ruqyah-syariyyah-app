import SwiftUI

struct AudioPlayerView: View {
    @EnvironmentObject var audioPlayerViewModel: AudioPlayerViewModel
    @EnvironmentObject var contentViewModel: ContentViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var showSpeedPicker: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                ZStack {
                    LinearGradient(
                        colors: [.primaryGreen, .primaryGreenDark],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    if let verse = audioPlayerViewModel.currentVerse {
                        VStack(spacing: AppConstants.spacingMedium) {
                            if let number = verse.verseNumber {
                                Text(number)
                                    .font(.amiriQuran(28))
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(Circle())
                            }

                            Text(verse.group)
                                .font(.headingSmall)
                                .foregroundColor(.white)

                            if let reference = verse.reference {
                                Text(reference)
                                    .font(.bodySmall)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .padding()
                    }
                }
                .frame(height: 180)

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

                    // Main Controls
                    HStack(spacing: AppConstants.spacingXLarge) {
                        // Speed
                        Button {
                            showSpeedPicker = true
                        } label: {
                            Text("\(String(format: "%.1f", audioPlayerViewModel.playbackSpeed))x")
                                .font(.bodyMedium)
                                .foregroundColor(.textSecondary)
                                .frame(width: 50)
                        }

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

                        // Favorite
                        if let verse = audioPlayerViewModel.currentVerse {
                            Button {
                                Task {
                                    await contentViewModel.toggleFavorite(verse)
                                }
                            } label: {
                                Image(systemName: contentViewModel.isFavorite(verse) ? "heart.fill" : "heart")
                                    .font(.title3)
                                    .foregroundColor(contentViewModel.isFavorite(verse) ? .red : .textSecondary)
                            }
                        }
                    }
                    .padding(.bottom, AppConstants.spacingLarge)
                }
                .padding()
                .background(Color.adaptiveSurface(colorScheme))
            }
            .background(Color.adaptiveBackground(colorScheme))
            .ignoresSafeArea(edges: .top)
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
        }
    }
}

#Preview {
    AudioPlayerView()
        .environmentObject(AudioPlayerViewModel())
        .environmentObject(ContentViewModel())
        .environmentObject(SettingsViewModel())
}
