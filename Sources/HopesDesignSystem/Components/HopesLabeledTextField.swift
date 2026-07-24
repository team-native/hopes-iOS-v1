import SwiftUI

public struct HopesLabeledTextField: View {
    private let title: String
    private let placeholder: String
    private let isSecure: Bool
    private let isEnabled: Bool
    @Binding private var text: String

    public init(
        _ title: String,
        text: Binding<String>,
        placeholder: String = "",
        isSecure: Bool = false,
        isEnabled: Bool = true
    ) {
        self.title = title
        _text = text
        self.placeholder = placeholder
        self.isSecure = isSecure
        self.isEnabled = isEnabled
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.hopesTextPrimary)

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .textFieldStyle(.plain)
            .font(.subheadline)
            .foregroundStyle(Color.hopesTextPrimary)
            .padding(.horizontal, 16)
            .frame(height: HopesMetrics.textFieldHeight)
            .background(Color.hopesInputBackground)
            .clipShape(
                RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius)
            )
            .overlay {
                RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius)
                    .stroke(Color.hopesBorder, lineWidth: 1)
            }
            .disabled(!isEnabled)
            .opacity(isEnabled ? 1 : 0.45)
        }
    }
}

#Preview("Hopes Labeled Text Fields") {
    @Previewable @State var email = "s20000@gsm.hs.kr"
    @Previewable @State var password = ""

    VStack(spacing: 24) {
        HopesLabeledTextField(
            "이메일",
            text: $email,
            placeholder: "학교 이메일"
        )

        HopesLabeledTextField(
            "비밀번호",
            text: $password,
            placeholder: "비밀번호",
            isSecure: true
        )

        HopesLabeledTextField(
            "비활성 입력",
            text: .constant("수정할 수 없어요"),
            isEnabled: false
        )
    }
    .padding()
    .background(Color.hopesBackground)
}
