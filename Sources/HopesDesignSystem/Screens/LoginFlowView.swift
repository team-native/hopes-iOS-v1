import SwiftUI

public struct LoginFlowView: View {
    private enum Screen {
        case guide
        case login
        case signUp
        case onboarding
        case chatHome
        case chatDetail
    }

    @State private var screen: Screen
    @State private var email = ""
    @State private var password = ""
    @State private var signUpEmail = ""
    @State private var name = ""
    @State private var major = ""
    @State private var cohort = ""
    @State private var chatMessage = ""
    @State private var chatReply = ""

    private let onLogin: () -> Void
    private let onSignUp: (SignUpFormData) -> Void
    private let onStartChat: () -> Void

    public init(
        isLoginInitiallyOpen: Bool = false,
        isSignUpInitiallyOpen: Bool = false,
        isOnboardingInitiallyOpen: Bool = false,
        isChatHomeInitiallyOpen: Bool = false,
        isChatDetailInitiallyOpen: Bool = false,
        onLogin: @escaping () -> Void = {},
        onSignUp: @escaping (SignUpFormData) -> Void = { _ in },
        onStartChat: @escaping () -> Void = {}
    ) {
        let initialScreen: Screen = if isChatDetailInitiallyOpen {
            .chatDetail
        } else if isChatHomeInitiallyOpen {
            .chatHome
        } else if isOnboardingInitiallyOpen {
            .onboarding
        } else if isSignUpInitiallyOpen {
            .signUp
        } else if isLoginInitiallyOpen {
            .login
        } else {
            .guide
        }

        _screen = State(initialValue: initialScreen)
        self.onLogin = onLogin
        self.onSignUp = onSignUp
        self.onStartChat = onStartChat
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
                    onSignUp: { data in
                        onSignUp(data)
                        transition(to: .onboarding)
                    },
                    onGoToLogin: {
                        transition(to: .login)
                    }
                )
                .transition(.move(edge: .trailing))

            case .onboarding:
                OnboardingView {
                    onStartChat()
                    transition(to: .chatHome)
                }
                    .transition(.move(edge: .trailing))

            case .chatHome:
                ChatHomeView(
                    message: $chatMessage,
                    onSend: { _ in
                        transition(to: .chatDetail)
                    }
                )
                    .transition(.move(edge: .trailing))

            case .chatDetail:
                ChatDetailView(
                    reply: $chatReply,
                    onBack: {
                        transition(to: .chatHome)
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
