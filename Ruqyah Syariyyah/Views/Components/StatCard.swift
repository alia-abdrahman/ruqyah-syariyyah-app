import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    var color: Color = .primaryGreen

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.spacingSmall) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)

                Spacer()
            }

            Text(value)
                .font(.headingMedium)
                .foregroundColor(.adaptiveText(colorScheme))

            Text(title)
                .font(.bodySmall)
                .foregroundColor(.textSecondary)
        }
        .padding(AppConstants.spacingMedium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.adaptiveSurface(colorScheme))
        .cornerRadius(AppConstants.radiusLarge)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Large Stat Card
struct LargeStatCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String
    var color: Color = .primaryGreen

    @Environment(\.colorScheme) private var colorScheme

    init(title: String, value: String, subtitle: String? = nil, icon: String, color: Color = .primaryGreen) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
    }

    var body: some View {
        HStack(spacing: AppConstants.spacingMedium) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 56, height: 56)

                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.bodySmall)
                    .foregroundColor(.textSecondary)

                Text(value)
                    .font(.headingMedium)
                    .foregroundColor(.adaptiveText(colorScheme))

                if let sub = subtitle {
                    Text(sub)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }

            Spacer()
        }
        .padding(AppConstants.spacingMedium)
        .background(Color.adaptiveSurface(colorScheme))
        .cornerRadius(AppConstants.radiusLarge)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    VStack(spacing: 16) {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatCard(title: "Sessions", value: "12", icon: "checkmark.circle")
            StatCard(title: "Minutes", value: "156", icon: "clock", color: .accentBlue)
            StatCard(title: "Streak", value: "7", icon: "flame", color: .accentGold)
            StatCard(title: "Favorites", value: "23", icon: "heart.fill", color: .red)
        }

        LargeStatCard(
            title: "This Week",
            value: "5 sessions",
            subtitle: "45 minutes total",
            icon: "chart.bar.fill"
        )
    }
    .padding()
}
