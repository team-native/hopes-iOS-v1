import SwiftUI

public struct HopesButton: View {
    public enum Variant: Sendable {
        case primary
        case secondary
        case danger
        case dark
    }

    public enum Size: Sendable {
        case compact
        case small
        case medium
        case regular
        case large
        case extraLarge

        fileprivate var height: CGFloat {
            switch self {
            case .compact:
                32
            case .small:
                36
            case .medium:
                38
            case .regular:
                46
            case .large:
                48
            case .extraLarge:
                52
            }
        }

        fileprivate var horizontalPadding: CGFloat {
            switch self {
            case .compact:
                12
            case .small:
                14
            case .medium:
                21
            case .regular, .large, .extraLarge:
                20
            }
        }

        fileprivate var font: Font {
            switch self {
            case .compact, .regular, .large, .extraLarge:
                .subheadline.weight(.semibold)
            case .small, .medium:
                .footnote.weight(.semibold)
            }
        }
    }

    public enum Width: Sendable {
        case fit
        case fill
        case fixed(CGFloat)

        fileprivate var minimum: CGFloat? {
            if case let .fixed(value) = self {
                return value
            }
            return nil
        }

        fileprivate var maximum: CGFloat? {
            switch self {
            case .fill:
                .infinity
            case .fit:
                nil
            case let .fixed(value):
                value
            }
        }
    }

    private let title: String
    private let variant: Variant
    private let size: Size
    private let width: Width
    private let isEnabled: Bool
    private let action: () -> Void

    public init(
        _ title: String,
        variant: Variant = .primary,
        size: Size = .regular,
        width: Width = .fill,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.variant = variant
        self.size = size
        self.width = width
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button(title, action: action)
            .font(size.font)
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, size.horizontalPadding)
            .frame(
                minWidth: width.minimum,
                maxWidth: width.maximum,
                minHeight: size.height,
                maxHeight: size.height
            )
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius)
                    .stroke(borderColor, lineWidth: borderColor == .clear ? 0 : 1)
            }
            .buttonStyle(HopesPressButtonStyle())
            .disabled(!isEnabled)
            .opacity(isEnabled ? 1 : 0.45)
            .accessibilityHint(isEnabled ? "" : "사용할 수 없는 버튼")
    }

    private var foregroundColor: Color {
        switch variant {
        case .primary, .dark:
            .white
        case .secondary:
            .hopesTextPrimary
        case .danger:
            .hopesDanger
        }
    }

    private var backgroundColor: Color {
        switch variant {
        case .primary:
            .hopesBrandPrimary
        case .secondary:
            .white
        case .danger:
            .hopesDangerSurface
        case .dark:
            .hopesTextPrimary
        }
    }

    private var borderColor: Color {
        switch variant {
        case .primary, .dark:
            .clear
        case .secondary, .danger:
            .hopesBorder
        }
    }
}

private struct HopesPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.78 : 1)
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

#Preview("Hopes Buttons") {
    VStack(alignment: .leading, spacing: 20) {
        HopesButton("로그인") {}
        HopesButton("채팅 시작하기", variant: .dark, size: .extraLarge) {}
        HopesButton("이 근거로 더 물어보기", size: .large) {}
        HopesButton("로그아웃", variant: .danger) {}
        HopesButton("열기", variant: .secondary, size: .compact, width: .fit) {}
        HopesButton("열기", size: .medium, width: .fixed(66)) {}
        HopesButton("채팅으로", variant: .secondary, size: .small, width: .fit) {}
        HopesButton("비활성화", isEnabled: false) {}
    }
    .padding()
    .background(Color.hopesBackground)
}
