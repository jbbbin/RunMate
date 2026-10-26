# RunMate

기존 MateRun과 같은 화면·모델·이미지·Firebase 의존성을 가진 RunMate 프로젝트입니다.

- 열 파일: `RunMate.xcodeproj`
- Scheme / Target / 앱 이름: `RunMate`
- Bundle Identifier: `com.jeongbinlee.RunMate`
- 앱 시작 파일: `RunMate/App/RunMateApp.swift`
- 소스 폴더: `RunMate/`

Firebase를 연결할 때 위 Bundle ID로 iOS 앱을 등록하고 다운로드한 설정 파일을 `RunMate/Resources/GoogleService-Info.plist`에 넣습니다. 실제 iPhone 실행 시 Xcode의 Signing & Capabilities에서 Team을 선택합니다.

현재 러닝/방 화면과 핀 기능은 로컬 미리보기 데이터로 동작합니다. 이후 개발에는 `RunMate.xcodeproj`를 사용하세요.
