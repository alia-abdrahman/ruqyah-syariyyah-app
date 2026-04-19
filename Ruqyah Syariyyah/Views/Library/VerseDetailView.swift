import SwiftUI

struct VerseDetailView: View {
    let verse: RuqyahVerse

    @EnvironmentObject var contentViewModel: ContentViewModel
    @EnvironmentObject var audioPlayerViewModel: AudioPlayerViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var isCopied: Bool = false
    @State private var repetitionCount: Int = 0
    @State private var showCounterComplete: Bool = false
    @State private var showConfetti: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: AppConstants.spacingLarge) {
                // Group title (multiline)
                Text(verse.group.replacingOccurrences(of: "\n", with: " "))
                    .font(.poppins(18, weight: .semibold))
                    .foregroundColor(.adaptiveText(colorScheme))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                // Arabic Text Card with Counter
                VStack(spacing: AppConstants.spacingMedium) {
                    if targetCount == nil, let number = verse.verseNumber {
                        Text(number.arabicToWesternNumerals)
                            .font(.poppins(16, weight: .semibold))
                            .foregroundColor(.primaryGreen)
                            .frame(width: 45, height: 45)
                            .background(Color.primaryGreen.opacity(0.1))
                            .clipShape(Circle())
                    }

                    Text(verse.arabicText)
                        .font(.arabicText(size: settingsViewModel.arabicTextSize))
                        .foregroundColor(.adaptiveText(colorScheme))
                        .multilineTextAlignment(.center)
                        .lineSpacing(16)
                        .padding(.horizontal)

                    // Counter badge below Arabic text
                    if targetCount != nil {
                        VStack(spacing: 6) {
                            counterBadge

                            Text("Tap to count · Long press to reset")
                                .font(.poppins(11, weight: .regular))
                                .foregroundColor(.textSecondary.opacity(0.6))
                        }
                        .padding(.top, 12)
                    }
                }
                .padding(.vertical, AppConstants.spacingLarge)
                .frame(maxWidth: .infinity)
                .background(Color.adaptiveSurface(colorScheme))
                .cornerRadius(AppConstants.radiusLarge)
                .shadow(color: .black.opacity(0.06), radius: 5, x: 0, y: 3)

                // Translation Card
                VStack(alignment: .leading, spacing: AppConstants.spacingMedium) {
                    Text("Translation")
                        .font(.headingSmall)
                        .foregroundColor(.adaptiveText(colorScheme))

                    Divider()

                    // English Translation
                    VStack(alignment: .leading, spacing: 6) {
                        Text("English")
                            .font(.caption)
                            .foregroundColor(.adaptiveSecondaryText(colorScheme))

                        Text(verse.translation(for: .english))
                            .font(.bodyLarge)
                            .foregroundColor(.adaptiveSecondaryText(colorScheme))
                            .lineSpacing(8)
                    }

                    Divider()
                        .opacity(0.5)

                    // Malay Translation
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Bahasa Melayu")
                            .font(.caption)
                            .foregroundColor(.adaptiveSecondaryText(colorScheme))

                        Text(verse.translation(for: .malay))
                            .font(.bodyLarge)
                            .foregroundColor(.adaptiveSecondaryText(colorScheme))
                            .lineSpacing(8)
                    }

                    if let reference = verse.reference {
                        HStack {
                            Image(systemName: "book.closed")
                                .foregroundColor(.primaryGreen)
                            Text(reference)
                                .font(.bodyMedium)
                                .foregroundColor(.primaryGreen)
                        }
                    }
                }
                .padding(AppConstants.spacingMedium)
                .background(Color.adaptiveSurface(colorScheme))
                .cornerRadius(AppConstants.radiusLarge)
                .shadow(color: .black.opacity(0.06), radius: 5, x: 0, y: 3)

                // Actions
                HStack(spacing: AppConstants.spacingMedium) {
                    // Favorite
                    ActionButton(
                        icon: contentViewModel.isFavorite(verse) ? "heart.fill" : "heart",
                        title: "Favorite",
                        color: contentViewModel.isFavorite(verse) ? .red : .textSecondary
                    ) {
                        Task {
                            await contentViewModel.toggleFavorite(verse)
                        }
                    }

                    // Copy
                    ActionButton(
                        icon: isCopied ? "checkmark" : "doc.on.doc",
                        title: isCopied ? "Copied" : "Copy",
                        color: isCopied ? .primaryGreen : .textSecondary
                    ) {
                        copyToClipboard()
                    }

                    // Share
                    ActionButton(
                        icon: "square.and.arrow.up",
                        title: "Share",
                        color: .textSecondary
                    ) {
                        shareVerse()
                    }

                    // Play (for local audio or API audio via reference, not for dhikr/dua groups)
                    if !AppConstants.noAudioGroups.contains(verse.group) && (verse.audioPath != nil || verse.reference != nil) {
                        ActionButton(
                            icon: audioPlayerViewModel.currentVerse?.id == verse.id && audioPlayerViewModel.isPlaying ? "pause.fill" : "play.fill",
                            title: playButtonTitle,
                            color: .primaryGreen
                        ) {
                            if audioPlayerViewModel.currentVerse?.id == verse.id && audioPlayerViewModel.isPlaying {
                                audioPlayerViewModel.pause()
                            } else if let target = targetCount, target > 0 {
                                audioPlayerViewModel.playWithRepeat(verse, times: target)
                            } else {
                                audioPlayerViewModel.playSingleVerse(verse)
                            }
                        }
                    }
                }
            }
            .padding(AppConstants.spacingMedium)
        }
        .background(Color.adaptiveBackground(colorScheme))
        .onReceive(NotificationCenter.default.publisher(for: .audioPlaybackEnded)) { _ in
            // Auto-increment counter when audio repeats
            if audioPlayerViewModel.currentVerse?.id == verse.id && audioPlayerViewModel.repeatCount > 0 {
                incrementCounter()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .fontWeight(.semibold)
                        Text("Back")
                            .font(.poppins(16, weight: .regular))
                    }
                    .foregroundColor(.primaryGreen)
                }
            }
        }
    }

    private var playButtonTitle: String {
        let isCurrentlyPlaying = audioPlayerViewModel.currentVerse?.id == verse.id && audioPlayerViewModel.isPlaying
        if isCurrentlyPlaying {
            if audioPlayerViewModel.repeatCount > 0 {
                return "\(audioPlayerViewModel.currentRepeat + 1)/\(audioPlayerViewModel.repeatCount)"
            }
            return "Pause"
        }
        if let target = targetCount, target > 0 {
            return "Play ×\(target)"
        }
        return "Play"
    }

    // MARK: - Repetition Counter
    private var targetCount: Int? {
        verse.recommendedRepetitions
    }

    private var counterProgress: Double {
        guard let target = targetCount, target > 0 else { return 0 }
        return min(Double(repetitionCount) / Double(target), 1.0)
    }

    private var counterBadge: some View {
        ZStack {
            // Confetti particles
            if showConfetti {
                ConfettiBurst()
            }

            // Background ring
            Circle()
                .stroke(Color.primaryGreen.opacity(0.15), lineWidth: 4)
                .frame(width: 65, height: 65)

            // Progress ring
            Circle()
                .trim(from: 0, to: counterProgress)
                .stroke(
                    showCounterComplete ? Color.accentGold : Color.primaryGreen,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 65, height: 65)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: counterProgress)

            // Count / checkmark
            if showCounterComplete {
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.accentGold)
                    .transition(.scale.combined(with: .opacity))
            } else {
                Text("\(repetitionCount)/\(targetCount ?? 0)")
                    .font(.poppins(14, weight: .bold))
                    .foregroundColor(.primaryGreen)
                    .contentTransition(.numericText())
            }
        }
        .contentShape(Circle().scale(3.5))
        .onTapGesture {
            incrementCounter()
        }
        .onLongPressGesture {
            resetCounter()
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showCounterComplete)
    }

    private func incrementCounter() {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
            repetitionCount += 1
        }

        // Light haptic
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()

        // Check if target reached
        if let target = targetCount, repetitionCount == target {
            withAnimation {
                showCounterComplete = true
                showConfetti = true
            }
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.success)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showCounterComplete = false
                    showConfetti = false
                }
            }
        }
    }

    private func resetCounter() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            repetitionCount = 0
            showCounterComplete = false
            showConfetti = false
        }

        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }

    private func copyToClipboard() {
        let text = """
        \(verse.arabicText)

        \(verse.translation(for: .english))

        \(verse.translation(for: .malay))

        \(verse.reference ?? "")
        """

        UIPasteboard.general.string = text
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            isCopied = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeOut(duration: 0.3)) {
                isCopied = false
            }
        }
    }

    private func shareVerse() {
        shareVerseAsImage(verse, colorScheme: colorScheme)
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let icon: String
    let title: String
    var color: Color = .textSecondary
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .contentTransition(.symbolEffect(.replace))

                Text(title)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppConstants.spacingMedium)
            .background(Color.adaptiveSurface(colorScheme))
            .cornerRadius(AppConstants.radiusMedium)
        }
        .buttonStyle(PressEffectButtonStyle(pressedScale: 0.9))
    }
}

// MARK: - Confetti Burst
struct ConfettiBurst: View {
    private let particles: [ConfettiParticle] = (0..<30).map { _ in ConfettiParticle() }

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                ConfettiParticleView(particle: particle)
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    let angle: Double
    let distance: CGFloat
    let size: CGFloat
    let isCircle: Bool
    let rotationEnd: Double

    init() {
        let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink, .cyan, .mint]
        color = colors.randomElement()!
        angle = Double.random(in: 0..<360)
        distance = CGFloat.random(in: 60...120)
        size = CGFloat.random(in: 6...10)
        isCircle = Bool.random()
        rotationEnd = Double.random(in: 180...720)
    }
}

struct ConfettiParticleView: View {
    let particle: ConfettiParticle
    @State private var animate = false

    private var offsetX: CGFloat {
        cos(particle.angle * .pi / 180) * particle.distance
    }
    private var offsetY: CGFloat {
        sin(particle.angle * .pi / 180) * particle.distance
    }

    var body: some View {
        Group {
            if particle.isCircle {
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
            } else {
                RoundedRectangle(cornerRadius: 1)
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size * 0.6)
            }
        }
        .offset(
            x: animate ? offsetX : 0,
            y: animate ? offsetY + 20 : 0
        )
        .scaleEffect(animate ? 0.5 : 1.2)
        .opacity(animate ? 0 : 1)
        .rotationEffect(.degrees(animate ? particle.rotationEnd : 0))
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                animate = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        VerseDetailView(verse: RuqyahVerse(
            arabicText: "بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ",
            englishTranslation: "In the name of Allah, the Entirely Merciful, the Especially Merciful.",
            malayTranslation: "Dengan nama Allah, Yang Maha Pemurah, lagi Maha Mengasihani.",
            group: "Surah Al-Fatihah",
            reference: "Al-Fatihah 1:1",
            audioPath: "audio.mp3",
            verseNumber: "١"
        ))
    }
    .environmentObject(ContentViewModel())
    .environmentObject(AudioPlayerViewModel())
    .environmentObject(SettingsViewModel())
}
