import SwiftUI

enum HeaderStyle {
    case gradient
    case plain
}

struct GradientHeader<Content: View, TrailingContent: View>: View {
    let title: String
    let subtitle: String?
    let showBackButton: Bool
    let style: HeaderStyle
    let trailingContent: () -> TrailingContent
    let content: () -> Content

    @Environment(\.colorScheme) private var colorScheme

    init(
        title: String,
        subtitle: String? = nil,
        showBackButton: Bool = false,
        style: HeaderStyle = .gradient,
        @ViewBuilder trailingContent: @escaping () -> TrailingContent = { EmptyView() },
        @ViewBuilder content: @escaping () -> Content = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.showBackButton = showBackButton
        self.style = style
        self.trailingContent = trailingContent
        self.content = content
    }

    private var titleColor: Color {
        style == .plain ? .adaptiveText(colorScheme) : .white
    }

    private var subtitleColor: Color {
        style == .plain ? .textSecondary : .white.opacity(0.85)
    }

    private var topPadding: CGFloat {
        if style == .plain {
            return showBackButton ? 70 : 60
        }
        return showBackButton ? 120 : 70
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title row with trailing content
            HStack(alignment: .top) {
                Text(title)
                    .font(.poppins(28, weight: .bold))
                    .foregroundColor(titleColor)
                    .lineLimit(3)
                    .minimumScaleFactor(0.7)
                    .layoutPriority(1)

                Spacer()

                trailingContent()
            }

            if let sub = subtitle {
                Text(sub)
                    .font(.poppins(14, weight: .regular))
                    .foregroundColor(subtitleColor)
            }

            content()
        }
        .padding(.horizontal, 20)
        .padding(.top, topPadding)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Group {
                if style == .plain {
                    LinearGradient(
                        colors: [
                            Color.adaptiveBackground(colorScheme),
                            Color.primaryGreenLight.opacity(colorScheme == .dark ? 0.08 : 0.15)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                } else {
                    Color.headerGradient
                }
            }
        )
    }
}

#Preview {
    VStack(spacing: 0) {
        GradientHeader(
            title: "Library",
            subtitle: "Your spiritual healing collection",
            style: .plain
        )

        Spacer()
    }
}
