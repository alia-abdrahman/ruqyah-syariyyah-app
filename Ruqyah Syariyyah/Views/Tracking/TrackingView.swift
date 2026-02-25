import SwiftUI

struct TrackingView: View {
    @EnvironmentObject var trackingViewModel: TrackingViewModel
    @Environment(\.colorScheme) private var colorScheme

    @State private var showStartSession: Bool = false
    @State private var selectedSessionType: SessionType = .reading
    @State private var sessionNotes: String = ""

    private let columns = [
        GridItem(.flexible(), spacing: AppConstants.spacingMedium),
        GridItem(.flexible(), spacing: AppConstants.spacingMedium)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header with Timer
                    GeometryReader { geometry in
                        ZStack {
                            LinearGradient(
                                colors: [.primaryGreen, .primaryGreenDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )

                            VStack(spacing: 12) {
                                Spacer()
                                    .frame(height: geometry.safeAreaInsets.top + 16)

                                if trackingViewModel.isSessionActive {
                                    // Active Session
                                    Text("Session in Progress")
                                        .font(.poppins(14, weight: .regular))
                                        .foregroundColor(.white.opacity(0.85))

                                    Text(trackingViewModel.elapsedTimeFormatted)
                                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                                        .foregroundColor(.white)

                                    HStack(spacing: 16) {
                                        Button {
                                            trackingViewModel.cancelSession()
                                        } label: {
                                            Label("Cancel", systemImage: "xmark")
                                                .font(.poppins(14, weight: .medium))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 10)
                                                .background(Color.white.opacity(0.2))
                                                .cornerRadius(10)
                                        }

                                        Button {
                                            Task {
                                                await trackingViewModel.endSession()
                                            }
                                        } label: {
                                            Label("End", systemImage: "checkmark")
                                                .font(.poppins(14, weight: .medium))
                                                .foregroundColor(.primaryGreen)
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 10)
                                                .background(Color.white)
                                                .cornerRadius(10)
                                        }
                                    }
                                } else {
                                    // Start Session
                                    Text("Track Your Practice")
                                        .font(.poppins(28, weight: .bold))
                                        .foregroundColor(.white)

                                    Text("Build consistency with daily sessions")
                                        .font(.poppins(14, weight: .regular))
                                        .foregroundColor(.white.opacity(0.85))

                                    Button {
                                        showStartSession = true
                                    } label: {
                                        Label("Start Session", systemImage: "play.fill")
                                            .font(.poppins(14, weight: .semibold))
                                            .foregroundColor(.primaryGreen)
                                            .padding(.horizontal, 24)
                                            .padding(.vertical, 12)
                                            .background(Color.white)
                                            .cornerRadius(12)
                                    }
                                    .padding(.top, 4)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                        }
                    }
                    .frame(height: 220)

                    // Stats Section
                    VStack(alignment: .leading, spacing: AppConstants.spacingMedium) {
                        Text("Statistics")
                            .font(.headingSmall)
                            .foregroundColor(.adaptiveText(colorScheme))
                            .padding(.horizontal, AppConstants.spacingMedium)

                        LazyVGrid(columns: columns, spacing: AppConstants.spacingMedium) {
                            StatCard(
                                title: "Total Sessions",
                                value: "\(trackingViewModel.totalSessions)",
                                icon: "checkmark.circle.fill"
                            )

                            StatCard(
                                title: "Total Minutes",
                                value: "\(trackingViewModel.totalMinutes)",
                                icon: "clock.fill",
                                color: .accentBlue
                            )

                            StatCard(
                                title: "Current Streak",
                                value: "\(trackingViewModel.currentStreak) days",
                                icon: "flame.fill",
                                color: .accentGold
                            )

                            StatCard(
                                title: "This Week",
                                value: "\(trackingViewModel.thisWeekSessions)",
                                icon: "calendar",
                                color: .accentPurple
                            )
                        }
                        .padding(.horizontal, AppConstants.spacingMedium)

                        // Recent Sessions
                        Text("Recent Sessions")
                            .font(.headingSmall)
                            .foregroundColor(.adaptiveText(colorScheme))
                            .padding(.horizontal, AppConstants.spacingMedium)
                            .padding(.top, AppConstants.spacingMedium)

                        if trackingViewModel.sessions.isEmpty {
                            ContentUnavailableView(
                                "No Sessions Yet",
                                systemImage: "clock",
                                description: Text("Start your first session to track your progress")
                            )
                            .frame(height: 150)
                        } else {
                            LazyVStack(spacing: AppConstants.spacingSmall) {
                                ForEach(trackingViewModel.recentSessions) { session in
                                    SessionRowView(session: session)
                                }
                            }
                            .padding(.horizontal, AppConstants.spacingMedium)
                        }
                    }
                    .padding(.top, AppConstants.spacingMedium)
                    .padding(.bottom, AppConstants.spacingXLarge)
                }
            }
            .background(Color.adaptiveBackground(colorScheme))
            .ignoresSafeArea(edges: .top)
            .sheet(isPresented: $showStartSession) {
                startSessionSheet
            }
        }
    }

    // MARK: - Start Session Sheet
    private var startSessionSheet: some View {
        NavigationStack {
            VStack(spacing: AppConstants.spacingLarge) {
                Text("Start a Session")
                    .font(.headingMedium)
                    .foregroundColor(.adaptiveText(colorScheme))

                // Session Type Picker
                VStack(alignment: .leading, spacing: AppConstants.spacingSmall) {
                    Text("Session Type")
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)

                    HStack(spacing: AppConstants.spacingMedium) {
                        ForEach(SessionType.allCases, id: \.self) { type in
                            Button {
                                selectedSessionType = type
                            } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: type.icon)
                                        .font(.title2)
                                    Text(type.displayName)
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(selectedSessionType == type ? Color.primaryGreen : Color.adaptiveSurface(colorScheme))
                                .foregroundColor(selectedSessionType == type ? .white : .textSecondary)
                                .cornerRadius(AppConstants.radiusMedium)
                            }
                        }
                    }
                }

                // Notes
                VStack(alignment: .leading, spacing: AppConstants.spacingSmall) {
                    Text("Notes (optional)")
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)

                    TextField("Add notes about your session...", text: $sessionNotes, axis: .vertical)
                        .lineLimit(3...6)
                        .padding()
                        .background(Color.adaptiveSurface(colorScheme))
                        .cornerRadius(AppConstants.radiusMedium)
                }

                Spacer()

                Button {
                    trackingViewModel.startSession(type: selectedSessionType, notes: sessionNotes.isEmpty ? nil : sessionNotes)
                    sessionNotes = ""
                    showStartSession = false
                } label: {
                    Text("Start Session")
                        .font(.button)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.primaryGreen)
                        .cornerRadius(AppConstants.radiusLarge)
                }
            }
            .padding(AppConstants.spacingLarge)
            .background(Color.adaptiveBackground(colorScheme))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        showStartSession = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Session Row View
struct SessionRowView: View {
    let session: SessionRecord

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: AppConstants.spacingMedium) {
            Image(systemName: session.type.icon)
                .font(.title3)
                .foregroundColor(.primaryGreen)
                .frame(width: 40, height: 40)
                .background(Color.primaryGreen.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(session.type.displayName)
                    .font(.bodyMedium)
                    .foregroundColor(.adaptiveText(colorScheme))

                Text(session.formattedDate)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(session.formattedDuration)
                    .font(.bodyMedium)
                    .foregroundColor(.adaptiveText(colorScheme))

                if session.completed {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.primaryGreen)
                        .font(.caption)
                }
            }
        }
        .padding(AppConstants.spacingMedium)
        .background(Color.adaptiveSurface(colorScheme))
        .cornerRadius(AppConstants.radiusMedium)
    }
}

#Preview {
    TrackingView()
        .environmentObject(TrackingViewModel())
}
