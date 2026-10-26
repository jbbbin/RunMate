import Foundation
import Observation

/// 메인 화면 검토용 저장소입니다. Auth UID/Firestore 데이터와 섞지 않습니다.
/// 다음 단계에서 Firestore 방 repository로 교체할 경계입니다.
@MainActor
@Observable
final class RoomStore {
    static let previewUserID = "preview-self"
    private static let storageKey = "RunMate.mainPreview.v1"

    private(set) var rooms: [JourneyRoom]
    private(set) var pinnedRoomID: String
    private let defaults: UserDefaults

    var pinnedRoom: JourneyRoom? {
        rooms.first { $0.id == pinnedRoomID } ?? rooms.first { $0.kind == .personal }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: Self.storageKey),
           let saved = try? JSONDecoder().decode(SavedState.self, from: data),
           saved.rooms.filter({ $0.kind == .personal }).count == 1,
           saved.rooms.allSatisfy({ $0.members.contains(where: { $0.id == Self.previewUserID }) }),
           Set(saved.rooms.map(\.id)).count == saved.rooms.count,
           let personal = saved.rooms.first(where: { $0.kind == .personal }) {
            rooms = saved.rooms
            pinnedRoomID = saved.rooms.contains(where: { $0.id == saved.pinnedRoomID })
                ? saved.pinnedRoomID : personal.id
        } else {
            // 고정된 샘플도 실제 방 모델의 정원·멤버 검증을 거쳐 생성합니다.
            rooms = Self.makePreviewRooms()
            pinnedRoomID = "personal-preview"
        }
    }

    func pin(_ roomID: String) {
        guard rooms.contains(where: { $0.id == roomID }) else { return }
        pinnedRoomID = roomID
        persist()
    }

    @discardableResult
    func createGroup(name: String, pinAfterCreating: Bool) throws -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.count <= 20 else { throw RoomValidationError.invalidName }
        let room = try JourneyRoom(
            id: UUID().uuidString,
            name: trimmed,
            kind: .group,
            ownerID: Self.previewUserID,
            members: [RoomMember(id: Self.previewUserID, nickname: "나")],
            location: .seoul,
            nextCheckpointName: "수원",
            targetDistanceMeters: 30_000,
            completedDistanceMeters: 0
        )
        rooms.append(room)
        if pinAfterCreating { pinnedRoomID = room.id }
        persist()
        return room.id
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(SavedState(rooms: rooms, pinnedRoomID: pinnedRoomID)) else { return }
        defaults.set(data, forKey: Self.storageKey)
    }

    private struct SavedState: Codable {
        let rooms: [JourneyRoom]
        let pinnedRoomID: String
    }

    private static func makePreviewRooms() -> [JourneyRoom] {
        let me = RoomMember(id: previewUserID, nickname: "나")
        do {
            return [
                try JourneyRoom(
                    id: "personal-preview", name: "나의 여정", kind: .personal,
                    ownerID: previewUserID, members: [me], location: .seoul,
                    nextCheckpointName: "수원", targetDistanceMeters: 30_000, completedDistanceMeters: 10_000
                ),
                try JourneyRoom(
                    id: "ccbb-preview", name: "시시비비", kind: .group,
                    ownerID: previewUserID,
                    members: [me] + ["빈", "젠", "하르딘", "비비", "루크"].enumerated().map {
                        RoomMember(id: "preview-friend-\($0.offset)", nickname: $0.element)
                    },
                    location: .suwon, nextCheckpointName: "천안",
                    targetDistanceMeters: 160_000, completedDistanceMeters: 5_000
                )
            ]
        } catch {
            assertionFailure("기본 방 데이터 검증 실패: \(error)")
            return []
        }
    }
}
