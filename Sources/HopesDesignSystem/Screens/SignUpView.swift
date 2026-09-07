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
    enum SignUpField: Hashable {
        case email
        case verificationCode
        case name
        case password
        case passwordConfirm
    }

    @State var verificationCode = ""
    @State var password = ""
    @State var passwordConfirm = ""
    @State var isPasswordVisible = false
    @State var isPasswordConfirmVisible = false
    @State var isRequestingVerification = false
    @State var isConfirmingVerification = false
    @State var isSigningUp = false
    @State var isEmailVerified = false
    @State var statusMessage: String?
    @State var errorMessage: String?
    @FocusState var focusedField: SignUpField?

    @Binding var email: String
    @Binding var name: String
    @Binding var major: String
    @Binding var cohort: String

    let onSignUp: (SignUpFormData) -> Void
    let onGoToLogin: () -> Void

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

}

#Preview("회원가입") {
    @Previewable @State var email = ""
    @Previewable @State var name = ""
    @Previewable @State var major = ""
    @Previewable @State var cohort = ""

    SignUpView(email: $email, name: $name, major: $major, cohort: $cohort)
        .frame(width: 402, height: 874)
}
