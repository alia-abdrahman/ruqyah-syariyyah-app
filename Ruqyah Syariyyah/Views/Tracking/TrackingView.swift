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
            VStack(spacing: 0) {
                // Static Header
                GradientHeader(
                    title: "Track Your Practice",
                    subtitle: trackingSubtitle,
                    style: .plain
                )

                // Scrollable Content
                ScrollView {
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

                        // Encouragement Card
                        encouragementCard

                        // Session Controls Section
                        if trackingViewModel.isSessionActive {
                            // Active Session Card
                            VStack(spacing: 16) {
                                Text("Session in Progress")
                                    .font(.poppins(14, weight: .medium))
                                    .foregroundColor(.textSecondary)

                                Text(trackingViewModel.elapsedTimeFormatted)
                                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                                    .foregroundColor(.primaryGreen)

                                HStack(spacing: 16) {
                                    Button {
                                        trackingViewModel.cancelSession()
                                    } label: {
                                        Label("Cancel", systemImage: "xmark")
                                            .font(.poppins(14, weight: .medium))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Color.gray.opacity(0.6))
                                            .cornerRadius(10)
                                    }

                                    Button {
                                        Task {
                                            await trackingViewModel.endSession()
                                        }
                                    } label: {
                                        Label("End", systemImage: "checkmark")
                                            .font(.poppins(14, weight: .medium))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Color.primaryGreen)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                            .padding(AppConstants.spacingLarge)
                            .background(Color.adaptiveSurface(colorScheme))
                            .cornerRadius(AppConstants.radiusLarge)
                            .shadow(color: .black.opacity(0.06), radius: 5, x: 0, y: 3)
                            .padding(.horizontal, AppConstants.spacingMedium)
                            .padding(.top, AppConstants.spacingMedium)
                        } else {
                            // Start Session Button - Attractive Design
                            Button {
                                showStartSession = true
                            } label: {
                                HStack(spacing: 16) {
                                    // Play icon in circle
                                    ZStack {
                                        Circle()
                                            .fill(Color.white.opacity(0.25))
                                            .frame(width: 44, height: 44)

                                        Image(systemName: "play.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(.white)
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Start Session")
                                            .font(.poppins(18, weight: .bold))
                                            .foregroundColor(.white)

                                        Text("Begin your spiritual practice")
                                            .font(.poppins(12, weight: .regular))
                                            .foregroundColor(.white.opacity(0.8))
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [.primaryGreen, .primaryGreenDark],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                            }
                            .padding(.horizontal, AppConstants.spacingMedium)
                            .padding(.top, AppConstants.spacingMedium)
                        }

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
                                    SessionRowView(session: session) {
                                        Task {
                                            await trackingViewModel.deleteSession(session)
                                        }
                                    }
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
            .overlay {
                if trackingViewModel.showSessionComplete {
                    sessionCompleteOverlay
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                withAnimation(.easeOut(duration: 0.4)) {
                                    trackingViewModel.showSessionComplete = false
                                }
                            }
                        }
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: trackingViewModel.showSessionComplete)
            .sheet(isPresented: $showStartSession) {
                startSessionSheet
            }
        }
    }

    // MARK: - Contextual Subtitle
    private var trackingSubtitle: String {
        let streak = trackingViewModel.currentStreak
        let total = trackingViewModel.totalSessions

        if total == 0 {
            return "Begin your spiritual practice journey"
        } else if streak >= 7 {
            return "MashaAllah! \(streak)-day streak"
        } else if streak >= 1 {
            return "\(streak)-day streak — keep it going!"
        } else {
            return "Every session is a step forward"
        }
    }

    // MARK: - Encouragement Card
    private var encouragementCard: some View {
        let streak = trackingViewModel.currentStreak
        let totalSessions = trackingViewModel.totalSessions

        let (message, icon, color): (String, String, Color) = {
            if totalSessions == 0 {
                return (
                    "Start your first session to begin tracking your spiritual practice. Bismillah!",
                    "leaf.fill",
                    .primaryGreen
                )
            } else if streak == 0 {
                return (
                    "No streak yet — and that is perfectly okay. Start a session today and build from here, one day at a time.",
                    "sunrise.fill",
                    .accentGold
                )
            } else if streak < 3 {
                return (
                    "You are building momentum! \(streak) day\(streak == 1 ? "" : "s") so far. Come back tomorrow to keep your streak alive.",
                    "figure.walk",
                    .accentBlue
                )
            } else if streak < 7 {
                return (
                    "SubhanAllah, \(streak) consecutive days! You are building a beautiful habit of spiritual healing.",
                    "flame.fill",
                    .accentGold
                )
            } else {
                return (
                    "MashaAllah, \(streak) days of consistent practice! Your dedication is truly remarkable. May it bring you barakah.",
                    "star.fill",
                    .accentGold
                )
            }
        }()

        return HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 40)

            Text(message)
                .font(.poppins(13, weight: .regular))
                .foregroundColor(.adaptiveText(colorScheme))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppConstants.spacingMedium)
        .background(color.opacity(0.08))
        .cornerRadius(AppConstants.radiusMedium)
        .padding(.horizontal, AppConstants.spacingMedium)
    }

    // MARK: - Session Complete Overlay
    private var sessionCompleteOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        trackingViewModel.showSessionComplete = false
                    }
                }

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.primaryGreen.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Circle()
                        .fill(Color.primaryGreen)
                        .frame(width: 72, height: 72)

                    Image(systemName: "checkmark")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }

                Text("Session Complete!")
                    .font(.headingSmall)
                    .foregroundColor(.adaptiveText(colorScheme))

                Text(trackingViewModel.completionMessage)
                    .font(.poppins(14, weight: .regular))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Text(trackingViewModel.lastCompletedDuration.shortDurationFormatted)
                    .font(.poppins(28, weight: .bold))
                    .foregroundColor(.primaryGreen)

                Button {
                    withAnimation {
                        trackingViewModel.showSessionComplete = false
                    }
                } label: {
                    Text("Continue")
                        .font(.button)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.primaryGreen)
                        .cornerRadius(AppConstants.radiusMedium)
                }
                .padding(.horizontal, 20)
            }
            .padding(AppConstants.spacingLarge)
            .padding(.vertical, 10)
            .background(Color.adaptiveSurface(colorScheme))
            .cornerRadius(AppConstants.radiusXLarge)
            .shadow(color: .black.opacity(0.1), radius: 20)
            .padding(.horizontal, 40)
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
    let onDelete: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var showDeleteConfirmation: Bool = false

    var body: some View {
        HStack(spacing: AppConstants.spacingMedium) {
            Image(systemName: session.type.icon)
                .font(.title3)
                .foregroundColor(.primaryGreen)
                .frame(width: 40, height: 40)
                .background(Color.primaryGreen.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                // Show notes as title if available, otherwise show session type
                Text(session.notes ?? session.type.displayName)
                    .font(.bodyMedium)
                    .foregroundColor(.adaptiveText(colorScheme))
                    .lineLimit(1)

                Text(session.formattedDate)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            HStack(spacing: 6) {
                Text(session.formattedDuration)
                    .font(.poppins(16, weight: .semibold))
                    .foregroundColor(.adaptiveText(colorScheme))

                if session.completed {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.primaryGreen)
                        .font(.system(size: 18))
                }
            }

            // Delete button
            Button {
                showDeleteConfirmation = true
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 16))
                    .foregroundColor(.red.opacity(0.7))
                    .frame(width: 32, height: 32)
            }
        }
        .padding(AppConstants.spacingMedium)
        .background(Color.adaptiveSurface(colorScheme))
        .cornerRadius(AppConstants.radiusMedium)
        .alert("Delete Session", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete this session?")
        }
    }
}

#Preview {
    TrackingView()
        .environmentObject(TrackingViewModel())
}
