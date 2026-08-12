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
        HStack(alignment: .top, spacing: 28) {
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
                            .frame(width: 60, height: 30)
                            .background(
                                selection == tab
                                    ? Color.hopesBrandTint
                                    : .clear
                            )
                            .clipShape(Capsule())

                        Text(tab.title)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(
                                selection == tab
                                    ? Color.hopesBrandPrimary
                                    : Color.hopesTextSecondary
                            )
                    }
                    .frame(width: 60)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
                .accessibilityAddTraits(selection == tab ? .isSelected : [])
            }
        }
        .padding(.leading, 25)
        .padding(.top, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
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

#Preview("Hopes Tab Bar") {
    @Previewable @State var selection: HopesTab = .home

    VStack {
        Spacer()
        HopesTabBar(selection: $selection)
    }
    .background(Color.hopesBackground)
}
