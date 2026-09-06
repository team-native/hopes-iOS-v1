import Foundation

extension SignUpView {
    var normalizedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isSchoolEmailValid: Bool {
        normalizedEmail.range(
            of: #"^[A-Z0-9._%+-]+@gsm\.hs\.kr$"#,
            options: [.regularExpression, .caseInsensitive]
        ) != nil
    }

    var isVerificationCodeValid: Bool {
        verificationCode.range(of: #"^\d{6}$"#, options: .regularExpression) != nil
    }

    var passwordValidationMessage: String? {
        guard !password.isEmpty, !PasswordPolicy.isValid(password) else { return nil }
        return "영문과 숫자를 포함한 8~15자로 입력해주세요."
    }

    var passwordConfirmValidationMessage: String? {
        guard !passwordConfirm.isEmpty, PasswordPolicy.isValid(password), password != passwordConfirm else {
            return nil
        }
        return "비밀번호가 일치하지 않습니다."
    }

    var isFormValid: Bool {
        isSchoolEmailValid
            && isEmailVerified
            && !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !major.isEmpty
            && cohort.rangeOfCharacter(from: .decimalDigits) != nil
            && PasswordPolicy.isValid(password)
            && password == passwordConfirm
    }

    var verificationButtonTitle: String {
        if isEmailVerified { return "인증 완료" }
        if isRequestingVerification { return "발송 중" }
        if isConfirmingVerification { return "확인 중" }
        return isVerificationCodeValid ? "인증 확인" : "번호 발송"
    }

    func handleVerificationButton() {
        if isVerificationCodeValid {
            confirmVerification()
        } else {
            requestVerification()
        }
    }

    func requestVerification() {
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

    func confirmVerification() {
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

    func signUp() {
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
