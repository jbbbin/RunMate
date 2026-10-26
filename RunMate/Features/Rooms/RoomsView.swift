import SwiftUI

struct RoomsView: View {
    @Environment(RoomStore.self) private var rooms
    @State private var showsCreateRoom = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 22) {
                    ForEach(rooms.rooms) { room in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { rooms.pin(room.id) }
                        } label: {
                            JourneyRoomCard(room: room, isPinned: rooms.pinnedRoomID == room.id)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(room.name), \(room.location.name), \(room.members.count)명")
                        .accessibilityValue(rooms.pinnedRoomID == room.id ? "러닝 탭에 고정됨" : "고정되지 않음")
                        .accessibilityHint("두 번 탭하여 러닝 탭에 고정")
                        .accessibilityIdentifier("rooms.pin.\(room.id)")
                        .contextMenu {
                            Button("러닝 탭에 고정", systemImage: "pin.fill") { rooms.pin(room.id) }
                        }
                    }
                    Button { showsCreateRoom = true } label: {
                        Image("AddRoomIcon").resizable().frame(width: 40, height: 42)
                            .frame(maxWidth: .infinity, minHeight: 79)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                            .overlay { RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.2), lineWidth: 1) }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("새 방 만들기")
                    .environment(\.colorScheme, .dark)
                    .accessibilityIdentifier("rooms.create")
                }
                .padding(.horizontal, 26).padding(.top, 8).padding(.bottom, 28)
            }
            .scrollIndicators(.hidden)
            .background { JourneyBackground(imageName: "SeoulRooms", dimmed: true) }
            .navigationTitle("방 목록").navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sensoryFeedback(.selection, trigger: rooms.pinnedRoomID)
        }
        .sheet(isPresented: $showsCreateRoom) { CreateRoomView() }
    }
}
