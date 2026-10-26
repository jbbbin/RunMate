import SwiftUI

struct ProfileView: View {
    @Environment(AppSession.self) private var session
    @Environment(\.dismiss) private var dismiss
    @State private var showsSignOutConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section("메인 화면 미리보기") {
                    Text("방 선택과 핀은 이 기기에 저장돼요. 현재 방과 거리·참가자는 화면 확인을 위한 샘플 데이터예요.")
                    Text("개인 여정 1개 · 친구 방 최대 6명").foregroundStyle(.secondary)
                }
                Section("계정") {
                    if session.userID != nil {
                        LabeledContent("닉네임", value: session.profile?.nickname ?? "불러오는 중")
                        Button("프로필 다시 불러오기") { Task { await session.refresh() } }
                        Button("로그아웃", role: .destructive) { showsSignOutConfirmation = true }
                    } else if session.isFirebaseReady {
                        Button("게스트 로그인") { Task { await session.signInAsGuest() } }
                    } else {
                        Text(session.setupMessage).foregroundStyle(.secondary)
                    }
                }
                .disabled(session.isBusy)
            }
            .font(JourneyFont.body)
            .navigationTitle("설정").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기", systemImage: "xmark") { dismiss() }
                }
            }
            .confirmationDialog("게스트 계정에서 로그아웃할까요?", isPresented: $showsSignOutConfirmation, titleVisibility: .visible) {
                Button("로그아웃", role: .destructive) { session.signOut() }
                Button("취소", role: .cancel) {}
            } message: {
                Text("로그아웃한 게스트 계정의 기록은 다시 불러올 수 없어요.")
            }
        }
    }
}
