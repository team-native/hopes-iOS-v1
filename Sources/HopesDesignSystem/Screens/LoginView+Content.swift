import SwiftUI

enum LoginScrollTarget {
    static let top = "login-sheet-top"
}

extension LoginView {
    var hero: some View {
        VStack(alignment: .leading, spacing: 13) {
            Text("선배에게 묻는\n가장 솔직한\n학교 이야기")
                .font(.system(size: 31, weight: .bold))
                .foregroundStyle(.white)
                .lineSpacing(2)

            Text("재학생, 신입생, 입학 희망자를 위한 AI 선배 챗봇.\n실제 선배들의 경험으로 답해드려요.")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color("HopesHeroSecondary", bundle: .module))
                .lineSpacing(5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var swipeCue: some View {
        VStack(spacing: 0) {
            ZStack {
                Image("SwipeChevronBack", bundle: .module)
                    .resizable()
                    .frame(width: 17, height: 34)
                    .rotationEffect(.degrees(90))
                    .offset(y: -9)
                Image("SwipeChevronFront", bundle: .module)
                    .resizable()
                    .frame(width: 17, height: 34)
                    .rotationEffect(.degrees(90))
                    .offset(y: 9)
            }
            .frame(height: 42)

            Text("위로 스와이프하기")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .padding(.top, 4)

            Text("로그인 창을 올려 학교 이메일로 시작해요.")
                .font(.system(size: 12))
                .foregroundStyle(Color("HopesSwipeHint", bundle: .module))
                .padding(.top, 6)
        }
        .frame(height: 118, alignment: .top)
        .frame(maxWidth: .infinity)
    }

    func loginSheet() -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            loginSheetContent.frame(minHeight: 502, alignment: .top)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .frame(height: 502)
        .background(.white)
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28))
        .shadow(color: Color(red: 13 / 255, green: 26 / 255, blue: 46 / 255).opacity(0.12), radius: 16, y: 7)
    }

    var loginSheetContent: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color("HopesSheetHandle", bundle: .module))
                .frame(width: 86, height: 5)
                .padding(.top, 20)

            VStack(alignment: .leading, spacing: 0) {
                Text("로그인")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Color.hopesTextPrimary)
                Text("학교 이메일로 로그인하세요.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.hopesTextSecondary)
                    .padding(.top, 4)
                Text("이메일")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.hopesTextPrimary)
                    .padding(.top, 39)

                TextField("이메일", text: $email)
                    .hopesEmailInputTraits()
                    .focused($focusedField, equals: .email)
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
                    .id(LoginField.email)

                Text("비밀번호")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.hopesTextPrimary)
                    .padding(.top, 15)

                Group {
                    if isPasswordVisible {
                        TextField("비밀번호", text: $password).focused($focusedField, equals: .password)
                    } else {
                        SecureField("비밀번호", text: $password).focused($focusedField, equals: .password)
                    }
                }
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
                    Button { isPasswordVisible.toggle() } label: {
                        Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.hopesTextSecondary)
                            .frame(width: 42, height: 40)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isPasswordVisible ? "비밀번호 숨기기" : "비밀번호 보기")
                }
                .padding(.top, 9)
                .accessibilityLabel("비밀번호")
                .id(LoginField.password)

                HStack(spacing: 0) {
                    Spacer()
                    Button {
                        focusedField = nil
                        onForgotPassword()
                    } label: {
                        Text("비밀번호를 잊으셨나요?")
                    }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.hopesBrandPrimary)
                        .buttonStyle(.plain)
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 32)
            .padding(.top, 43)

            HopesButton(
                isLoading ? "로그인 중..." : "로그인",
                isEnabled: !isLoading && !email.isEmpty && !password.isEmpty
            ) {
                focusedField = nil
                onLogin()
            }
            .padding(.horizontal, 32)
            .padding(.top, 35)

            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.hopesDanger)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
            }

            HStack(spacing: 0) {
                Spacer()
                Button {
                    focusedField = nil
                    onSignUp()
                } label: {
                    Text("계정이 없으신가요?  회원가입")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.hopesTextSecondary)
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .padding(.horizontal, 32)
            .padding(.top, errorMessage == nil ? 21 : 27)
        }
        .frame(minHeight: 502, alignment: .top)
        .frame(maxWidth: .infinity)
        .background { Color.clear.contentShape(Rectangle()).onTapGesture { focusedField = nil } }
        .id(LoginScrollTarget.top)
    }
}

extension View {
    @ViewBuilder
    func hopesEmailInputTraits() -> some View {
        #if os(iOS)
        textInputAutocapitalization(.never).keyboardType(.emailAddress).textContentType(.username)
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
