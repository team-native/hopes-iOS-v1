import SwiftUI

public enum HopesTab: String, CaseIterable, Sendable {
    case home
    case chat
    case history
    case settings

    fileprivate var title: String {
        switch self {
        case .home:
            "홈"
        case .chat:
            "채팅"
        case .history:
            "기록"
        case .settings:
            "설정"
        }
    }
}

public struct HopesTabBar: View {
    @Binding private var selection: HopesTab
    private let onSelect: (HopesTab) -> Void

    public init(
        selection: Binding<HopesTab>,
        onSelect: @escaping (HopesTab) -> Void = { _ in }
    ) {
        _selection = selection
        self.onSelect = onSelect
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(HopesTab.allCases, id: \.self) { tab in
                Button {
                    selection = tab
                    onSelect(tab)
                } label: {
                    VStack(spacing: -1) {
                        Text(selection == tab ? "●" : "○")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(
                                selection == tab
                                    ? Color.hopesBrandPrimary
                                    : Color.hopesTextPlaceholder
                            )
                            .frame(width: 34, height: 14)
                            .modifier(TabIconContainerModifier(isSelected: selection == tab))

                        Text(tab.title)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(
                                selection == tab
                                    ? Color.hopesBrandPrimary
                                    : Color.hopesTextSecondary
                            )
                            .frame(width: 46, height: 12, alignment: .center)
                    }
                    .frame(width: 60, height: 42, alignment: .top)
                    .contentShape(Rectangle())
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
                .accessibilityAddTraits(selection == tab ? .isSelected : [])
            }
        }
        .padding(.top, 12)
        .frame(maxWidth: .infinity)
        .frame(height: 84, alignment: .top)
        .frame(maxWidth: .infinity)
        .background(.white)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.hopesBorder)
                .frame(height: 1)
        }
    }
}

private struct TabIconContainerModifier: ViewModifier {
    let isSelected: Bool

    func body(content: Content) -> some View {
        content
            .frame(width: 60, height: 30, alignment: .center)
            .background {
                Capsule()
                    .fill(isSelected ? Color.hopesBrandTint : .clear)
            }
    }
}

#Preview("Hopes Tab Bar") {
    @Previewable @State var selection: HopesTab = .home

    VStack {
        Spacer()
        HopesTabBar(selection: $selection)
    }
    .background(Color.hopesBackground)
}
