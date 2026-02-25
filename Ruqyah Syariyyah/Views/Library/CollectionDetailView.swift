import SwiftUI

struct CollectionDetailView: View {
    let collection: Collection

    @EnvironmentObject var contentViewModel: ContentViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                GeometryReader { geometry in
                    ZStack(alignment: .topLeading) {
                        LinearGradient(
                            colors: [.primaryGreen, .primaryGreenDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )

                        VStack(alignment: .leading, spacing: 8) {
                            Spacer()
                                .frame(height: geometry.safeAreaInsets.top + 24)

                            // Title
                            Text(collection.name)
                                .font(.poppins(28, weight: .bold))
                                .foregroundColor(.white)

                            // Arabic Name
                            if let arabicName = collection.nameArabic {
                                Text(arabicName)
                                    .font(.amiriQuran(20))
                                    .foregroundColor(.white.opacity(0.9))
                            }

                            // Badge pills
                            HStack(spacing: 12) {
                                Text("\(collection.groupCount) groups")
                                    .font(.poppins(13, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(20)

                                Text("\(collection.totalVerseCount) verses")
                                    .font(.poppins(13, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(20)
                            }
                            .padding(.top, 4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
                .frame(height: 220)

                VStack(spacing: AppConstants.spacingMedium) {
                    // Description Card
                    if let description = collection.description, !description.isEmpty {
                        Text(description)
                            .font(.poppins(15, weight: .regular))
                            .foregroundColor(.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(AppConstants.spacingMedium)
                            .background(Color.primaryGreen.opacity(0.08))
                            .cornerRadius(AppConstants.radiusLarge)
                    }

                    // Groups List
                    let groups = contentViewModel.getGroupsForCollection(collection.id)

                    ForEach(Array(groups.enumerated()), id: \.element.id) { index, group in
                        NavigationLink(destination: GroupDetailView(group: group)) {
                            GroupRowView(group: group, index: index + 1)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(AppConstants.spacingMedium)
            }
        }
        .background(Color.adaptiveBackground(colorScheme))
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

// MARK: - Group Row View
struct GroupRowView: View {
    let group: VerseGroup
    let index: Int

    @Environment(\.colorScheme) private var colorScheme

    init(group: VerseGroup, index: Int = 1) {
        self.group = group
        self.index = index
    }

    var body: some View {
        HStack(spacing: AppConstants.spacingMedium) {
            // Number Circle
            ZStack {
                Circle()
                    .fill(Color.primaryGreen)
                    .frame(width: 44, height: 44)

                Text("\(index)")
                    .font(.poppins(16, weight: .semibold))
                    .foregroundColor(.white)
            }

            // Name and verse count
            VStack(alignment: .leading, spacing: 2) {
                Text(group.name)
                    .font(.poppins(16, weight: .semibold))
                    .foregroundColor(.adaptiveText(colorScheme))

                Text("\(group.verseCount) verses")
                    .font(.poppins(13, weight: .regular))
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            // Arabic preview
            if let preview = group.arabicPreview {
                Text(preview)
                    .font(.amiriQuran(16))
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
                    .frame(maxWidth: 120, alignment: .trailing)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(AppConstants.spacingMedium)
        .background(Color.adaptiveSurface(colorScheme))
        .cornerRadius(AppConstants.radiusLarge)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        CollectionDetailView(collection: Collection(
            id: "amalan-pendinding-diri",
            name: "Amalan Pendinding Diri",
            nameArabic: "أعمال حماية النفس",
            description: "Protection prayers and verses from the Holy Quran for spiritual shielding",
            icon: "shield",
            sortOrder: 1,
            groupCount: 2,
            totalVerseCount: 11
        ))
    }
    .environmentObject(ContentViewModel())
    .environmentObject(SettingsViewModel())
}
