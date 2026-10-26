import Foundation
import FirebaseCore

@MainActor
enum FirebaseConfiguration {
    static var isReady: Bool { FirebaseApp.app() != nil }
    private(set) static var setupMessage = "GoogleService-Info.plist를 RunMate/Resources 폴더에 추가해 주세요."

    static func configure() {
        guard !isReady else { return }
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
            return
        }
        guard let options = FirebaseOptions(contentsOfFile: path),
              let projectID = options.projectID, !projectID.isEmpty,
              let apiKey = options.apiKey, !apiKey.isEmpty else {
            setupMessage = "Firebase Console에서 올바른 GoogleService-Info.plist를 다시 다운로드해 주세요."
            return
        }
        guard options.bundleID == Bundle.main.bundleIdentifier else {
            setupMessage = "Firebase 앱과 Xcode의 Bundle Identifier가 다릅니다. 현재 앱: \(Bundle.main.bundleIdentifier ?? "알 수 없음")"
            return
        }
        FirebaseApp.configure(options: options)
    }

    static func requireConfigured() throws {
        guard isReady else { throw AppError.firebaseNotConfigured }
    }
}
