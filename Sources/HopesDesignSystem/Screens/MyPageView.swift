import SwiftUI

public struct MyPageView: View {
    enum ProfileField: Hashable {
        case name
        case introduction
    }

    public struct Profile: Equatable, Sendable {
        public var name: String
        public var introduction: String

        public init(name: String, introduction: String) {
            self.name = name
            self.introduction = introduction
        }
    }

    @State var selectedTab: HopesTab = .settings
    @State var lastSavedProfile: Profile
    @State var hasSaved = false
    @Binding var name: String
    @Binding var introduction: String
    @FocusState var focusedField: ProfileField?

    let email: String
    let major: String
    let isLoading: Bool
    let isSaving: Bool
    let errorMessage: String?
    let onBack: () -> Void
    let onOpenSettings: () -> Void
    let onSave: (Profile) -> Void
    let onOpenAccountInfo: () -> Void
    let onSelectTab: (HopesTab) -> Void
    let cardContentHorizontalPadding: CGFloat = 24

    public init(
        name: Binding<String>,
        introduction: Binding<String>,
        email: String = "s26055@gsm.hs.kr",
        major: String = "인공지능소프트웨어과",
        isLoading: Bool = false,
        isSaving: Bool = false,
        errorMessage: String? = nil,
        onBack: @escaping () -> Void = {},
        onOpenSettings: @escaping () -> Void = {},
        onSave: @escaping (Profile) -> Void = { _ in },
        onOpenAccountInfo: @escaping () -> Void = {},
        onSelectTab: @escaping (HopesTab) -> Void = { _ in }
    ) {
        _name = name
        _introduction = introduction
        _lastSavedProfile = State(
            initialValue: Profile(
                name: name.wrappedValue,
                introduction: introduction.wrappedValue
            )
        )
        self.email = email
        self.major = major
        self.isLoading = isLoading
        self.isSaving = isSaving
        self.errorMessage = errorMessage
        self.onBack = onBack
        self.onOpenSettings = onOpenSettings
        self.onSave = onSave
        self.onOpenAccountInfo = onOpenAccountInfo
        self.onSelectTab = onSelectTab
    }

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.horizontal, 24)
                    .padding(.trailing, 13)
                    .padding(.top, 70)

                Text("마이페이지")
                    .font(.title.weight(.bold))
                    .foregroundStyle(Color.hopesTextPrimary)
                    .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                    .padding(.top, 26)

                Button {
                    focusedField = nil
                    onOpenAccountInfo()
                } label: {
                    accountCard
                }
                .buttonStyle(.plain)
                .accessibilityHint("계정 정보 상세 화면을 엽니다")
                .padding(.horizontal, 24)
                .padding(.top, 12)

                profileCard
                    .padding(.horizontal, 24)
                    .padding(.top, 40)

                if isLoading {
                    ProgressView("프로필을 불러오는 중...")
                        .frame(maxWidth: .infinity)
                        .padding(.top, 12)
                } else if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(Color.hopesDanger)
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                }

                HopesButton(
                    isSaving ? "저장 중" : "저장",
                    size: .regular,
                    width: .fixed(96),
                    isEnabled: canSave && !isLoading && !isSaving,
                    action: {
                        focusedField = nil
                        saveProfile()
                    }
                )
                .padding(.horizontal, 30)
                .padding(.top, 18)
                .padding(.bottom, 24)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollDismissesKeyboard(.interactively)
        .simultaneousGesture(
            TapGesture().onEnded { focusedField = nil },
            including: .gesture
        )
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if focusedField == nil {
                HopesTabBar(selection: $selectedTab) { tab in
                    focusedField = nil
                    onSelectTab(tab)
                }
            }
        }
        .background(Color.hopesBackground.ignoresSafeArea())
    }

    private var currentProfile: Profile {
        Profile(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            introduction: introduction.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    private var hasUnsavedChanges: Bool {
        currentProfile != lastSavedProfile
    }

    private var canSave: Bool {
        !currentProfile.name.isEmpty && (!hasSaved || hasUnsavedChanges)
    }

    private func saveProfile() {
        guard canSave else {
            return
        }

        onSave(currentProfile)
    }
}

#Preview("마이페이지") {
    @Previewable @State var name = "임서하"
    @Previewable @State var introduction = ""

    MyPageView(
        name: $name,
        introduction: $introduction
    )
    .frame(width: 402, height: 874)
}
