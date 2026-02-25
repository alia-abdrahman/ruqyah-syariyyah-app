import SwiftUI

struct GradientHeader<Content: View>: View {
    let title: String
    let subtitle: String?
    let content: () -> Content

    init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: @escaping () -> Content = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: [.primaryGreen, .primaryGreenDark],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                VStack(alignment: .leading, spacing: 8) {
                    Spacer()
                        .frame(height: geometry.safeAreaInsets.top + 16)

                    Text(title)
                        .font(.poppins(28, weight: .bold))
                        .foregroundColor(.white)

                    if let sub = subtitle {
                        Text(sub)
                            .font(.poppins(14, weight: .regular))
                            .foregroundColor(.white.opacity(0.85))
                    }

                    content()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
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
