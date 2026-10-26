import SwiftUI

enum JourneyFont {
    static let title = Font.custom("Pretendard-Bold", size: 28, relativeTo: .title)
    static let distance = Font.custom("Pretendard-Bold", size: 36, relativeTo: .largeTitle)
    static let body = Font.custom("Pretendard-Regular", size: 16, relativeTo: .callout)
    static let bodyBold = Font.custom("Pretendard-Bold", size: 16, relativeTo: .callout)
    static let label = Font.custom("Pretendard-Regular", size: 14, relativeTo: .subheadline)
    static let labelBold = Font.custom("Pretendard-Bold", size: 14, relativeTo: .subheadline)
    static let caption = Font.custom("Pretendard-Regular", size: 13, relativeTo: .footnote)
}

extension Color {
    static let journeySecondaryText = Color(white: 218.0 / 255)
}

struct JourneyBackground: View {
    let imageName: String
    var dimmed = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("JourneyNoise").resizable()
                Image(imageName).resizable().scaledToFill()
                if dimmed { Color.black.opacity(0.6) }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

struct JourneyProgressStyle: ProgressViewStyle {
    var fillImage = "JourneyProgressFill"

    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(.white.opacity(0.5))
                if let fraction = configuration.fractionCompleted, fraction > 0 {
                    Image(fillImage).resizable()
                        .frame(width: geometry.size.width * min(max(fraction, 0), 1), height: 17)
                }
            }
            .clipShape(Capsule())
        }
        .frame(height: 17)
    }
}

struct JourneyCheckpointCard: View {
    let room: JourneyRoom

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Image("PinnedJourneyIcon").resizable().frame(width: 15, height: 20)
                    .accessibilityHidden(true)
                Text(room.name).font(JourneyFont.bodyBold).lineLimit(1)
            }
            .foregroundStyle(Color.journeySecondaryText)
            .padding(.bottom, 20)

            Text("다음 체크포인트, \(Text("\(room.nextCheckpointName)까지").font(JourneyFont.bodyBold).foregroundStyle(.white))")
                .font(JourneyFont.body)
                .foregroundStyle(Color.journeySecondaryText)
            Text("\(room.remainingDistanceMeters.journeyKilometers)Km")
                .font(JourneyFont.distance).foregroundStyle(.white).monospacedDigit()
                .padding(.top, 4).padding(.bottom, 8)
            ProgressView(value: room.progress)
                .progressViewStyle(JourneyProgressStyle())
                .accessibilityLabel("다음 체크포인트까지의 진행률")
            Text("\(room.targetDistanceMeters.journeyKilometers)km")
                .font(JourneyFont.caption).foregroundStyle(Color.journeySecondaryText)
                .frame(maxWidth: .infinity, alignment: .trailing).padding(.top, 6)
        }
        .padding(.horizontal, 20).padding(.top, 15).padding(.bottom, 10)
        .frame(maxWidth: .infinity, minHeight: 179, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .environment(\.colorScheme, .dark)
        .overlay {
            RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.2), lineWidth: 1)
        }
    }
}

struct JourneyRunner: View {
    let room: JourneyRoom
    var currentUserID = "preview-self"

    private var runningFriends: Int {
        room.members.filter { $0.id != currentUserID && $0.isRunning }.count
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image("FriendRestingIcon").resizable().frame(width: 17, height: 18)
                    .accessibilityHidden(true)
                Text(runningFriends == 0 ? "지금 친구들은 휴식 중!" : "\(runningFriends)명의 친구가 달리는 중!")
                    .font(JourneyFont.label).foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 16).padding(.vertical, 6)
            .background(.white.opacity(0.2), in: Capsule())
            .overlay { Capsule().strokeBorder(.white.opacity(0.3), lineWidth: 1) }

            // PNG 캔버스 비율 대신 Figma 이미지 레이어의 225:219 비율로 표시합니다.
            Image("RunnerIdle").resizable().frame(width: 225, height: 219)
                .accessibilityLabel("휴식 중인 러너 캐릭터")
        }
    }
}

struct JourneyStartButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image("RunStartIcon").resizable().frame(width: 32, height: 33)
                    .padding(27)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay { Circle().strokeBorder(.white.opacity(0.25), lineWidth: 1) }
                Text("러닝 시작하기").font(JourneyFont.body).foregroundStyle(.white)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .environment(\.colorScheme, .dark)
        .accessibilityIdentifier("running.start")
    }
}
