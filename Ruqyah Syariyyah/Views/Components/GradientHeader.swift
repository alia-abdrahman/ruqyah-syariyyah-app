import SwiftUI

struct GradientHeader<Content: View, TrailingContent: View>: View {
    let title: String
    let subtitle: String?
    let showBackButton: Bool
    let trailingContent: () -> TrailingContent
    let content: () -> Content

    init(
        title: String,
        subtitle: String? = nil,
        showBackButton: Bool = false,
        @ViewBuilder trailingContent: @escaping () -> TrailingContent = { EmptyView() },
        @ViewBuilder content: @escaping () -> Content = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.showBackButton = showBackButton
        self.trailingContent = trailingContent
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
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
        .padding(.horizontal, 20)
        .padding(.top, showBackButton ? 100 : 44)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [.primaryGreen, .primaryGreenDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

#Preview {
    VStack(spacing: 0) {
        GradientHeader(
            title: "Library",
            subtitle: "Your spiritual healing collection"
        )
        .ignoresSafeArea(edges: .top)

        Spacer()
    }
}
