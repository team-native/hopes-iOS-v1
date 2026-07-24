import SwiftUI

public struct LoginFlowView: View {
    private enum Screen {
        case guide
        case login
        case signUp
    }

    @State private var screen: Screen
    @State private var email = ""
    @State private var password = ""
    @State private var signUpEmail = ""
    @State private var name = ""
    @State private var major = ""
    @State private var cohort = ""

    private let onLogin: () -> Void
    private let onSignUp: (SignUpFormData) -> Void

    public init(
        isLoginInitiallyOpen: Bool = false,
        isSignUpInitiallyOpen: Bool = false,
        onLogin: @escaping () -> Void = {},
        onSignUp: @escaping (SignUpFormData) -> Void = { _ in }
    ) {
        let initialScreen: Screen = if isSignUpInitiallyOpen {
            .signUp
        } else if isLoginInitiallyOpen {
            .login
        } else {
            .guide
        }

        _screen = State(initialValue: initialScreen)
        self.onLogin = onLogin
        self.onSignUp = onSignUp
    }

    public var body: some View {
        ZStack {
            switch screen {
            case .guide:
                LoginSwipeGuideView {
                    transition(to: .login)
                }
                .transition(.opacity)

            case .login:
                LoginView(
                    email: $email,
                    password: $password,
                    onLogin: onLogin,
                    onSignUp: {
                        transition(to: .signUp)
                    }
                )
                .transition(.move(edge: .bottom))

            case .signUp:
                SignUpView(
                    email: $signUpEmail,
                    name: $name,
                    major: $major,
                    cohort: $cohort,
                    onSignUp: onSignUp,
                    onGoToLogin: {
                        transition(to: .login)
                    }
                )
                .transition(.move(edge: .trailing))
            }
        }
    }

    private func transition(to screen: Screen) {
        withAnimation(.spring(response: 0.42, dampingFraction: 0.88)) {
            self.screen = screen
        }
    }
}

#Preview("로그인 플로우") {
    LoginFlowView()
        .frame(width: 402, height: 874)
}
