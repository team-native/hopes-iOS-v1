import SwiftUI

public struct SignUpFormData: Equatable, Sendable {
    public var email: String
    public var name: String
    public var major: String
    public var cohort: String
    public var password: String
    public var passwordConfirm: String
    public var verificationCode: String

    public init(
        email: String,
        name: String,
        major: String,
        cohort: String,
        password: String = "",
        passwordConfirm: String = "",
        verificationCode: String = ""
    ) {
        self.email = email
        self.name = name
        self.major = major
        self.cohort = cohort
        self.password = password
        self.passwordConfirm = passwordConfirm
        self.verificationCode = verificationCode
    }
}

public struct SignUpView: View {
    @State private var selectedTab: HopesTab = .home
    @State private var verificationCode = ""
    @State private var password = ""
    @State private var passwordConfirm = ""
    @State private var isPasswordVisible = false
    @State private var isPasswordConfirmVisible = false
    @State private var isRequestingVerification = false
    @State private var isConfirmingVerification = false
    @State private var isSigningUp = false
    @State private var isEmailVerified = false
    @State private var statusMessage: String?
    @State private var errorMessage: String?

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
            Color.hopesBackground.ignoresSafeArea()
            header

            signUpCard
                .padding(.horizontal, 24)
                .padding(.top, 217)
                .padding(.bottom, 92)

            HopesTabBar(selection: $selectedTab)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .ignoresSafeArea(edges: .bottom)
        }
        .onChange(of: email) {
            isEmailVerified = false
            verificationCode = ""
            statusMessage = nil
            errorMessage = nil
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

    private var signUpCard: some View {
        ScrollView(showsIndicators: true) {
            VStack(spacing: 20) {
                VStack(spacing: 0) {
                    signUpField("학교 이메일", text: $email, placeholder: "s26055@gsm.hs.kr", kind: .email)
                    verificationField
                    signUpField("이름", text: $name, placeholder: "임서하")
                    signUpField(
                        "비밀번호",
                        text: $password,
                        placeholder: "영문·숫자 포함 8~15자",
                        kind: .password,
                        isPasswordVisible: $isPasswordVisible
                    )
                    signUpField(
                        "비밀번호 확인",
                        text: $passwordConfirm,
                        placeholder: "비밀번호 재입력",
                        kind: .password,
                        isPasswordVisible: $isPasswordConfirmVisible
                    )
                    signUpField("과", text: $major, placeholder: "AI", kind: .major)
                    signUpField("기수", text: $cohort, placeholder: "10기", kind: .cohort)
                }

                signUpButton
                loginLink
            }
            .padding(.horizontal, 17)
            .padding(.top, 30)
            .padding(.bottom, 28)
        }
        .scrollBounceBehavior(.basedOnSize)
        .frame(maxWidth: 354, maxHeight: .infinity)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius)
                .stroke(Color.hopesBorder, lineWidth: 1)
        }
        .shadow(color: Color(red: 13 / 255, green: 26 / 255, blue: 46 / 255).opacity(0.09), radius: 11, y: 8)
    }

    private var verificationField: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("인증번호")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.hopesTextPrimary)

            HStack(spacing: 8) {
                TextField("숫자 6자리", text: $verificationCode)
                    .signUpInputTraits(.verificationCode)
                    .textFieldStyle(.plain)
                    .font(.system(size: 15))
                    .padding(.horizontal, 12)
                    .frame(height: 43)
                    .overlay {
                        RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius)
                            .stroke(Color.hopesBorder, lineWidth: 1)
                    }
                    .disabled(isEmailVerified)

                Button(verificationButtonTitle, action: handleVerificationButton)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 86, height: 43)
                    .background(Color.hopesBrandPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius))
                    .disabled(isEmailVerified || isRequestingVerification || isConfirmingVerification)
            }
        }
        .frame(height: 89, alignment: .top)
    }

    private func signUpField(
        _ title: String,
        text: Binding<String>,
        placeholder: String,
        kind: SignUpFieldKind = .plain,
        isPasswordVisible: Binding<Bool>? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.hopesTextPrimary)

            Group {
                if kind == .major {
                    Menu {
                        ForEach(["AI", "SW", "IoT"], id: \.self) { option in
                            Button(option) { text.wrappedValue = option }
                        }
                    } label: {
                        HStack {
                            Text(text.wrappedValue.isEmpty ? placeholder : text.wrappedValue)
                                .foregroundStyle(Color.hopesTextSecondary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(Color.hopesTextPrimary)
                        }
                    }
                } else if kind == .password, let isPasswordVisible {
                    Group {
                        if isPasswordVisible.wrappedValue {
                            TextField(placeholder, text: text)
                        } else {
                            SecureField(placeholder, text: text)
                        }
                    }
                    .padding(.trailing, 30)
                    .overlay(alignment: .trailing) {
                        Button {
                            isPasswordVisible.wrappedValue.toggle()
                        } label: {
                            Image(systemName: isPasswordVisible.wrappedValue ? "eye" : "eye.slash")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.hopesTextSecondary)
                                .frame(width: 30, height: 40)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(isPasswordVisible.wrappedValue ? "비밀번호 숨기기" : "비밀번호 보기")
                    }
                } else {
                    TextField("", text: text, prompt: Text(placeholder).foregroundStyle(Color.hopesTextSecondary))
                        .signUpInputTraits(kind)
                }
            }
            .textFieldStyle(.plain)
            .font(.system(size: 15))
            .foregroundStyle(Color.hopesTextPrimary)
            .padding(.horizontal, 12)
            .frame(height: 43)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius)
                    .stroke(Color.hopesBorder, lineWidth: 1)
            }
        }
        .frame(height: 89, alignment: .top)
    }

    private var signUpButton: some View {
        Button(action: signUp) {
            Text(isSigningUp ? "가입 중..." : "회원가입")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(Color.hopesBrandPrimary)
                .clipShape(RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius))
        }
        .buttonStyle(.plain)
        .disabled(!isFormValid || isSigningUp)
        .opacity(isFormValid && !isSigningUp ? 1 : 0.45)
        .overlay(alignment: .bottom) {
            if let message = errorMessage ?? statusMessage {
                Text(message)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(errorMessage == nil ? Color.hopesSuccess : Color.hopesDanger)
                    .offset(y: 18)
            }
        }
    }

    private var loginLink: some View {
        Button(action: onGoToLogin) {
            (Text("계정이 있으신가요?  ").foregroundStyle(Color.hopesTextSecondary)
                + Text("로그인").foregroundStyle(Color.hopesBrandPrimary).underline())
                .font(.footnote)
                .frame(maxWidth: .infinity)
                .frame(height: 18)
        }
        .buttonStyle(.plain)
    }

    private var normalizedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isSchoolEmailValid: Bool {
        normalizedEmail.range(
            of: #"^[A-Z0-9._%+-]+@gsm\.hs\.kr$"#,
            options: [.regularExpression, .caseInsensitive]
        ) != nil
    }

    private var isVerificationCodeValid: Bool {
        verificationCode.range(of: #"^\d{6}$"#, options: .regularExpression) != nil
    }

    private var isFormValid: Bool {
        isSchoolEmailValid
            && isEmailVerified
            && !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !major.isEmpty
            && cohort.rangeOfCharacter(from: .decimalDigits) != nil
            && PasswordPolicy.isValid(password)
            && password == passwordConfirm
    }

    private var verificationButtonTitle: String {
        if isEmailVerified { return "인증 완료" }
        if isRequestingVerification { return "발송 중" }
        if isConfirmingVerification { return "확인 중" }
        return isVerificationCodeValid ? "인증 확인" : "번호 발송"
    }

    private func handleVerificationButton() {
        if isVerificationCodeValid {
            confirmVerification()
        } else {
            requestVerification()
        }
    }

    private func requestVerification() {
        guard isSchoolEmailValid else {
            errorMessage = "학교 이메일을 올바르게 입력해주세요."
            return
        }
        isRequestingVerification = true
        errorMessage = nil
        statusMessage = nil
        Task {
            do {
                let response = try await HopesAPIClient.shared.requestEmailVerification(email: normalizedEmail)
                await MainActor.run {
                    isRequestingVerification = false
                    statusMessage = response.message
                }
            } catch {
                await MainActor.run {
                    isRequestingVerification = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func confirmVerification() {
        isConfirmingVerification = true
        errorMessage = nil
        Task {
            do {
                let response = try await HopesAPIClient.shared.confirmEmailVerification(
                    email: normalizedEmail,
                    code: verificationCode
                )
                await MainActor.run {
                    isConfirmingVerification = false
                    isEmailVerified = true
                    statusMessage = response.message
                }
            } catch {
                await MainActor.run {
                    isConfirmingVerification = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func signUp() {
        guard isFormValid, !isSigningUp else { return }
        isSigningUp = true
        errorMessage = nil
        let formData = SignUpFormData(
            email: normalizedEmail,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            major: major,
            cohort: cohort,
            password: password,
            passwordConfirm: passwordConfirm,
            verificationCode: verificationCode
        )
        Task {
            do {
                try await HopesAPIClient.shared.signUp(
                    SignupRequest(
                        email: formData.email,
                        username: formData.name,
                        password: formData.password,
                        passwordConfirm: formData.passwordConfirm,
                        verificationCode: formData.verificationCode,
                        gender: nil,
                        major: formData.major,
                        cohort: Int(formData.cohort.filter(\.isNumber))
                    )
                )
                await MainActor.run {
                    isSigningUp = false
                    onSignUp(formData)
                }
            } catch {
                await MainActor.run {
                    isSigningUp = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

private enum SignUpFieldKind {
    case plain
    case email
    case major
    case cohort
    case password
    case verificationCode
}

private extension View {
    @ViewBuilder
    func signUpInputTraits(_ kind: SignUpFieldKind) -> some View {
        #if os(iOS)
        switch kind {
        case .plain, .major, .password:
            textInputAutocapitalization(.never)
        case .email:
            textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
        case .cohort:
            keyboardType(.numbersAndPunctuation)
        case .verificationCode:
            keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
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

    SignUpView(email: $email, name: $name, major: $major, cohort: $cohort)
        .frame(width: 402, height: 874)
}
