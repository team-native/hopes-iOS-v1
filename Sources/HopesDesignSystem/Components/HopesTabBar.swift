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
            "house"
        case .chat:
            "message"
        case .history:
            "clock.arrow.circlepath"
        case .settings:
            "person"
        }
    }

    fileprivate var selectedIconName: String {
        switch self {
        case .home:
            "house.fill"
        case .chat:
            "message.fill"
        case .history:
            "clock.arrow.circlepath"
        case .settings:
            "person.fill"
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
                        Image(systemName: selection == tab ? tab.selectedIconName : tab.iconName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(
                                selection == tab
                                    ? Color(red: 13 / 255, green: 138 / 255, blue: 229 / 255)
                                    : Color.hopesTextPlaceholder
                            )
                            .frame(width: 34, height: 18)
                            .modifier(TabIconContainerModifier(isSelected: selection == tab))

                        Text(tab.title)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(
                                selection == tab
                                    ? Color(red: 13 / 255, green: 138 / 255, blue: 229 / 255)
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
        .padding(.horizontal, 25)
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
