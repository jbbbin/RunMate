import FirebaseAuth

@MainActor
struct AuthService {
    var currentUserID: String? {
        guard FirebaseConfiguration.isReady else { return nil }
        return Auth.auth().currentUser?.uid
    }

    func requireUserID() throws -> String {
        try FirebaseConfiguration.requireConfigured()
        guard let userID = currentUserID else { throw AppError.signInRequired }
        return userID
    }

    /// Firebase Console → Authentication → Sign-in method에서 Anonymous를 활성화해야 합니다.
    func signInAnonymously() async throws -> String {
        try FirebaseConfiguration.requireConfigured()
        if let userID = currentUserID { return userID }
        return try await Auth.auth().signInAnonymously().user.uid
    }

    func signOut() throws {
        try FirebaseConfiguration.requireConfigured()
        try Auth.auth().signOut()
    }
}
