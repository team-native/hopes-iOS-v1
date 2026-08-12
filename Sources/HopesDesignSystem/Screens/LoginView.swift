import SwiftUI

public struct LoginView: View {
    @Binding private var email: String
    @Binding private var password: String

    private let onLogin: () -> Void
    private let onSignUp: () -> Void

    public init(
        email: Binding<String>,
        password: Binding<String>,
        onLogin: @escaping () -> Void = {},
        onSignUp: @escaping () -> Void = {}
    ) {
        _email = email
        _password = password
        self.onLogin = onLogin
        self.onSignUp = onSignUp
    }

    public var body: some View {
        ZStack {
            Color.hopesHeroGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HopesLogo(placement: .onBrand)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 14)
                    .padding(.horizontal, 32)

                Text("선배에게 묻는\n가장 솔직한\n학교 이야기")
                    .font(.system(size: 31, weight: .bold))
                    .foregroundStyle(.white)
                    .lineSpacing(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 32)
                    .padding(.top, 168)

                Spacer(minLength: 0)
            }

            VStack(spacing: 0) {
                Spacer(minLength: 0)
                loginSheet
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }

    private var loginSheet: some View {
        ZStack(alignment: .top) {
            Capsule()
                .fill(Color("HopesSheetHandle", bundle: .module))
                .frame(width: 86, height: 5)
                .padding(.top, 20)

            VStack(alignment: .leading, spacing: 0) {
                Text("로그인")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Color.hopesTextPrimary)

                Text("학교 이메일로 로그인하고 바로 질문을 시작하세요.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.hopesTextSecondary)
                    .padding(.top, 4)

                Text("이메일")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.hopesTextPrimary)
                    .padding(.top, 39)

                TextField("이메일", text: $email)
                    .hopesEmailInputTraits()
                    .font(.system(size: 15))
                    .foregroundStyle(Color.hopesTextPrimary)
                    .padding(.horizontal, 16)
                    .frame(height: 40)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(red: 217 / 255, green: 217 / 255, blue: 217 / 255), lineWidth: 1)
                    }
                    .padding(.top, 7)
                    .accessibilityLabel("이메일")

                Text("비밀번호")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.hopesTextPrimary)
                    .padding(.top, 15)

                SecureField("비밀번호", text: $password)
                    .hopesPasswordInputTraits()
                    .font(.system(size: 15))
                    .foregroundStyle(Color.hopesTextPrimary)
                    .padding(.leading, 16)
                    .padding(.trailing, 42)
                    .frame(height: 40)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(red: 217 / 255, green: 217 / 255, blue: 217 / 255), lineWidth: 1)
                    }
                    .overlay(alignment: .trailing) {
                        Image(systemName: "eye.slash")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.hopesTextSecondary)
                            .padding(.trailing, 10)
                    }
                    .padding(.top, 9)
                    .accessibilityLabel("비밀번호")
            }
            .padding(.horizontal, 32)
            .padding(.top, 68)

            HopesButton("로그인", action: onLogin)
                .padding(.horizontal, 32)
                .padding(.top, 355)

            Button(action: onSignUp) {
                Text("계정이 없으신가요?  회원가입")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.hopesTextSecondary)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 32)
            .padding(.top, 422)
        }
        .frame(height: 502, alignment: .top)
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 28,
                topTrailingRadius: 28
            )
        )
        .shadow(
            color: Color(red: 13 / 255, green: 26 / 255, blue: 46 / 255).opacity(0.12),
            radius: 16,
            y: 7
        )
    }
}

private extension View {
    @ViewBuilder
    func hopesEmailInputTraits() -> some View {
        #if os(iOS)
        textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)
            .textContentType(.username)
        #else
        self
        #endif
    }

    @ViewBuilder
    func hopesPasswordInputTraits() -> some View {
        #if os(iOS)
        textContentType(.password)
        #else
        self
        #endif
    }
}

#Preview("로그인 전체 시트") {
    @Previewable @State var email = ""
    @Previewable @State var password = ""

    LoginView(
        email: $email,
        password: $password
    )
    .frame(width: 402, height: 874)
}
