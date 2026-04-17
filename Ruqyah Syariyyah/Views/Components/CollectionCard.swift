import SwiftUI

struct CollectionCard: View {
    let collection: Collection

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.spacingSmall) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.primaryGreen.opacity(0.15))
                    .frame(width: 50, height: 50)

                Image(systemName: collection.sfSymbol)
                    .font(.system(size: 22))
                    .foregroundColor(.primaryGreen)
            }

            Spacer()

            // Name
            Text(collection.name)
                .font(.poppins(15, weight: .semibold))
                .foregroundColor(.adaptiveText(colorScheme))
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            // Stats
            HStack(spacing: AppConstants.spacingSmall) {
                Label("\(collection.groupCount)", systemImage: "folder")
                Label("\(collection.totalVerseCount)", systemImage: "text.quote")
            }
            .font(.caption)
            .foregroundColor(.textSecondary)
        }
        .padding(AppConstants.spacingMedium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 180)
        .background(Color.adaptiveSurface(colorScheme))
        .cornerRadius(AppConstants.radiusXLarge)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
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
                    ? .easeIn(duration: 0.06)
                    : .interpolatingSpring(stiffness: 250, damping: 8),
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
