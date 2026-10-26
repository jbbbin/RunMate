import SwiftUI

/// 작은 기기나 큰 글자에서는 세로 스크롤로 전환합니다.
struct RunningDashboard: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let room: JourneyRoom
    let onStart: () -> Void

    var body: some View {
        GeometryReader { geometry in
            if geometry.size.height >= 610 && dynamicTypeSize <= .xLarge {
                VStack(spacing: 0) {
                    JourneyCheckpointCard(room: room)
                    Spacer(minLength: 28)
                    JourneyRunner(room: room)
                    Spacer(minLength: 20)
                    JourneyStartButton(action: onStart).padding(.bottom, 24)
                }
                .padding(.horizontal, 26).padding(.top, 8)
            } else {
                ScrollView {
                    VStack(spacing: 28) {
                        JourneyCheckpointCard(room: room)
                        JourneyRunner(room: room)
                        JourneyStartButton(action: onStart)
                    }
                    .padding(.horizontal, 26).padding(.top, 8).padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}
