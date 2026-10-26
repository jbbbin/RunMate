import Foundation

enum JourneyLocation: String, Codable, CaseIterable, Identifiable {
    case seoul
    case suwon

    var id: String { rawValue }
    var name: String { self == .seoul ? "서울" : "수원" }
    var runningImage: String { self == .seoul ? "SeoulRunning" : "Suwon" }
    var roomImage: String { self == .seoul ? "SeoulRooms" : "Suwon" }
}

enum JourneyRoomKind: String, Codable {
    case personal
    case group

    var capacity: Int { self == .personal ? 1 : 6 }
}

struct RoomMember: Codable, Identifiable, Equatable {
    let id: String
    let nickname: String
    var isRunning = false
}

/// 한 사용자는 여러 방에 참여할 수 있습니다. 핀은 방 공통 속성이 아닌 사용자별 선택입니다.
/// 현재 화면 단계에서는 로컬 미리보기 데이터이며, 실제 Firestore 문서는 아직 생성하지 않습니다.
struct JourneyRoom: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let kind: JourneyRoomKind
    let ownerID: String
    let members: [RoomMember]
    let location: JourneyLocation
    let nextCheckpointName: String
    let targetDistanceMeters: Double
    let completedDistanceMeters: Double

    var capacity: Int { kind.capacity }
    var progress: Double { min(completedDistanceMeters / targetDistanceMeters, 1) }
    var remainingDistanceMeters: Double { max(targetDistanceMeters - completedDistanceMeters, 0) }

    init(
        id: String,
        name: String,
        kind: JourneyRoomKind,
        ownerID: String,
        members: [RoomMember],
        location: JourneyLocation,
        nextCheckpointName: String,
        targetDistanceMeters: Double,
        completedDistanceMeters: Double
    ) throws {
        guard !id.isEmpty,
              !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !members.isEmpty, members.count <= kind.capacity,
              Set(members.map(\.id)).count == members.count,
              members.allSatisfy({ !$0.id.isEmpty }),
              members.contains(where: { $0.id == ownerID }),
              targetDistanceMeters.isFinite, targetDistanceMeters > 0,
              completedDistanceMeters.isFinite, completedDistanceMeters >= 0 else {
            throw RoomValidationError.invalidRoom
        }
        self.id = id
        self.name = name
        self.kind = kind
        self.ownerID = ownerID
        self.members = members
        self.location = location
        self.nextCheckpointName = nextCheckpointName
        self.targetDistanceMeters = targetDistanceMeters
        self.completedDistanceMeters = completedDistanceMeters
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, kind, ownerID, members, location, nextCheckpointName
        case targetDistanceMeters, completedDistanceMeters
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            id: values.decode(String.self, forKey: .id),
            name: values.decode(String.self, forKey: .name),
            kind: values.decode(JourneyRoomKind.self, forKey: .kind),
            ownerID: values.decode(String.self, forKey: .ownerID),
            members: values.decode([RoomMember].self, forKey: .members),
            location: values.decode(JourneyLocation.self, forKey: .location),
            nextCheckpointName: values.decode(String.self, forKey: .nextCheckpointName),
            targetDistanceMeters: values.decode(Double.self, forKey: .targetDistanceMeters),
            completedDistanceMeters: values.decode(Double.self, forKey: .completedDistanceMeters)
        )
    }
}

enum RoomValidationError: LocalizedError {
    case invalidRoom
    case invalidName

    var errorDescription: String? {
        switch self {
        case .invalidRoom: return "개인 여정은 1명, 친구 방은 방장을 포함해 최대 6명으로 구성해 주세요."
        case .invalidName: return "방 이름을 1~20자로 입력해 주세요."
        }
    }
}

extension Double {
    var journeyKilometers: String {
        (self / 1_000).formatted(
            .number.grouping(.never).precision(.fractionLength(0...2)).locale(Locale(identifier: "ko_KR"))
        )
    }
}
