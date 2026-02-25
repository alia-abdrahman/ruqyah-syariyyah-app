import Foundation
import SwiftData

@Model
final class SessionRecord {
    @Attribute(.unique) var id: UUID
    var date: Date
    var durationSeconds: Int
    var sessionType: String
    var notes: String?
    var completed: Bool

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        durationSeconds: Int = 0,
        sessionType: SessionType = .reading,
        notes: String? = nil,
        completed: Bool = false
    ) {
        self.id = id
        self.date = date
        self.durationSeconds = durationSeconds
        self.sessionType = sessionType.rawValue
        self.notes = notes
        self.completed = completed
    }

    var type: SessionType {
        SessionType(rawValue: sessionType) ?? .reading
    }

    var formattedDuration: String {
        let hours = durationSeconds / 3600
        let minutes = (durationSeconds % 3600) / 60
        let seconds = durationSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Favorite Verse Model
@Model
final class FavoriteVerse {
    @Attribute(.unique) var verseKey: String
    var dateAdded: Date

    init(verseKey: String, dateAdded: Date = Date()) {
        self.verseKey = verseKey
        self.dateAdded = dateAdded
    }
}
