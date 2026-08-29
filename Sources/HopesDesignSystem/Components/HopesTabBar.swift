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
            "마이페이지"
        }
    }

    fileprivate var iconName: String {
        switch self {
        case .home:
            "HopesTabHome"
        case .chat:
            "HopesTabChat"
        case .history:
            "HopesTabHistory"
        case .settings:
            "HopesTabMyPage"
        }
    }
}

public struct HopesTabBar: View {
    private let contentHeight: CGFloat = 56
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
        HStack(spacing: 0) {
            ForEach(HopesTab.allCases, id: \.self) { tab in
                tabButton(tab)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: contentHeight)
        .frame(maxWidth: .infinity)
        .background(.white)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.hopesBorder)
                .frame(height: 1)
        }
    }

    private func tabButton(_ tab: HopesTab) -> some View {
        Button {
            selection = tab
            onSelect(tab)
        } label: {
            VStack(spacing: 4) {
                Image(tab.iconName)
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(
                        selection == tab
                            ? Color(red: 13 / 255, green: 138 / 255, blue: 229 / 255)
                            : Color.hopesTextPlaceholder
                    )
                    .frame(width: 24, height: 24)

                Text(tab.title)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(
                        selection == tab
                            ? Color(red: 13 / 255, green: 138 / 255, blue: 229 / 255)
                            : Color.hopesTextSecondary
                    )
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(selection == tab ? .isSelected : [])
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
