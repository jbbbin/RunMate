import SwiftUI

struct ContentView: View {
    @Environment(AppSession.self) private var session
    @State private var selectedTab = MainTab.running

    private enum MainTab: Hashable {
        case running
        case rooms
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label("러닝", systemImage: "figure.run") }
                .tag(MainTab.running)
            RoomsView()
                .tabItem { Label("방", systemImage: "house.lodge") }
                .tag(MainTab.rooms)
        }
        .tint(.accentColor)
        .preferredColorScheme(.light)
        .alert("확인이 필요해요", isPresented: Binding(
            get: { session.errorMessage != nil },
            set: { if !$0 { session.errorMessage = nil } }
        )) {
            Button("확인", role: .cancel) { session.errorMessage = nil }
        } message: {
            Text(session.errorMessage ?? "")
        }
    }
}

#Preview {
    ContentView()
        .environment(AppSession())
        .environment(RoomStore(defaults: UserDefaults(suiteName: "RunMate.CanvasPreview")!))
}
