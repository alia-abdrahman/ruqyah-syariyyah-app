import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var contentViewModel: ContentViewModel
    @Environment(\.colorScheme) private var colorScheme

    @State private var showResetConfirmation: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Static Header
                GradientHeader(
                    title: "Settings",
                    subtitle: "Customize your experience",
                    style: .plain
                )

                // Scrollable Content
                ScrollView {
                    VStack(spacing: AppConstants.spacingMedium) {
                        // Appearance Section
                        SettingsSection(title: "Appearance") {
                            // Theme
                            SettingsRow {
                                Picker("Theme", selection: $settingsViewModel.themeMode) {
                                    ForEach(ThemeMode.allCases, id: \.self) { mode in
                                        Text(mode.displayName).tag(mode)
                                    }
                                }
                            }

                            Divider()

                            // Language
                            SettingsRow {
                                Picker("Translation Language", selection: $settingsViewModel.language) {
                                    ForEach(Language.allCases, id: \.self) { lang in
                                        Text(lang.displayName).tag(lang)
                                    }
                                }
                                .onChange(of: settingsViewModel.language) { _, newValue in
                                    contentViewModel.setLanguage(newValue)
                                }
                            }

                            Divider()

                            // Arabic Text Size
                            SettingsRow {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Arabic Text Size")
                                            .font(.poppins(15, weight: .regular))
                                        Spacer()
                                        Text(settingsViewModel.textSizeLabel)
                                            .font(.poppins(14, weight: .regular))
                                            .foregroundColor(.textSecondary)
                                    }

                                    Slider(
                                        value: $settingsViewModel.arabicTextSize,
                                        in: SettingsViewModel.textSizeRange,
                                        step: 2
                                    )
                                    .tint(.primaryGreen)

                                    Text("بِسْمِ ٱللَّهِ")
                                        .font(.amiriQuran(settingsViewModel.arabicTextSize))
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.vertical, 8)
                                }
                            }
                        }

                        // Reminders Section
                        SettingsSection(title: "Reminders") {
                            SettingsRow {
                                Toggle("Daily Reminder", isOn: $settingsViewModel.reminderEnabled)
                                    .tint(.primaryGreen)
                                    .font(.poppins(15, weight: .regular))
                            }

                            if settingsViewModel.reminderEnabled {
                                Divider()

                                SettingsRow {
                                    if !settingsViewModel.isNotificationAuthorized {
                                        Button {
                                            Task {
                                                await settingsViewModel.requestNotificationPermission()
                                            }
                                        } label: {
                                            HStack {
                                                Image(systemName: "bell.badge")
                                                    .foregroundColor(.accentGold)
                                                Text("Enable Notifications")
                                                    .font(.poppins(15, weight: .regular))
                                                    .foregroundColor(.primaryGreen)
                                            }
                                        }
                                    } else {
                                        DatePicker(
                                            "Reminder Time",
                                            selection: $settingsViewModel.reminderTime,
                                            displayedComponents: .hourAndMinute
                                        )
                                        .font(.poppins(15, weight: .regular))
                                    }
                                }
                            }
                        }

                        // About Section
                        SettingsSection(title: "About") {
                            SettingsRow {
                                HStack {
                                    Text("Version")
                                        .font(.poppins(15, weight: .regular))
                                    Spacer()
                                    Text("\(settingsViewModel.appVersion) (\(settingsViewModel.buildNumber))")
                                        .font(.poppins(14, weight: .regular))
                                        .foregroundColor(.textSecondary)
                                }
                            }

                            Divider()

                            SettingsRow {
                                Link(destination: URL(string: "https://example.com/privacy")!) {
                                    HStack {
                                        Text("Privacy Policy")
                                            .font(.poppins(15, weight: .regular))
                                            .foregroundColor(.adaptiveText(colorScheme))
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundColor(.textSecondary)
                                    }
                                }
                            }

                            Divider()

                            SettingsRow {
                                Link(destination: URL(string: "https://example.com/terms")!) {
                                    HStack {
                                        Text("Terms of Service")
                                            .font(.poppins(15, weight: .regular))
                                            .foregroundColor(.adaptiveText(colorScheme))
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundColor(.textSecondary)
                                    }
                                }
                            }
                        }

                        // Support Section
                        SettingsSection(title: "Support") {
                            SettingsRow {
                                Button {
                                    shareApp()
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.system(size: 18))
                                            .foregroundColor(.primaryGreen)
                                            .frame(width: 28)

                                        Text("Share App")
                                            .font(.poppins(15, weight: .regular))
                                            .foregroundColor(.adaptiveText(colorScheme))

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundColor(.textSecondary)
                                    }
                                }
                            }

                            Divider()

                            SettingsRow {
                                Link(destination: URL(string: "https://apps.apple.com/app/id6760955875")!) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(.accentGold)
                                            .frame(width: 28)

                                        Text("Rate App")
                                            .font(.poppins(15, weight: .regular))
                                            .foregroundColor(.adaptiveText(colorScheme))

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundColor(.textSecondary)
                                    }
                                }
                            }

                            Divider()

                            SettingsRow {
                                Link(destination: URL(string: "https://buymeacoffee.com/codedancoffee")!) {
                                    HStack(spacing: 12) {
                                        Text("☕")
                                            .font(.system(size: 22))
                                            .frame(width: 28)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Buy Me a Coffee")
                                                .font(.poppins(15, weight: .regular))
                                                .foregroundColor(.adaptiveText(colorScheme))
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundColor(.textSecondary)
                                    }
                                }
                            }
                        }

                        // Reset Section
                        SettingsSection(title: "Data") {
                            SettingsRow {
                                Button(role: .destructive) {
                                    showResetConfirmation = true
                                } label: {
                                    HStack {
                                        Image(systemName: "arrow.counterclockwise")
                                        Text("Reset All Settings")
                                            .font(.poppins(15, weight: .regular))
                                    }
                                    .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, AppConstants.spacingMedium)
                    .padding(.top, AppConstants.spacingMedium)
                    .padding(.bottom, AppConstants.spacingXLarge)
                }
            }
            .background(Color.adaptiveBackground(colorScheme))
            .ignoresSafeArea(edges: .top)
            .confirmationDialog(
                "Reset Settings?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset", role: .destructive) {
                    settingsViewModel.resetAllSettings()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will reset all settings to their default values. This action cannot be undone.")
            }
        }
    }

    private func shareApp() {
        let appURL = URL(string: "https://apps.apple.com/app/id6760955875")!
        let text = "Check out MyRuqyah - an app for spiritual healing through Quran and Sunnah."
        let activityVC = UIActivityViewController(
            activityItems: [text, appURL],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = window
                popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Settings Section
struct SettingsSection<Content: View>: View {
    let title: String
    let content: () -> Content
    @Environment(\.colorScheme) private var colorScheme

    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.spacingSmall) {
            Text(title.uppercased())
                .font(.poppins(12, weight: .semibold))
                .foregroundColor(.textSecondary)
                .padding(.horizontal, AppConstants.spacingSmall)

            VStack(spacing: 0) {
                content()
            }
            .background(Color.adaptiveSurface(colorScheme))
            .cornerRadius(AppConstants.radiusMedium)
        }
    }
}

// MARK: - Settings Row
struct SettingsRow<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .padding(AppConstants.spacingMedium)
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel())
        .environmentObject(ContentViewModel())
}
