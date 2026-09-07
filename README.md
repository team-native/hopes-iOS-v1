# hopes-iOS-V1

Hopes iOS 앱과 디자인 시스템을 함께 관리하는 레포지토리입니다.

## 프로젝트 운영 방식

### 원본으로 관리하는 파일

- `Workspace.swift`: Tuist 워크스페이스 구성
- `App/Project.swift`: Hopes 앱 타깃 구성과 버전 정보
- `Package.swift`: HopesDesignSystem 패키지 구성
- `Sources/`, `Resources/`, `Tests/`: 앱 소스, 리소스, 테스트

앱 타깃 설정이나 소스 파일을 추가할 때는 위 파일을 먼저 수정합니다.

### 로컬에서 생성하는 파일

아래 파일은 로컬 앱 개발을 위해 Tuist가 생성합니다. Git에 추가하지 않습니다.

- `App/Hopes.xcodeproj`
- `App/Hopes.xcworkspace`
- `App/Derived`
- `Hopes.xcworkspace`

프로젝트를 열거나 앱을 빌드하기 전에 레포지토리 최상위에서 아래 명령을 실행합니다.

```bash
tuist generate
```

생성 후에는 `Hopes.xcworkspace`를 열거나 `App/Hopes.xcodeproj`의 `Hopes` 스킴을 사용합니다.

### 호환용으로 추적하는 Xcode 파일

다음 파일은 현재 디자인 시스템 단독 빌드와 기존 Xcode Cloud 흐름을 지원하기 위해 Git에 유지합니다.

- `HopesDesignSystem.xcodeproj`
- `Workspace.xcworkspace`
- `Derived/`

이 파일들은 일반 앱 개발용 생성물이 아닙니다. 새 Swift 파일을 추가하거나 제거한 경우에는
Tuist 앱 빌드뿐 아니라 `HopesDesignSystem.xcodeproj` 빌드도 확인하고, 필요한 Source 참조 변경을
같은 PR에 포함합니다. Xcode Cloud의 생성·빌드 흐름을 별도로 이전하기 전까지는 삭제하지 않습니다.

## 빌드 확인

```bash
tuist generate
xcodebuild -project App/Hopes.xcodeproj -scheme Hopes \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO build
```

디자인 시스템 파일을 변경했으면 아래 빌드도 추가로 확인합니다.

```bash
xcodebuild -project HopesDesignSystem.xcodeproj -scheme HopesDesignSystem \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO build
```

## 리소스

Figma에서 추출한 디자인 리소스는 [`Resources`](Resources/README.md)에 있습니다.
