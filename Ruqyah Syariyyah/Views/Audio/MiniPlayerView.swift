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

                        if let reference = verse.reference {
                            Text(reference)
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                                .lineLimit(1)
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
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: -2)
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
