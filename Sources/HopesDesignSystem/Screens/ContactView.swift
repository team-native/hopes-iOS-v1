import SwiftUI

public struct ContactView: View {
    private enum ContactField: Hashable {
        case email
        case message
    }

    @State private var selectedTab: HopesTab = .settings
    @State private var email: String
    @State private var message: String
    @FocusState private var focusedField: ContactField?

    private let contactEmail: String
    private let onBack: () -> Void
    private let onDone: () -> Void
    private let onSend: (String, String) -> Void
    private let onSelectTab: (HopesTab) -> Void
    private let isSending: Bool
    private let errorMessage: String?

    public init(
        email: String = "",
        message: String = "",
        contactEmail: String = "gsm-chatbot@gsm.hs.kr",
        isSending: Bool = false,
        errorMessage: String? = nil,
        onBack: @escaping () -> Void = {},
        onDone: @escaping () -> Void = {},
        onSend: @escaping (String, String) -> Void = { _, _ in },
        onSelectTab: @escaping (HopesTab) -> Void = { _ in }
    ) {
        _email = State(initialValue: email)
        _message = State(initialValue: message)
        self.contactEmail = contactEmail
        self.isSending = isSending
        self.errorMessage = errorMessage
        self.onBack = onBack
        self.onDone = onDone
        self.onSend = onSend
        self.onSelectTab = onSelectTab
    }

    public var body: some View {
        ZStack(alignment: .top) {
            Color.hopesBackground
                .contentShape(Rectangle())
                .onTapGesture { focusedField = nil }

            header
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 72)

            contactCard
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 156)

            mailInformation
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 624)

            HopesTabBar(selection: $selectedTab) { tab in
                focusedField = nil
                onSelectTab(tab)
            }
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                focusedField = nil
                onBack()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.hopesBrandPrimary)
                    .frame(width: 38, height: 38)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                    .overlay {
                        RoundedRectangle(cornerRadius: 13)
                            .stroke(Color.hopesBorder, lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("설정으로 돌아가기")

            VStack(alignment: .leading, spacing: 2) {
                Text("문의하기")
                    .font(.title.weight(.bold))
                    .foregroundStyle(Color.hopesTextPrimary)

                Text("서비스 오류나 개선 의견을 보내요.")
                    .font(.footnote)
                    .foregroundStyle(Color.hopesTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

        }
        .simultaneousGesture(
            TapGesture().onEnded { focusedField = nil }
        )
    }

    private var contactCard: some View {
        HopesCard(padding: 24) {
            VStack(alignment: .leading, spacing: 0) {
                Text("이메일")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.hopesTextPrimary)
                    .simultaneousGesture(
                        TapGesture().onEnded { focusedField = nil }
                    )

                emailField
                    .padding(.top, 8)

                Text("문의 내용")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.hopesTextPrimary)
                    .padding(.top, 20)
                    .simultaneousGesture(
                        TapGesture().onEnded { focusedField = nil }
                    )

                messageEditor
                    .padding(.top, 16)

                HopesButton(
                    isSending ? "전송 중..." : "문의 보내기",
                    size: .large,
                    isEnabled: !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSending
                ) {
                    focusedField = nil
                    onSend(email, message)
                }
                .padding(.top, 30)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(Color.hopesDanger)
                        .padding(.top, 10)
                }
            }
            .padding(.top, 16)
        }
        .frame(height: 420)
    }

    private var emailField: some View {
        TextField("이메일", text: $email)
            .textFieldStyle(.plain)
            .font(.subheadline)
            .foregroundStyle(Color.hopesTextPrimary)
            .padding(.horizontal, 16)
            .frame(height: 40)
            .focused($focusedField, equals: .email)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius)
                    .stroke(Color(red: 217 / 255, green: 217 / 255, blue: 217 / 255), lineWidth: 1)
            }
    }

    private var messageEditor: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $message)
                .font(.subheadline)
                .foregroundStyle(Color.hopesTextPrimary)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 11)
                .padding(.vertical, 13)
                .focused($focusedField, equals: .message)

            if message.isEmpty {
                Text("예: 답변이 너무 짧게 나와요.")
                    .font(.subheadline)
                    .foregroundStyle(Color.hopesTextSecondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                    .allowsHitTesting(false)
            }
        }
        .frame(height: 146)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius)
                .stroke(Color.hopesBorder, lineWidth: 1)
        }
    }

    private var mailInformation: some View {
        Text("이메일 문의: \(contactEmail)")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color.hopesTextPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .frame(height: 70)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.hopesBorder, lineWidth: 1)
            }
    }
}

#Preview("문의하기") {
    ContactView()
        .frame(width: 402, height: 874)
}
