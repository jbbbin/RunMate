import SwiftUI

struct HomeView: View {
    @Environment(RoomStore.self) private var rooms
    @State private var showsSettings = false
    @State private var showsRunningNotice = false

    var body: some View {
        NavigationStack {
            Group {
                if let room = rooms.pinnedRoom {
                    RunningDashboard(room: room) { showsRunningNotice = true }
                        .background { JourneyBackground(imageName: room.location.runningImage) }
                        .navigationTitle(room.location.name)
                } else {
                    ContentUnavailableView("핀한 방이 없어요", systemImage: "house.lodge", description: Text("방 탭에서 함께 달릴 여정을 선택해 주세요."))
                        .navigationTitle("러닝")
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("설정", systemImage: "gearshape") { showsSettings = true }
                        .tint(.white)
                        .accessibilityIdentifier("running.settings")
                }
            }
        }
        .sheet(isPresented: $showsSettings) { ProfileView() }
        .alert("\(rooms.pinnedRoom?.name ?? "선택한 방")에서 달리기", isPresented: $showsRunningNotice) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("러닝 측정 기능은 준비 중이에요. 지금은 방을 핀하고 러닝 화면을 둘러볼 수 있어요.")
        }
    }
}
