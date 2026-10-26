import Foundation
import FirebaseFirestore

/// Firestore: users/{uid}/runRecords/{recordID}
struct RunRecord: Codable, Identifiable {
    @DocumentID var id: String?
    var userID: String
    var distanceMeters: Double
    var durationSeconds: Int
    var startedAt: Date
    var finishedAt: Date

    var averagePaceSecondsPerKilometer: Double? {
        guard distanceMeters > 0, durationSeconds > 0 else { return nil }
        return Double(durationSeconds) / (distanceMeters / 1_000)
    }
}
