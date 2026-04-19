import SwiftUI

struct CollectionCard: View {
    let collection: Collection

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.spacingSmall) {
            // Icon — solid green circle with white icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.primaryGreen)
                    .frame(width: 44, height: 44)

                Image(systemName: collection.sfSymbol)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }

            Spacer()

            // Name
            Text(collection.name)
                .font(.poppins(16, weight: .bold))
                .foregroundColor(.adaptiveText(colorScheme))
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            // Stats
            Text("\(collection.groupCount) duas · \(collection.totalVerseCount) ayat")
                .font(.poppins(12, weight: .regular))
                .foregroundColor(.textSecondary)
        }
        .padding(AppConstants.spacingMedium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 170)
        .background(Color.adaptiveSurface(colorScheme))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Bounce on Tap Modifier
struct BounceModifier: ViewModifier {
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .animation(
                isPressed
                    ? .easeIn(duration: 0.08)
                    : .spring(response: 0.35, dampingFraction: 0.4),
                value: isPressed
            )
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed { isPressed = true }
                    }
                    .onEnded { _ in
                        isPressed = false
                    }
            )
    }
}

extension View {
    func bounceOnTap() -> some View {
        modifier(BounceModifier())
    }
}

// MARK: - Press Effect Button Style
struct PressEffectButtonStyle: ButtonStyle {
    var pressedScale: CGFloat = 0.92

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1.0)
            .animation(
                configuration.isPressed
                    ? .easeIn(duration: 0.08)
                    : .spring(response: 0.35, dampingFraction: 0.4),
                value: configuration.isPressed
            )
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
        CollectionCard(collection: Collection(
            id: "amalan-pendinding-diri",
            name: "Self-Protection Recitations",
            nameArabic: "أعمال حماية النفس",
            description: "Protection prayers",
            icon: "shield",
            sortOrder: 1,
            groupCount: 3,
            totalVerseCount: 15
        ))

        CollectionCard(collection: Collection.fromId("amalan-kendiri", groupCount: 5, totalVerseCount: 25))
    }
    .padding()
}
