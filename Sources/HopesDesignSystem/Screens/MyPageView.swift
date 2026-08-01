import SwiftUI

public struct MyPageView: View {
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

    private let email: String
    private let major: String
    private let onBackToChat: () -> Void
    private let onSave: (Profile) -> Void
    private let onOpenAccountInfo: () -> Void

    public init(
        name: Binding<String>,
        introduction: Binding<String>,
        email: String = "s26055@gsm.hs.kr",
        major: String = "인공지능소프트웨어과",
        onBackToChat: @escaping () -> Void = {},
        onSave: @escaping (Profile) -> Void = { _ in },
        onOpenAccountInfo: @escaping () -> Void = {}
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
        self.onBackToChat = onBackToChat
        self.onSave = onSave
        self.onOpenAccountInfo = onOpenAccountInfo
    }

    public var body: some View {
        ZStack(alignment: .top) {
            Color.hopesBackground

            header
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 70)

            Text("마이페이지")
                .font(.title.weight(.bold))
                .foregroundStyle(Color.hopesTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 138)

            profileCard
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 190)

            HopesButton(
                hasSaved && !hasUnsavedChanges ? "저장됨" : "저장",
                size: .regular,
                width: .fixed(hasSaved && !hasUnsavedChanges ? 104 : 96),
                isEnabled: canSave,
                action: saveProfile
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 48)
            .padding(.top, 538)

            Button(action: onOpenAccountInfo) {
                accountCard
            }
            .buttonStyle(.plain)
            .accessibilityHint("계정 정보 상세 화면을 엽니다")
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 628)

            HopesTabBar(selection: $selectedTab)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack {
            HopesLogo()

            Spacer()

            HopesButton(
                "채팅으로",
                variant: .secondary,
                size: .medium,
                width: .fixed(78),
                action: onBackToChat
            )
        }
    }

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("프로필")
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.hopesTextPrimary)

            HopesLabeledTextField(
                "이름",
                text: $name,
                placeholder: "이름"
            )
            .padding(.top, 22)

            Text("자기소개 (AI 응답 개인화에 활용됩니다)")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.hopesTextPrimary)
                .padding(.top, 14)

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
            .padding(.top, 16)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 326, alignment: .top)
        .background(.white)
        .clipShape(
            RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius)
        )
        .overlay {
            RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius)
                .stroke(Color.hopesBorder, lineWidth: 1)
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
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 128, alignment: .top)
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

        name = currentProfile.name
        introduction = currentProfile.introduction
        lastSavedProfile = currentProfile
        hasSaved = true
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
