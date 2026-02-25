import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search"
    var onSubmit: (() -> Void)?

    @FocusState private var isFocused: Bool

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
        .padding(.vertical, 12)
        .background(Color.backgroundLight)
        .cornerRadius(AppConstants.radiusLarge)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.radiusLarge)
                .stroke(isFocused ? Color.primaryGreen : Color.clear, lineWidth: 2)
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
