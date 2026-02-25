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
                GradientHeader(
                    title: collection.name,
                    subtitle: collection.description,
                    showBackButton: true
                ) {
                    HStack(spacing: AppConstants.spacingMedium) {
                        Label("\(collection.groupCount) groups", systemImage: "folder")
                        Label("\(collection.totalVerseCount) verses", systemImage: "text.quote")
                    }
                    .font(.bodySmall)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, AppConstants.spacingSmall)
                }
                .frame(height: 220)

                // Groups List
                VStack(spacing: AppConstants.spacingMedium) {
                    let groups = contentViewModel.getGroupsForCollection(collection.id)

                    ForEach(groups) { group in
                        NavigationLink(destination: GroupDetailView(group: group)) {
                            GroupRowView(group: group)
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

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.spacingSmall) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.name)
                        .font(.headingSmall)
                        .foregroundColor(.adaptiveText(colorScheme))

                    Text("\(group.verseCount) verses")
                        .font(.bodySmall)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.textSecondary)
            }

            if let preview = group.arabicPreview {
                Text(preview)
                    .font(.amiriQuran(18))
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
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
            description: "Protection prayers and verses from the Holy Quran",
            icon: "shield",
            sortOrder: 1,
            groupCount: 2,
            totalVerseCount: 10
        ))
    }
    .environmentObject(ContentViewModel())
    .environmentObject(SettingsViewModel())
}
