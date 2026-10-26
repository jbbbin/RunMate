import Foundation
import Observation

@MainActor
@Observable
final class AppSession {
    private(set) var userID: String?
    private(set) var profile: UserProfile?
    private(set) var records: [RunRecord] = []
    private(set) var isBusy = false
    var errorMessage: String?

    private let auth = AuthService()
    private let firestore = FirestoreService()
    private var didRestore = false

    var isFirebaseReady: Bool { FirebaseConfiguration.isReady }
    var setupMessage: String { FirebaseConfiguration.setupMessage }

    func restoreSession() async {
        guard !didRestore else { return }
        didRestore = true
        guard isFirebaseReady else { return }
        userID = auth.currentUserID
        if userID != nil { await refresh() }
    }

    func signInAsGuest() async {
        guard !isBusy else { return }
        isBusy = true
        defer { isBusy = false }
        do {
            userID = try await auth.signInAnonymously()
            try await loadData()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refresh() async {
        guard !isBusy, userID != nil else { return }
        isBusy = true
        defer { isBusy = false }
        do {
            try await loadData()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        guard !isBusy else { return }
        do {
            try auth.signOut()
            userID = nil
            profile = nil
            records = []
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadData() async throws {
        if let existing = try await firestore.fetchProfile() {
            profile = existing
        } else {
            let newProfile = UserProfile(nickname: "러너")
            try await firestore.saveProfile(newProfile)
            profile = try await firestore.fetchProfile()
        }
        records = try await firestore.fetchRunRecords()
    }
}
