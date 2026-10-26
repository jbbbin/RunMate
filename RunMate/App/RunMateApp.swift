import SwiftUI

@main
struct RunMateApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var session = AppSession()
    @State private var rooms = RoomStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(session)
                .environment(rooms)
                .task { await session.restoreSession() }
        }
    }
}
