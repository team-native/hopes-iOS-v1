import SwiftUI

public struct PasswordResetView: View {
    private enum ResetField: Hashable {
        case email
        case code
        case newPassword
    }

    @Binding private var email: String
    @Binding private var code: String
    @Binding private var newPassword: String
    @FocusState private var focusedField: ResetField?
    @State private var isPasswordVisible = false
    private let codeRequested: Bool
    private let isVerified: Bool
    private let isLoading: Bool
    private let errorMessage: String?
    private let onBack: () -> Void
    private let onRequestCode: () -> Void
    private let onReset: () -> Void
    private let onComplete: () -> Void

    public init(
        email: Binding<String>,
        code: Binding<String>,
        newPassword: Binding<String>,
        codeRequested: Bool = false,
        isVerified: Bool = false,
        isLoading: Bool = false,
        errorMessage: String? = nil,
        onBack: @escaping () -> Void = {},
        onRequestCode: @escaping () -> Void = {},
        onReset: @escaping () -> Void = {},
        onComplete: @escaping () -> Void = {}
    ) {
        _email = email
        _code = code
        _newPassword = newPassword
        self.codeRequested = codeRequested
        self.isVerified = isVerified
        self.isLoading = isLoading
        self.errorMessage = errorMessage
        self.onBack = onBack
        self.onRequestCode = onRequestCode
        self.onReset = onReset
        self.onComplete = onComplete
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Button {
                    focusedField = nil
                    onBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.hopesTextPrimary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Text("비밀번호 재설정")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.hopesTextPrimary)
                    .padding(.top, 34)

                Text("학교 이메일로 받은 인증번호를 입력해주세요.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.hopesTextSecondary)
                    .padding(.top, 6)

                fieldTitle("이메일", top: 36)
                TextField("이메일", text: $email)
                    .textFieldStyle(HopesResetFieldStyle())
                    .focused($focusedField, equals: .email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .disabled(isVerified)

                if let emailErrorMessage {
                    feedbackText(emailErrorMessage, color: Color.hopesDanger)
                }

                fieldTitle("인증번호", top: 8)
                HStack(spacing: 10) {
                    TextField("숫자 6자리", text: $code)
                        .textFieldStyle(HopesResetFieldStyle())
                        .focused($focusedField, equals: .code)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .disabled(isVerified)

                    Button(codeButtonTitle, action: handleCodeButton)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 88, height: 43)
                        .background(Color.hopesBrandPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .contentShape(RoundedRectangle(cornerRadius: 14))
                        .buttonStyle(.plain)
                        .disabled(!isCodeButtonEnabled)
                        .opacity(isVerified || isCodeButtonEnabled ? 1 : 0.45)
                }

                if isVerified {
                    feedbackText("인증이 완료되었습니다.", color: Color.hopesSuccess)
                } else if let codeErrorMessage {
                    feedbackText(codeErrorMessage, color: Color.hopesDanger)
                }

                fieldTitle("비밀번호", top: 8)
                ZStack(alignment: .trailing) {
                    Group {
                        if isPasswordVisible {
                            TextField("비밀번호", text: $newPassword)
                        } else {
                            SecureField("비밀번호", text: $newPassword)
                        }
                    }
                    .textFieldStyle(HopesResetFieldStyle())
                    .focused($focusedField, equals: .newPassword)
                    .textContentType(.newPassword)
                    .disabled(isVerified)

                    Button {
                        isPasswordVisible.toggle()
                        focusedField = .newPassword
                    } label: {
                        Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.hopesTextSecondary)
                            .frame(width: 44, height: 48)
                    }
                    .buttonStyle(.plain)
                }

                feedbackText(passwordFeedbackMessage, color: passwordFeedbackColor)

                Color.clear
                    .frame(height: 0)
                    .onChange(of: code) { _, newValue in
                        let filtered = String(newValue.filter(\.isNumber).prefix(6))
                        if filtered != newValue {
                            code = filtered
                        }
                    }

                HopesButton("완료", size: .large, isEnabled: canComplete) {
                    focusedField = nil
                    onComplete()
                }
                .padding(.top, 36)
            }
            .padding(.horizontal, 28)
            .padding(.top, 24)
            .padding(.bottom, 34)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .simultaneousGesture(
            TapGesture().onEnded { focusedField = nil },
            including: .gesture
        )
        .background(Color.hopesBackground.ignoresSafeArea())
        .onChange(of: codeRequested) { _, requested in
            if requested {
                focusedField = .code
            }
        }
    }

    private var canComplete: Bool {
        isVerified && !isLoading
    }

    private var codeButtonTitle: String {
        if isVerified { return "인증 완료" }
        if isLoading { return "처리 중" }
        return codeRequested ? "인증하기" : "번호 발송"
    }

    private var emailErrorMessage: String? {
        guard let errorMessage, errorMessage.contains("이메일") || errorMessage.contains("회원") else {
            return nil
        }
        return errorMessage
    }

    private var codeErrorMessage: String? {
        guard let errorMessage,
              !errorMessage.contains("이메일"),
              !errorMessage.contains("회원"),
              !errorMessage.contains("비밀번호")
        else { return nil }
        return errorMessage
    }

    private var passwordFeedbackMessage: String {
        if let errorMessage, errorMessage.contains("비밀번호") {
            return errorMessage
        }
        return "영문과 숫자를 포함해 8~15자로 입력해주세요."
    }

    private var passwordFeedbackColor: Color {
        guard !newPassword.isEmpty else { return Color.hopesTextSecondary }
        if let errorMessage, errorMessage.contains("비밀번호") {
            return Color.hopesDanger
        }
        return PasswordPolicy.isValid(newPassword) ? Color.hopesTextSecondary : Color.hopesDanger
    }

    private var isCodeButtonEnabled: Bool {
        guard !isLoading, !isVerified else { return false }
        return codeRequested ? isCodeValid : isEmailValid
    }

    private var isEmailValid: Bool {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
            .range(of: #"^[A-Z0-9._%+-]+@gsm\.hs\.kr$"#, options: [.regularExpression, .caseInsensitive]) != nil
    }

    private var isCodeValid: Bool {
        code.range(of: #"^\d{6}$"#, options: .regularExpression) != nil
    }

    private func handleCodeButton() {
        focusedField = nil
        if codeRequested {
            guard isCodeValid else { return }
            onReset()
        } else {
            onRequestCode()
        }
    }

    private func fieldTitle(_ title: String, top: CGFloat) -> some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color.hopesTextPrimary)
            .padding(.top, top)
            .padding(.bottom, 8)
    }

    private func feedbackText(_ message: String, color: Color) -> some View {
        Text(message)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(color)
            .padding(.top, 6)
    }
}

private struct HopesResetFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 15))
            .padding(.horizontal, 16)
            .frame(height: 44)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.hopesBorder, lineWidth: 1)
            }
    }
}
