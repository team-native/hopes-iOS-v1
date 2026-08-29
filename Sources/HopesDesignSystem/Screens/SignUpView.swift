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
    private enum SignUpField: Hashable {
        case email
        case verificationCode
        case name
        case password
        case passwordConfirm
    }

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
    @FocusState private var focusedField: SignUpField?

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
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                header

                signUpPanel
                    .padding(.horizontal, 24)
                    .padding(.top, 26)
            }
            .frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
        .simultaneousGesture(
            TapGesture().onEnded { focusedField = nil },
            including: .gesture
        )
        .scrollIndicators(.hidden)
        .background(Color.hopesBackground.ignoresSafeArea())
        .onChange(of: email) {
            isEmailVerified = false
            verificationCode = ""
            statusMessage = nil
            errorMessage = nil
        }
    }

    private var signUpPanel: some View {
        VStack(spacing: 0) {
            signUpCard

            signUpButton
                .padding(.top, 42)

            if let message = errorMessage ?? statusMessage {
                Text(message)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(errorMessage == nil ? Color.hopesSuccess : Color.hopesDanger)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
            }

            loginLink
                .padding(.top, 10)
        }
        .padding(.bottom, 96)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            HopesLogo(placement: .onBrand)
                .padding(.leading, 32)
                .padding(.top, 76)

            Text("학교 이메일로\n간단히 시작하기")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .lineSpacing(1)
                .padding(.leading, 32)
                .padding(.top, 28)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 250)
        .background(Color.hopesHeroGradient.ignoresSafeArea(edges: .top))
    }

    private var signUpCard: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                signUpField(
                    "학교 이메일",
                    text: $email,
                    placeholder: "s26055@gsm.hs.kr",
                    kind: .email,
                    focus: .email
                )
                verificationField
                signUpField("이름", text: $name, placeholder: "임서하", focus: .name)
                signUpField("과", text: $major, placeholder: "학과 선택", kind: .major)
                signUpField("기수", text: $cohort, placeholder: "기수 선택", kind: .cohort)
                signUpField(
                    "비밀번호",
                    text: $password,
                    placeholder: "영문·숫자 포함 8~15자",
                    kind: .password,
                    isPasswordVisible: $isPasswordVisible,
                    focus: .password,
                    validationMessage: passwordValidationMessage
                )
                signUpField(
                    "비밀번호 확인",
                    text: $passwordConfirm,
                    placeholder: "비밀번호 재입력",
                    kind: .password,
                    isPasswordVisible: $isPasswordConfirmVisible,
                    focus: .passwordConfirm,
                    validationMessage: passwordConfirmValidationMessage
                )
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 24)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollDismissesKeyboard(.interactively)
        .frame(maxWidth: 354)
        .frame(height: 386)
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
                .simultaneousGesture(
                    TapGesture().onEnded { focusedField = nil }
                )

            HStack(spacing: 8) {
                TextField("숫자 6자리", text: $verificationCode)
                    .signUpInputTraits(.verificationCode)
                    .textFieldStyle(.plain)
                    .focused($focusedField, equals: .verificationCode)
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
        .frame(height: 76, alignment: .top)
    }

    private func signUpField(
        _ title: String,
        text: Binding<String>,
        placeholder: String,
        kind: SignUpFieldKind = .plain,
        isPasswordVisible: Binding<Bool>? = nil,
        focus: SignUpField? = nil,
        validationMessage: String? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.hopesTextPrimary)
                .simultaneousGesture(
                    TapGesture().onEnded { focusedField = nil }
                )

            Group {
                if kind == .major || kind == .cohort {
                    Menu {
                        ForEach(kind == .major ? ["AI", "SW", "IoT"] : ["7기", "8기", "9기", "10기"], id: \.self) { option in
                            Button(option) {
                                focusedField = nil
                                text.wrappedValue = option
                            }
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
                    .focused($focusedField, equals: focus)
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
                        .focused($focusedField, equals: focus)
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
                    .stroke(validationMessage == nil ? Color.hopesBorder : Color.hopesDanger, lineWidth: 1)
            }

            if let validationMessage {
                Text(validationMessage)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.hopesDanger)
            }
        }
        .frame(height: validationMessage == nil ? 76 : 94, alignment: .top)
    }

    private var signUpButton: some View {
        Button {
            focusedField = nil
            signUp()
        } label: {
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
    }

    private var loginLink: some View {
        HStack(spacing: 0) {
            Spacer()

            Button {
                focusedField = nil
                onGoToLogin()
            } label: {
                (Text("계정이 있으신가요?  ").foregroundStyle(Color.hopesTextSecondary)
                    + Text("로그인").foregroundStyle(Color.hopesBrandPrimary).underline())
                    .font(.footnote)
                    .frame(height: 18)
            }
            .buttonStyle(.plain)

            Spacer()
        }
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

    private var passwordValidationMessage: String? {
        guard !password.isEmpty, !PasswordPolicy.isValid(password) else { return nil }
        return "영문과 숫자를 포함한 8~15자로 입력해주세요."
    }

    private var passwordConfirmValidationMessage: String? {
        guard !passwordConfirm.isEmpty, PasswordPolicy.isValid(password), password != passwordConfirm else {
            return nil
        }
        return "비밀번호가 일치하지 않습니다."
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
