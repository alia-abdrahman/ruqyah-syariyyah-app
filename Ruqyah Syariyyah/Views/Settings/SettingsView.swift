import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var contentViewModel: ContentViewModel
    @Environment(\.colorScheme) private var colorScheme

    @State private var showResetConfirmation: Bool = false

    var body: some View {
        NavigationStack {
            List {
                // Appearance Section
                Section {
                    // Theme
                    Picker("Theme", selection: $settingsViewModel.themeMode) {
                        ForEach(ThemeMode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }

                    // Language
                    Picker("Translation Language", selection: $settingsViewModel.language) {
                        ForEach(Language.allCases, id: \.self) { lang in
                            Text(lang.displayName).tag(lang)
                        }
                    }
                    .onChange(of: settingsViewModel.language) { _, newValue in
                        contentViewModel.setLanguage(newValue)
                    }

                    // Arabic Text Size
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Arabic Text Size")
                            Spacer()
                            Text(settingsViewModel.textSizeLabel)
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
                } header: {
                    Text("Appearance")
                }

                // Reminders Section
                Section {
                    Toggle("Daily Reminder", isOn: $settingsViewModel.reminderEnabled)
                        .tint(.primaryGreen)

                    if settingsViewModel.reminderEnabled {
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
                                        .foregroundColor(.primaryGreen)
                                }
                            }
                        } else {
                            DatePicker(
                                "Reminder Time",
                                selection: $settingsViewModel.reminderTime,
                                displayedComponents: .hourAndMinute
                            )
                        }
                    }
                } header: {
                    Text("Reminders")
                } footer: {
                    Text("Receive a daily reminder to practice your spiritual healing routine")
                }

                // About Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("\(settingsViewModel.appVersion) (\(settingsViewModel.buildNumber))")
                            .foregroundColor(.textSecondary)
                    }

                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        HStack {
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.textSecondary)
                        }
                    }
                    .foregroundColor(.adaptiveText(colorScheme))

                    Link(destination: URL(string: "https://example.com/terms")!) {
                        HStack {
                            Text("Terms of Service")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.textSecondary)
                        }
                    }
                    .foregroundColor(.adaptiveText(colorScheme))
                } header: {
                    Text("About")
                }

                // Reset Section
                Section {
                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset All Settings")
                        }
                    }
                } footer: {
                    Text("This will reset all settings to their default values")
                }
            }
            .navigationTitle("Settings")
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
}

#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel())
        .environmentObject(ContentViewModel())
}
