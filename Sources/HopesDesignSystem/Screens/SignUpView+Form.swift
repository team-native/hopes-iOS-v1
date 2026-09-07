import SwiftUI

enum SignUpFieldKind {
    case plain
    case email
    case major
    case cohort
    case password
    case verificationCode
}

extension SignUpView {
    var signUpPanel: some View {
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

    var header: some View {
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

    var signUpCard: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                signUpField("학교 이메일", text: $email, placeholder: "s26055@gsm.hs.kr", kind: .email, focus: .email)
                verificationField
                signUpField("이름", text: $name, placeholder: "임서하", focus: .name)
                signUpField("과", text: $major, placeholder: "학과 선택", kind: .major)
                signUpField("기수", text: $cohort, placeholder: "기수 선택", kind: .cohort)
                signUpField("비밀번호", text: $password, placeholder: "영문·숫자 포함 8~15자", kind: .password, isPasswordVisible: $isPasswordVisible, focus: .password, validationMessage: passwordValidationMessage)
                signUpField("비밀번호 확인", text: $passwordConfirm, placeholder: "비밀번호 재입력", kind: .password, isPasswordVisible: $isPasswordConfirmVisible, focus: .passwordConfirm, validationMessage: passwordConfirmValidationMessage)
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

    var verificationField: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("인증번호")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.hopesTextPrimary)
                .simultaneousGesture(TapGesture().onEnded { focusedField = nil })

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

    func signUpField(_ title: String, text: Binding<String>, placeholder: String, kind: SignUpFieldKind = .plain, isPasswordVisible: Binding<Bool>? = nil, focus: SignUpField? = nil, validationMessage: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.hopesTextPrimary)
                .simultaneousGesture(TapGesture().onEnded { focusedField = nil })

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
                        Button { isPasswordVisible.wrappedValue.toggle() } label: {
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

    var signUpButton: some View {
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

    var loginLink: some View {
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
}

extension View {
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
