import SwiftUI

struct MiniPlayerView: View {
    @EnvironmentObject var audioPlayerViewModel: AudioPlayerViewModel
    @EnvironmentObject var contentViewModel: ContentViewModel
    @Environment(\.colorScheme) private var colorScheme

    @State private var showFullPlayer: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Progress Bar
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.primaryGreen)
                    .frame(width: geometry.size.width * audioPlayerViewModel.progress)
            }
            .frame(height: 3)
            .background(Color.textSecondary.opacity(0.2))

            // Content
            HStack(spacing: AppConstants.spacingMedium) {
                // Verse Info
                if let verse = audioPlayerViewModel.currentVerse {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(verse.group)
                            .font(.bodyMedium)
                            .foregroundColor(.adaptiveText(colorScheme))
                            .lineLimit(1)

                        HStack(spacing: 6) {
                            if let reference = verse.reference {
                                Text(reference)
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                                    .lineLimit(1)
                            }

                            if audioPlayerViewModel.repeatCount > 0 {
                                HStack(spacing: 3) {
                                    Image(systemName: "repeat")
                                        .font(.system(size: 10))
                                    Text("\(audioPlayerViewModel.currentRepeat + 1)/\(audioPlayerViewModel.repeatCount)")
                                        .font(.system(size: 11, weight: .medium))
                                }
                                .foregroundColor(.primaryGreen)
                            }
                        }
                    }
                }

                Spacer()

                // Controls
                HStack(spacing: AppConstants.spacingMedium) {
                    Button {
                        audioPlayerViewModel.togglePlayPause()
                    } label: {
                        Image(systemName: audioPlayerViewModel.isPlaying ? "pause.fill" : "play.fill")
                            .font(.title2)
                            .foregroundColor(.primaryGreen)
                    }

                    Button {
                        audioPlayerViewModel.stop()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .padding(.horizontal, AppConstants.spacingMedium)
            .padding(.vertical, AppConstants.spacingSmall)
        }
        .background(Color.adaptiveSurface(colorScheme))
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: -3)
        .onTapGesture {
            showFullPlayer = true
        }
        .fullScreenCover(isPresented: $showFullPlayer) {
            AudioPlayerView()
        }
    }
}

#Preview {
    VStack {
        Spacer()
        MiniPlayerView()
    }
    .environmentObject(AudioPlayerViewModel())
    .environmentObject(ContentViewModel())
}
