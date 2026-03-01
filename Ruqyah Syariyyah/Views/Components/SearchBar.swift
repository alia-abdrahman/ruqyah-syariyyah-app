import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search"
    var onSubmit: (() -> Void)?

    @FocusState private var isFocused: Bool

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: AppConstants.spacingSmall) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.textSecondary)

            TextField(placeholder, text: $text)
                .font(.bodyMedium)
                .focused($isFocused)
                .onSubmit {
                    onSubmit?()
                }

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .padding(.horizontal, AppConstants.spacingMedium)
        .padding(.vertical, 14)
        .background(colorScheme == .dark ? Color.gray.opacity(0.15) : Color.gray.opacity(0.08))
        .cornerRadius(AppConstants.radiusLarge)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.radiusLarge)
                .stroke(isFocused ? Color.primaryGreen : Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        SearchBar(text: .constant(""))
        SearchBar(text: .constant("Al-Fatihah"))
    }
    .padding()
}
