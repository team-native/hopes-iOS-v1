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
    private let isLoading: Bool
    private let errorMessage: String?
    private let onBack: () -> Void
    private let onRequestCode: () -> Void
    private let onReset: () -> Void

    public init(
        email: Binding<String>,
        code: Binding<String>,
        newPassword: Binding<String>,
        codeRequested: Bool = false,
        isLoading: Bool = false,
        errorMessage: String? = nil,
        onBack: @escaping () -> Void = {},
        onRequestCode: @escaping () -> Void = {},
        onReset: @escaping () -> Void = {}
    ) {
        _email = email
        _code = code
        _newPassword = newPassword
        self.codeRequested = codeRequested
        self.isLoading = isLoading
        self.errorMessage = errorMessage
        self.onBack = onBack
        self.onRequestCode = onRequestCode
        self.onReset = onReset
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            Color.hopesBackground
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { focusedField = nil }

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

                fieldTitle("인증번호", top: 8)
                HStack(spacing: 10) {
                    TextField("숫자 6자리", text: $code)
                        .textFieldStyle(HopesResetFieldStyle())
                        .focused($focusedField, equals: .code)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)

                    Button(codeButtonTitle, action: handleCodeButton)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 88, height: 43)
                        .background(Color.hopesBrandPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .buttonStyle(.plain)
                        .disabled(!isCodeButtonEnabled)
                        .opacity(isCodeButtonEnabled ? 1 : 0.45)
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

                Color.clear
                    .frame(height: 0)
                    .onChange(of: code) { _, newValue in
                        let filtered = String(newValue.filter(\.isNumber).prefix(6))
                        if filtered != newValue {
                            code = filtered
                        }
                    }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.hopesDanger)
                        .padding(.top, 12)
                }

                Spacer()

                HopesButton("완료", size: .large, isEnabled: canSubmit) {
                    focusedField = nil
                    onReset()
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 24)
            .padding(.bottom, 34)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onChange(of: codeRequested) { _, requested in
            if requested {
                focusedField = .code
            }
        }
    }

    private var canSubmit: Bool {
        !isLoading
            && codeRequested
            && isEmailValid
            && isCodeValid
            && PasswordPolicy.isValid(newPassword)
    }

    private var codeButtonTitle: String {
        if isLoading { return "처리 중" }
        return codeRequested ? "인증하기" : "번호 발송"
    }

    private var isCodeButtonEnabled: Bool {
        guard !isLoading else { return false }
        return codeRequested ? canSubmit : isEmailValid
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
            guard canSubmit else { return }
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
