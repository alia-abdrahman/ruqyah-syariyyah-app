import SwiftUI

struct CollectionDetailView: View {
    let collection: Collection

    @EnvironmentObject var contentViewModel: ContentViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var showReadAllView: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Static Header
            VStack(alignment: .leading, spacing: 8) {
                // Title
                Text(collection.name)
                    .font(.poppins(28, weight: .bold))
                    .foregroundColor(.white)

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

                // Read All Button
                Button {
                    showReadAllView = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Read All")
                            .font(.poppins(14, weight: .semibold))
                    }
                    .foregroundColor(.primaryGreen)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .cornerRadius(25)
                }
                .padding(.top, 12)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 120)
            .padding(.bottom, 20)
            .background(
                LinearGradient(
                    colors: [.primaryGreen, .primaryGreenDark],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

            // Scrollable Content
            ScrollView {
                VStack(spacing: AppConstants.spacingMedium) {
                    Color.clear.frame(height: 1).id("scrollTop")

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
                        .bounceOnTap()
                    }

                    // End of list
                    VStack(spacing: 6) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 18))
                            .foregroundColor(.textSecondary.opacity(0.4))
                        Text("You've reached the end")
                            .font(.poppins(12, weight: .regular))
                            .foregroundColor(.textSecondary.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, AppConstants.spacingMedium)
                    .padding(.bottom, 80)
                    .id("scrollBottom")
                }
                .padding(.horizontal, AppConstants.spacingMedium)
                .padding(.top, AppConstants.spacingMedium)
                .padding(.bottom, AppConstants.spacingXLarge)
            }
            .withScrollButtons()
        }
        .background(Color.adaptiveBackground(colorScheme))
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .fontWeight(.semibold)
                        Text("Back")
                            .font(.poppins(16, weight: .regular))
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $showReadAllView) {
            CollectionMushafView(collection: collection)
        }
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
                    .fixedSize(horizontal: false, vertical: true)

                Text("\(group.verseCount) verses")
                    .font(.poppins(13, weight: .regular))
                    .foregroundColor(.textSecondary)
            }
            .layoutPriority(1)

            Spacer()

            // Arabic name
            if let arabicName = group.arabicName {
                Text(arabicName)
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
        .shadow(color: .black.opacity(0.06), radius: 5, x: 0, y: 3)
    }
}

#Preview {
    NavigationStack {
        CollectionDetailView(collection: Collection(
            id: "amalan-pendinding-diri",
            name: "Self-Protection Recitations",
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
