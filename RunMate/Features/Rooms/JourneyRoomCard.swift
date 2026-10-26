import SwiftUI

struct JourneyRoomCard: View {
    let room: JourneyRoom
    let isPinned: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                if isPinned {
                    Image("PinnedRoomIcon").resizable().frame(width: 15, height: 20)
                        .accessibilityHidden(true)
                }
                Text(room.name).font(JourneyFont.labelBold).lineLimit(1)
                    .padding(.horizontal, 16).padding(.vertical, 5)
                    .background(.white.opacity(0.45), in: Capsule())
                Spacer(minLength: 8)
                if room.kind == .group {
                    Text("\(room.members.count) / \(room.capacity)명").font(JourneyFont.caption)
                }
            }
            .frame(minHeight: 28).padding(.bottom, 18)
            Text(room.location.name).font(JourneyFont.title).padding(.bottom, 4)
            Text("\(room.targetDistanceMeters.journeyKilometers)km 중 \(Text("\(room.completedDistanceMeters.journeyKilometers)km").font(JourneyFont.bodyBold))")
                .font(JourneyFont.body)
            ProgressView(value: room.progress)
                .progressViewStyle(JourneyProgressStyle(fillImage: isPinned ? "JourneyProgressFill" : "RoomProgressFill"))
                .padding(.top, 12).accessibilityHidden(true)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 24)
        .frame(maxWidth: .infinity, minHeight: 179, alignment: .leading)
        .background {
            GeometryReader { geometry in
                ZStack {
                    Image("JourneyNoise").resizable().opacity(0.2)
                    Image(room.location.roomImage).resizable().scaledToFill()
                    Color.black.opacity(0.3)
                }
                .frame(width: geometry.size.width, height: geometry.size.height).clipped()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay { RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.25), lineWidth: 1) }
        .shadow(color: .black.opacity(0.25), radius: 10, y: 12)
    }
}
