import Foundation
import FirebaseFirestore

/// Firestore: users/{Firebase Auth UID}
struct UserProfile: Codable, Identifiable {
    @DocumentID var id: String?
    var nickname: String
    var profileImageURL: URL?
    /// 거리 단위는 앱 전체에서 미터로 통일합니다.
    var totalDistanceMeters: Double = 0
    var createdAt: Date = .now
}
