import Foundation
import FirebaseFirestore

@MainActor
struct FirestoreService {
    private let auth = AuthService()

    func fetchProfile() async throws -> UserProfile? {
        let userID = try auth.requireUserID()
        let snapshot = try await Firestore.firestore().collection("users").document(userID).getDocument()
        guard snapshot.exists else { return nil }
        return try snapshot.data(as: UserProfile.self)
    }

    func saveProfile(_ profile: UserProfile) async throws {
        let userID = try auth.requireUserID()
        let data = try Firestore.Encoder().encode(profile)
        try await Firestore.firestore().collection("users").document(userID).setData(data, merge: true)
    }

    func fetchRunRecords() async throws -> [RunRecord] {
        let userID = try auth.requireUserID()
        let snapshot = try await Firestore.firestore()
            .collection("users").document(userID).collection("runRecords")
            .order(by: "startedAt", descending: true)
            .limit(to: 100)
            .getDocuments()
        return try snapshot.documents.map { try $0.data(as: RunRecord.self) }
    }

    /// 성공한 기록의 문서 ID를 반환합니다. 같은 ID로 재호출하면 중복 생성하지 않습니다.
    /// 누적 거리는 향후 서버에서 집계할 수 있도록 여기서 변경하지 않습니다.
    @discardableResult
    func saveRunRecord(_ record: RunRecord) async throws -> String {
        let userID = try auth.requireUserID()
        guard record.userID == userID,
              record.distanceMeters.isFinite, record.distanceMeters > 0,
              record.durationSeconds > 0,
              record.finishedAt >= record.startedAt else {
            throw AppError.invalidRunRecord
        }
        let collection = Firestore.firestore().collection("users").document(userID).collection("runRecords")
        let document = record.id.map { collection.document($0) } ?? collection.document()
        try await document.setData(try Firestore.Encoder().encode(record))
        return document.documentID
    }
}
