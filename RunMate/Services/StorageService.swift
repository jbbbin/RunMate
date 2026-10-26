import Foundation
import FirebaseStorage

@MainActor
struct StorageService {
    /// 업로드 성공 후 URL을 UserProfile.profileImageURL에 저장하면 됩니다.
    func uploadProfileImage(jpegData: Data) async throws -> URL {
        let userID = try AuthService().requireUserID()
        guard !jpegData.isEmpty, jpegData.count <= 5 * 1_024 * 1_024,
              jpegData.starts(with: [0xFF, 0xD8, 0xFF]) else {
            throw AppError.invalidImage
        }
        let reference = Storage.storage().reference().child("users/\(userID)/profile.jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        _ = try await reference.putDataAsync(jpegData, metadata: metadata)
        return try await reference.downloadURL()
    }
}
