import SwiftUI

public struct LoginFlowView: View {
    @State private var isLoginOpen = false
    @State private var email = ""
    @State private var password = ""

    private let onLogin: () -> Void
    private let onSignUp: () -> Void

    public init(
        isLoginInitiallyOpen: Bool = false,
        onLogin: @escaping () -> Void = {},
        onSignUp: @escaping () -> Void = {}
    ) {
        _isLoginOpen = State(initialValue: isLoginInitiallyOpen)
        self.onLogin = onLogin
        self.onSignUp = onSignUp
    }

    public var body: some View {
        ZStack {
            if isLoginOpen {
                LoginView(
                    email: $email,
                    password: $password,
                    onLogin: onLogin,
                    onSignUp: onSignUp
                )
                .transition(.move(edge: .bottom))
            } else {
                LoginSwipeGuideView {
                    withAnimation(.spring(response: 0.42, dampingFraction: 0.88)) {
                        isLoginOpen = true
                    }
                }
                .transition(.opacity)
            }
        }
    }
}

#Preview("로그인 플로우") {
    LoginFlowView()
        .frame(width: 402, height: 874)
}
