import SwiftUI

struct CreateRoomView: View {
    @Environment(RoomStore.self) private var rooms
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var pinAfterCreating = true
    @State private var errorMessage: String?

    private var isValid: Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count <= 20
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("방 이름", text: $name).accessibilityIdentifier("rooms.name")
                    Toggle("러닝 탭에 고정", isOn: $pinAfterCreating)
                } header: {
                    Text("함께 달릴 여정")
                } footer: {
                    Text("방장을 포함해 최대 6명이 함께할 수 있어요. 방 이름은 20자까지 입력할 수 있어요.")
                }
                Section {
                    Text("지금 만드는 방은 이 기기에서 미리 볼 수 있어요. 친구 초대와 실시간 동기화는 준비 중이에요.")
                        .font(JourneyFont.label).foregroundStyle(.secondary)
                }
            }
            .font(JourneyFont.body)
            .navigationTitle("새 방 만들기").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소", systemImage: "xmark") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("방 만들기", systemImage: "checkmark") {
                        do {
                            try rooms.createGroup(name: name, pinAfterCreating: pinAfterCreating)
                            dismiss()
                        } catch {
                            errorMessage = error.localizedDescription
                        }
                    }
                    .buttonStyle(.borderedProminent).disabled(!isValid)
                    .accessibilityIdentifier("rooms.save")
                }
            }
        }
        .alert("방을 만들 수 없어요", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("확인", role: .cancel) { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }
}
