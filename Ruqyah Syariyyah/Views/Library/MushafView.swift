import SwiftUI

struct MushafView: View {
    let verses: [RuqyahVerse]

    @EnvironmentObject var contentViewModel: ContentViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var currentIndex: Int = 0
    @State private var showTranslation: Bool = true

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                TabView(selection: $currentIndex) {
                    ForEach(Array(verses.enumerated()), id: \.offset) { index, verse in
                        versePageView(verse, geometry: geometry)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .background(Color.adaptiveBackground(colorScheme))
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.adaptiveText(colorScheme))
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("\(currentIndex + 1) / \(verses.count)")
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showTranslation.toggle()
                    } label: {
                        Image(systemName: showTranslation ? "text.bubble.fill" : "text.bubble")
                            .foregroundColor(.primaryGreen)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                // Page Navigation
                HStack {
                    Button {
                        if currentIndex > 0 {
                            withAnimation {
                                currentIndex -= 1
                            }
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(currentIndex > 0 ? .primaryGreen : .textSecondary.opacity(0.3))
                    }
                    .disabled(currentIndex == 0)

                    Spacer()

                    // Page Dots (max 10 visible)
                    HStack(spacing: 6) {
                        let start = max(0, min(currentIndex - 4, verses.count - 10))
                        let end = min(start + 10, verses.count)

                        ForEach(start..<end, id: \.self) { index in
                            Circle()
                                .fill(index == currentIndex ? Color.primaryGreen : Color.textSecondary.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }

                    Spacer()

                    Button {
                        if currentIndex < verses.count - 1 {
                            withAnimation {
                                currentIndex += 1
                            }
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                            .foregroundColor(currentIndex < verses.count - 1 ? .primaryGreen : .textSecondary.opacity(0.3))
                    }
                    .disabled(currentIndex == verses.count - 1)
                }
                .padding()
                .background(Color.adaptiveSurface(colorScheme))
            }
        }
    }

    @ViewBuilder
    private func versePageView(_ verse: RuqyahVerse, geometry: GeometryProxy) -> some View {
        ScrollView {
            VStack(spacing: AppConstants.spacingLarge) {
                Spacer()
                    .frame(height: 20)

                // Verse Number
                if let number = verse.verseNumber {
                    ZStack {
                        Image(systemName: "seal.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.primaryGreen.opacity(0.15))

                        Text(number)
                            .font(.amiriQuran(24))
                            .foregroundColor(.primaryGreen)
                    }
                }

                // Arabic Text
                Text(verse.arabicText)
                    .font(.arabicText(size: settingsViewModel.arabicTextSize + 4))
                    .foregroundColor(.adaptiveText(colorScheme))
                    .multilineTextAlignment(.center)
                    .lineSpacing(20)
                    .padding(.horizontal, AppConstants.spacingLarge)

                // Translation
                if showTranslation {
                    Divider()
                        .padding(.horizontal, 50)

                    Text(verse.translation(for: contentViewModel.language))
                        .font(.bodyLarge)
                        .foregroundColor(.adaptiveSecondaryText(colorScheme))
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                        .padding(.horizontal, AppConstants.spacingLarge)

                    if let reference = verse.reference {
                        Text(reference)
                            .font(.bodySmall)
                            .foregroundColor(.primaryGreen)
                    }
                }

                Spacer()
                    .frame(height: 100)
            }
            .frame(minHeight: geometry.size.height - 100)
        }
    }
}

#Preview {
    MushafView(verses: [
        RuqyahVerse(
            arabicText: "بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ",
            englishTranslation: "In the name of Allah, the Entirely Merciful, the Especially Merciful.",
            malayTranslation: "Dengan nama Allah, Yang Maha Pemurah.",
            group: "Al-Fatihah",
            reference: "Al-Fatihah 1:1",
            verseNumber: "١"
        ),
        RuqyahVerse(
            arabicText: "ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَـٰلَمِينَ",
            englishTranslation: "[All] praise is [due] to Allah, Lord of the worlds",
            malayTranslation: "Segala puji tertentu bagi Allah.",
            group: "Al-Fatihah",
            reference: "Al-Fatihah 1:2",
            verseNumber: "٢"
        )
    ])
    .environmentObject(ContentViewModel())
    .environmentObject(SettingsViewModel())
}
