import SwiftUI

public struct LoginSwipeGuideView: View {
    private let onOpenLogin: () -> Void

    @State private var sheetDragOffset: CGFloat = 0

    public init(onOpenLogin: @escaping () -> Void = {}) {
        self.onOpenLogin = onOpenLogin
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.hopesHeroGradient
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    HopesLogo(placement: .onBrand)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, proxy.safeAreaInsets.top + 14)
                        .padding(.horizontal, 32)

                    hero
                        .padding(.horizontal, 32)
                        .padding(.top, max(72, proxy.size.height * 0.192))

                    Spacer(minLength: 20)

                    swipeCue

                    loginSheet
                        .offset(y: max(sheetDragOffset, -24))
                        .gesture(openLoginGesture)
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var hero: some View {
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

    private var swipeCue: some View {
        VStack(spacing: 0) {
            ZStack {
                Image("SwipeChevronBack", bundle: .module)
                    .resizable()
                    .frame(width: 34, height: 17)
                    .offset(y: -9)

                Image("SwipeChevronFront", bundle: .module)
                    .resizable()
                    .frame(width: 34, height: 17)
                    .offset(y: 9)
            }
            .frame(height: 42)

            Text("위로 스와이프하기")
                .font(HopesTypography.inter(size: 18, weight: .bold, relativeTo: .headline))
                .foregroundStyle(.white)
                .padding(.top, 4)

            Text("로그인 창을 올려 학교 이메일로 시작해요.")
                .font(HopesTypography.inter(size: 12, relativeTo: .caption))
                .foregroundStyle(Color("HopesSwipeHint", bundle: .module))
                .padding(.top, 6)
        }
        .frame(height: 118, alignment: .top)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityHint("로그인 창을 열려면 아래 시트를 위로 쓸어 올리세요.")
    }

    private var loginSheet: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color("HopesSheetHandle", bundle: .module))
                .frame(width: 86, height: 5)
                .padding(.top, 20)

            Spacer()

            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("로그인")
                        .font(HopesTypography.inter(size: 25, weight: .bold, relativeTo: .title2))
                        .foregroundStyle(Color("HopesSheetTitle", bundle: .module))

                    Text("학교 이메일로 로그인하세요.")
                        .font(HopesTypography.inter(size: 12, relativeTo: .caption))
                        .foregroundStyle(Color("HopesSheetSecondary", bundle: .module))
                }

                Spacer(minLength: 0)

                HopesButton(
                    "열기",
                    size: .small,
                    width: .fit,
                    action: openLogin
                )
            }
            .padding(.horizontal, 30)

            Spacer()
        }
        .frame(height: 190)
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 28,
                topTrailingRadius: 28
            )
        )
        .shadow(color: Color(red: 10 / 255, green: 31 / 255, blue: 56 / 255).opacity(0.16), radius: 14, y: -6)
        .accessibilityAction(named: "로그인 열기", openLogin)
    }

    private var openLoginGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                sheetDragOffset = min(0, value.translation.height)
            }
            .onEnded { value in
                if value.translation.height < -60 || value.predictedEndTranslation.height < -100 {
                    openLogin()
                } else {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                        sheetDragOffset = 0
                    }
                }
            }
    }

    private func openLogin() {
        withAnimation(.easeOut(duration: 0.18)) {
            sheetDragOffset = -24
        }
        onOpenLogin()
    }
}

#Preview("로그인 스와이프 안내") {
    LoginSwipeGuideView()
        .frame(width: 402, height: 874)
}
