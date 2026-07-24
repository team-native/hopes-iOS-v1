import SwiftUI

public struct SignUpFormData: Equatable, Sendable {
    public var email: String
    public var name: String
    public var major: String
    public var cohort: String

    public init(
        email: String,
        name: String,
        major: String,
        cohort: String
    ) {
        self.email = email
        self.name = name
        self.major = major
        self.cohort = cohort
    }
}

public struct SignUpView: View {
    @Binding private var email: String
    @Binding private var name: String
    @Binding private var major: String
    @Binding private var cohort: String

    private let onSignUp: (SignUpFormData) -> Void
    private let onGoToLogin: () -> Void

    public init(
        email: Binding<String>,
        name: Binding<String>,
        major: Binding<String>,
        cohort: Binding<String>,
        onSignUp: @escaping (SignUpFormData) -> Void = { _ in },
        onGoToLogin: @escaping () -> Void = {}
    ) {
        _email = email
        _name = name
        _major = major
        _cohort = cohort
        self.onSignUp = onSignUp
        self.onGoToLogin = onGoToLogin
    }

    public var body: some View {
        ZStack(alignment: .top) {
            Color.hopesBackground
                .ignoresSafeArea()

            header
            formCard
                .padding(.top, 217)

            signUpButton
                .padding(.top, 579)

            HopesButton(
                "이미 계정이 있어요",
                variant: .secondary,
                width: .fixed(354),
                action: onGoToLogin
            )
            .padding(.top, 645)

            authTabBar
                .frame(maxHeight: .infinity, alignment: .bottom)
                .ignoresSafeArea(edges: .bottom)
        }
    }

    private var header: some View {
        ZStack(alignment: .topLeading) {
            Color.hopesHeroGradient

            HopesLogo(placement: .onBrand)
                .padding(.leading, 32)
                .padding(.top, 76)

            Text("학교 이메일로\n간단히 시작하기")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .lineSpacing(1)
                .padding(.leading, 32)
                .padding(.top, 154)
        }
        .frame(height: 250)
        .ignoresSafeArea(edges: .top)
    }

    private var formCard: some View {
        VStack(spacing: 0) {
            signUpField(
                "학교 이메일",
                text: $email,
                placeholder: "s26055@gsm.hs.kr",
                kind: .email
            )
            signUpField(
                "이름",
                text: $name,
                placeholder: "임서하"
            )
            signUpField(
                "전공",
                text: $major,
                placeholder: ""
            )
            signUpField(
                "기수",
                text: $cohort,
                placeholder: "10기",
                kind: .cohort
            )
        }
        .padding(.horizontal, 24)
        .padding(.top, 22)
        .frame(width: 354, height: 338, alignment: .top)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius)
                .stroke(Color.hopesBorder, lineWidth: 1)
        }
        .shadow(color: Color(red: 13 / 255, green: 26 / 255, blue: 46 / 255).opacity(0.09), radius: 11, y: 8)
    }

    private var signUpButton: some View {
        Button {
            onSignUp(
                SignUpFormData(
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                    major: major.trimmingCharacters(in: .whitespacesAndNewlines),
                    cohort: cohort.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            )
        } label: {
            Text("회원가입")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 354, height: 46)
                .background(isFormValid ? Color.hopesBrandPrimary : .clear)
                .clipShape(RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius))
        }
        .buttonStyle(.plain)
        .disabled(!isFormValid)
        .accessibilityHint(isFormValid ? "" : "모든 항목을 올바르게 입력해 주세요.")
    }

    private var authTabBar: some View {
        HStack(spacing: 0) {
            authTabItem("홈", symbol: "●", isSelected: true)
            authTabItem("채팅", symbol: "○")
            authTabItem("기록", symbol: "○")
            authTabItem("설정", symbol: "○")
        }
        .frame(height: 84)
        .frame(maxWidth: .infinity)
        .background(.white)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.hopesBorder)
                .frame(height: 1)
        }
    }

    private func authTabItem(
        _ title: String,
        symbol: String,
        isSelected: Bool = false
    ) -> some View {
        VStack(spacing: 5) {
            Text(symbol)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(
                    isSelected ? Color.hopesBrandPrimary : Color.hopesTextPlaceholder
                )
                .frame(width: 60, height: 30)
                .background(isSelected ? Color.hopesBrandTint : .clear)
                .clipShape(Capsule())

            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(
                    isSelected ? Color.hopesBrandPrimary : Color.hopesTextSecondary
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 12)
    }

    private func signUpField(
        _ title: String,
        text: Binding<String>,
        placeholder: String,
        kind: SignUpFieldKind = .plain
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.hopesTextPrimary)

            TextField(
                "",
                text: text,
                prompt: Text(placeholder)
                    .foregroundStyle(Color.hopesTextSecondary)
            )
                .signUpInputTraits(kind)
                .textFieldStyle(.plain)
                .font(.system(size: 15))
                .foregroundStyle(Color.hopesTextPrimary)
                .padding(.horizontal, 16)
                .frame(height: 52)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(Color.hopesBorder)
                        .frame(height: 1)
                }
        }
        .frame(height: 76, alignment: .top)
    }

    private var isFormValid: Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasSchoolDomain = trimmedEmail.range(
            of: #"^[A-Z0-9._%+-]+@gsm\.hs\.kr$"#,
            options: [.regularExpression, .caseInsensitive]
        ) != nil

        return hasSchoolDomain
            && !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !major.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && cohort.rangeOfCharacter(from: .decimalDigits) != nil
    }
}

private enum SignUpFieldKind {
    case plain
    case email
    case cohort
}

private extension View {
    @ViewBuilder
    func signUpInputTraits(_ kind: SignUpFieldKind) -> some View {
        #if os(iOS)
        switch kind {
        case .plain:
            textInputAutocapitalization(.never)
        case .email:
            textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
        case .cohort:
            keyboardType(.numbersAndPunctuation)
        }
        #else
        self
        #endif
    }
}

#Preview("회원가입") {
    @Previewable @State var email = ""
    @Previewable @State var name = ""
    @Previewable @State var major = ""
    @Previewable @State var cohort = ""

    SignUpView(
        email: $email,
        name: $name,
        major: $major,
        cohort: $cohort
    )
    .frame(width: 402, height: 874)
}
