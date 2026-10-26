import Foundation

enum AppError: LocalizedError {
    case firebaseNotConfigured
    case signInRequired
    case invalidRunRecord
    case invalidImage

    var errorDescription: String? {
        switch self {
        case .firebaseNotConfigured:
            return "Firebase 설정이 필요합니다. 프로젝트의 README를 확인해 주세요."
        case .signInRequired:
            return "먼저 로그인해 주세요."
        case .invalidRunRecord:
            return "거리, 운동 시간, 시작·종료 시간을 확인해 주세요."
        case .invalidImage:
            return "프로필 사진은 5MB 이하의 JPEG 파일을 사용해 주세요."
        }
    }
}
