import SwiftUI

struct GradientHeader<Content: View, TrailingContent: View>: View {
    let title: String
    let subtitle: String?
    let showBackButton: Bool
    let content: () -> Content
    let trailingContent: () -> TrailingContent

    init(
        title: String,
        subtitle: String? = nil,
        showBackButton: Bool = false,
        @ViewBuilder content: @escaping () -> Content = { EmptyView() },
        @ViewBuilder trailingContent: @escaping () -> TrailingContent = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.showBackButton = showBackButton
        self.content = content
        self.trailingContent = trailingContent
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: [.primaryGreen, .primaryGreenDark],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                VStack(alignment: .leading, spacing: 12) {
                    // Add extra padding when back button is shown (detail views)
                    Spacer()
                        .frame(height: geometry.safeAreaInsets.top + (showBackButton ? 100 : 44))

                    // Title row with trailing content
                    HStack(alignment: .center) {
                        Text(title)
                            .font(.poppins(28, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(3)
                            .minimumScaleFactor(0.7)
                            .layoutPriority(1)

                        Spacer()

                        trailingContent()
                    }

                    if let sub = subtitle {
                        Text(sub)
                            .font(.poppins(14, weight: .regular))
                            .foregroundColor(.white.opacity(0.85))
                    }

                    content()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 5)
            }
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        GradientHeader(
            title: "Library",
            subtitle: "Your spiritual healing collection"
        )
        .frame(height: 160)
        .ignoresSafeArea(edges: .top)

        Spacer()
    }
}
