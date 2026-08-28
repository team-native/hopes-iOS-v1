import SwiftUI

public struct MyPageView: View {
    private enum ProfileField: Hashable {
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

    @State private var selectedTab: HopesTab = .settings
    @State private var lastSavedProfile: Profile
    @State private var hasSaved = false
    @Binding private var name: String
    @Binding private var introduction: String
    @FocusState private var focusedField: ProfileField?

    private let email: String
    private let major: String
    private let isLoading: Bool
    private let isSaving: Bool
    private let errorMessage: String?
    private let onBack: () -> Void
    private let onOpenSettings: () -> Void
    private let onSave: (Profile) -> Void
    private let onOpenAccountInfo: () -> Void
    private let onSelectTab: (HopesTab) -> Void
    private let cardContentHorizontalPadding: CGFloat = 24

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
            HopesTabBar(selection: $selectedTab) { tab in
                focusedField = nil
                onSelectTab(tab)
            }
        }
        .background(Color.hopesBackground.ignoresSafeArea())
    }

    private var header: some View {
        HStack {
            HopesLogo()

            Spacer()

            HopesButton(
                "설정",
                variant: .secondary,
                size: .small,
                width: .fixed(54),
                action: {
                    focusedField = nil
                    onOpenSettings()
                }
            )
        }
        .frame(height: 42, alignment: .top)
    }

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("프로필")
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.hopesTextPrimary)

            focusedNameField
                .padding(.top, 24)

            Text("자기소개 (AI 응답 개인화에 활용됩니다)")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.hopesTextPrimary)
                .padding(.top, 24)
                .simultaneousGesture(
                    TapGesture().onEnded { focusedField = nil }
                )

            ZStack(alignment: .topLeading) {
                if introduction.isEmpty {
                    Text("예: 프론트엔드에 관심 많은 8기 학생이에요.")
                        .font(.subheadline)
                        .foregroundStyle(Color.hopesTextSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .allowsHitTesting(false)
                }

                TextEditor(text: $introduction)
                    .font(.subheadline)
                    .foregroundStyle(Color.hopesTextPrimary)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 8)
                    .frame(height: 92)
                    .focused($focusedField, equals: .introduction)
            }
            .background(.white)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: HopesMetrics.controlCornerRadius
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: HopesMetrics.controlCornerRadius
                )
                .stroke(Color.hopesBorder, lineWidth: 1)
            }
            .padding(.top, 24)
        }
        .padding(.horizontal, cardContentHorizontalPadding)
        .padding(.vertical, 24)
        .frame(width: 354, height: 326, alignment: .topLeading)
        .background(.white)
        .clipShape(
            RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius)
        )
        .overlay {
            RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius)
                .stroke(Color.hopesBorder, lineWidth: 1)
        }
    }

    private var focusedNameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("이름")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.hopesTextPrimary)
                .simultaneousGesture(
                    TapGesture().onEnded { focusedField = nil }
                )

            TextField("이름", text: $name)
                .textFieldStyle(.plain)
                .font(.subheadline)
                .foregroundStyle(Color.hopesTextPrimary)
                .padding(.horizontal, 16)
                .frame(height: HopesMetrics.textFieldHeight)
                .background(Color.hopesInputBackground)
                .clipShape(
                    RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius)
                        .stroke(Color.hopesBorder, lineWidth: 1)
                }
                .focused($focusedField, equals: .name)
        }
    }

    private var accountCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("계정 정보 (수정 불가)")
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.hopesTextPrimary)

            Text("이메일: \(email)")
                .padding(.top, 22)

            Text("전공: \(major)")
                .padding(.top, 10)
        }
        .font(.footnote)
        .foregroundStyle(Color.hopesTextPrimary)
        .padding(.horizontal, cardContentHorizontalPadding)
        .padding(.vertical, 24)
        .frame(width: 354, height: 128, alignment: .topLeading)
        .background(.white)
        .clipShape(
            RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius)
        )
        .overlay {
            RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius)
                .stroke(Color.hopesBorder, lineWidth: 1)
        }
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
