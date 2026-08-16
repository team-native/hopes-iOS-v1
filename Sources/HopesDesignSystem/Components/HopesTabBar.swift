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

    private static let figmaTabCenters: [CGFloat] = [55, 143, 231, 319]
    private static let figmaWidth: CGFloat = 402

    public init(
        selection: Binding<HopesTab>,
        onSelect: @escaping (HopesTab) -> Void = { _ in }
    ) {
        _selection = selection
        self.onSelect = onSelect
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Color.white

                ForEach(Array(HopesTab.allCases.enumerated()), id: \.offset) { index, tab in
                    tabButton(tab)
                        .position(x: geometry.size.width * Self.figmaTabCenters[index] / Self.figmaWidth, y: 42)
                }
            }
            .frame(width: geometry.size.width, height: 84, alignment: .top)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(Color.hopesBorder)
                    .frame(height: 1)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 84, alignment: .top)
        .ignoresSafeArea(.container, edges: .bottom)
    }

    private func tabButton(_ tab: HopesTab) -> some View {
        Button {
            selection = tab
            onSelect(tab)
        } label: {
            ZStack(alignment: .top) {
                if selection == tab && tab != .history {
                    Capsule()
                        .fill(Color.hopesBrandTint)
                        .frame(width: 60, height: 30)
                        .position(x: 30, y: 27)
                }

                Image(systemName: selection == tab ? tab.selectedIconName : tab.iconName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(
                        selection == tab
                            ? Color(red: 13 / 255, green: 138 / 255, blue: 229 / 255)
                            : Color.hopesTextPlaceholder
                    )
                    .frame(width: 24, height: 24)
                    .position(x: 30, y: 24)

                Text(tab.title)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(
                        selection == tab
                            ? Color(red: 13 / 255, green: 138 / 255, blue: 229 / 255)
                            : Color.hopesTextSecondary
                    )
                    .frame(width: 46, height: 12, alignment: .center)
                    .position(x: 30, y: 47)
            }
            .frame(width: 60, height: 84, alignment: .top)
            .contentShape(Rectangle())
        }
        .frame(width: 60, height: 84, alignment: .top)
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
