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
                TextField("학교 이메일", text: $email)
                    .textFieldStyle(HopesResetFieldStyle())
                    .focused($focusedField, equals: .email)
                    .disabled(codeRequested)

                if codeRequested {
                    fieldTitle("인증번호", top: 18)
                    TextField("숫자 6자리", text: $code)
                        .textFieldStyle(HopesResetFieldStyle())
                        .focused($focusedField, equals: .code)

                    fieldTitle("새 비밀번호", top: 18)
                    SecureField("영문+숫자 8~15자", text: $newPassword)
                        .textFieldStyle(HopesResetFieldStyle())
                        .focused($focusedField, equals: .newPassword)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.hopesDanger)
                        .padding(.top, 12)
                }

                Spacer()

                HopesButton(
                    isLoading ? "처리 중..." : codeRequested ? "비밀번호 변경" : "인증번호 받기",
                    isEnabled: canSubmit
                ) {
                    focusedField = nil
                    if codeRequested {
                        onReset()
                    } else {
                        onRequestCode()
                    }
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 24)
            .padding(.bottom, 34)
        }
    }

    private var canSubmit: Bool {
        guard !isLoading, !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        return !codeRequested || (code.range(of: #"^\d{6}$"#, options: .regularExpression) != nil && PasswordPolicy.isValid(newPassword))
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
            .frame(height: 48)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.hopesBorder, lineWidth: 1)
            }
    }
}
