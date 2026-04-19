import SwiftUI

struct WelcomeView: View {
    @Binding var isPresented: Bool
    @State private var currentPage: Int = 0
    @State private var opacity: Double = 0

    private let pages: [WelcomePage] = [
        WelcomePage(
            title: "Ruqyah Syar'iyyah",
            titleArabic: "الرقية الشرعية",
            description: "Your companion for spiritual healing through authentic Quranic recitations and supplications",
            icon: "book.fill"
        ),
        WelcomePage(
            title: "Comprehensive Library",
            titleArabic: "مكتبة شاملة",
            description: "Access a curated collection of protection verses, healing duas, and daily adhkar",
            icon: "books.vertical.fill"
        ),
        WelcomePage(
            title: "Track Your Progress",
            titleArabic: "تتبع تقدمك",
            description: "Build consistency with session tracking and maintain your spiritual practice",
            icon: "chart.line.uptrend.xyaxis"
        )
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.primaryGreen, .primaryGreenDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Page Content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        pageView(page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 400)

                // Page Indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.white : Color.white.opacity(0.4))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut, value: currentPage)
                    }
                }
                .padding(.top, 20)

                Spacer()

                // Buttons
                VStack(spacing: 16) {
                    if currentPage < pages.count - 1 {
                        Button {
                            withAnimation {
                                currentPage += 1
                            }
                        } label: {
                            Text("Next")
                                .font(.button)
                                .foregroundColor(.primaryGreen)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .cornerRadius(AppConstants.radiusLarge)
                        }
                    } else {
                        Button {
                            withAnimation {
                                isPresented = false
                            }
                        } label: {
                            Text("Get Started")
                                .font(.button)
                                .foregroundColor(.primaryGreen)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .cornerRadius(AppConstants.radiusLarge)
                        }
                    }

                    if currentPage < pages.count - 1 {
                        Button {
                            withAnimation {
                                isPresented = false
                            }
                        } label: {
                            Text("Skip")
                                .font(.bodyMedium)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .padding(.horizontal, AppConstants.spacingLarge)
                .padding(.bottom, 50)
            }
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) {
                opacity = 1
            }
        }
    }

    @ViewBuilder
    private func pageView(_ page: WelcomePage) -> some View {
        VStack(spacing: AppConstants.spacingLarge) {
            Image(systemName: page.icon)
                .font(.system(size: 60))
                .foregroundColor(.white)
                .padding(.bottom, 10)

            VStack(spacing: 8) {
                Text(page.titleArabic)
                    .font(.amiriQuran(32))
                    .foregroundColor(.white)

                Text(page.title)
                    .font(.headingMedium)
                    .foregroundColor(.white)
            }

            Text(page.description)
                .font(.bodyLarge)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppConstants.spacingLarge)
        }
        .padding(.horizontal, AppConstants.spacingMedium)
    }
}

// MARK: - Supporting Types
private struct WelcomePage {
    let title: String
    let titleArabic: String
    let description: String
    let icon: String
}

#Preview {
    WelcomeView(isPresented: .constant(true))
}
