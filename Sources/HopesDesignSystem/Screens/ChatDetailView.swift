import SwiftUI

public struct ChatDetailView: View {
    @State private var selectedTab: HopesTab = .chat
    @State private var isSaved = false
    @State private var isLiked = false
    @Binding private var reply: String

    private let onBack: () -> Void
    private let onShowSources: () -> Void
    private let onSend: (String) -> Void
    private let onShare: () -> Void

    public init(
        reply: Binding<String>,
        onBack: @escaping () -> Void = {},
        onShowSources: @escaping () -> Void = {},
        onSend: @escaping (String) -> Void = { _ in },
        onShare: @escaping () -> Void = {}
    ) {
        _reply = reply
        self.onBack = onBack
        self.onShowSources = onShowSources
        self.onSend = onSend
        self.onShare = onShare
    }

    public var body: some View {
        ZStack(alignment: .top) {
            Color.hopesBackground

            header
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 72)

            userBubble
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 150)

            answerBubble
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 232)

            responseActions
                .padding(.leading, 44)
                .padding(.top, 364)

            sourceCard
                .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
                .padding(.top, 430)

            composer
                .padding(.top, 716)

            HopesTabBar(selection: $selectedTab)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
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
            .accessibilityLabel("뒤로")

            VStack(alignment: .leading, spacing: 1) {
                Text("기숙사 생활")
                    .font(.system(size: 27, weight: .bold))
                    .foregroundStyle(Color.hopesTextPrimary)

                Text("선배 답변 · 실제 경험 기반")
                    .font(.footnote)
                    .foregroundStyle(Color.hopesTextSecondary)
            }

            Spacer(minLength: 8)

            HopesButton(
                isSaved ? "저장됨" : "저장",
                variant: .secondary,
                size: .small,
                width: .fixed(isSaved ? 64 : 54)
            ) {
                isSaved.toggle()
            }
        }
    }

    private var userBubble: some View {
        HStack {
            Spacer(minLength: 70)

            Text("기숙사 하루 일과가 어떻게 돼?")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 58)
                .background(Color.hopesBrandPrimary)
                .clipShape(RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius))
        }
    }

    private var answerBubble: some View {
        Text(
            "평일은 저녁 식사 후 자습, 점호 순서로 흘러가요. "
                + "처음엔 빠듯하지만 일주일 정도 지나면 개인 루틴이 잡혀요."
        )
        .font(.subheadline)
        .foregroundStyle(Color.hopesTextPrimary)
        .lineSpacing(2)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 110)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius)
                .stroke(Color.hopesBorder, lineWidth: 1)
        }
    }

    private var responseActions: some View {
        HStack(spacing: 12) {
            HopesButton(
                isLiked ? "좋아요!" : "좋아요",
                variant: .secondary,
                size: .small,
                width: .fixed(isLiked ? 84 : 76)
            ) {
                isLiked.toggle()
            }

            HopesButton(
                "더 물어보기",
                size: .small,
                width: .fixed(104)
            ) {
                reply = "기숙사 생활에 대해 더 알려줘."
            }

            HopesButton(
                "공유",
                variant: .secondary,
                size: .small,
                width: .fixed(76),
                action: onShare
            )
        }
    }

    private var sourceCard: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 10) {
                Text("답변 근거")
                    .font(.callout.weight(.bold))
                    .foregroundStyle(Color.hopesTextPrimary)

                Text("점호 시간, 자습실 분위기, 빨래 루틴을 선배 답변에서 정리했어요.")
                    .font(.footnote)
                    .foregroundStyle(Color.hopesTextSecondary)
                    .lineSpacing(2)
            }

            Spacer(minLength: 0)

            HopesButton(
                "보기",
                variant: .secondary,
                size: .compact,
                width: .fixed(54),
                action: onShowSources
            )
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .frame(height: 106)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius)
                .stroke(Color.hopesBorder, lineWidth: 1)
        }
    }

    private var composer: some View {
        HStack(spacing: 14) {
            TextField("추가 질문 입력", text: $reply)
                .font(.footnote)
                .foregroundStyle(Color.hopesTextPrimary)
                .padding(.horizontal, 20)
                .frame(height: 44)
                .background(Color.hopesInputBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.hopesBorder, lineWidth: 1)
                }
                .onSubmit(sendReply)

            Button("전송", action: sendReply)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 58, height: 44)
                .background(Color.hopesBrandPrimary)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: HopesMetrics.controlCornerRadius
                    )
                )
                .disabled(trimmedReply.isEmpty)
                .opacity(trimmedReply.isEmpty ? 0.45 : 1)
        }
        .padding(.horizontal, HopesMetrics.screenHorizontalPadding)
        .frame(height: 74)
        .background(.white)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.hopesBorder)
                .frame(height: 1)
        }
    }

    private var trimmedReply: String {
        reply.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func sendReply() {
        guard !trimmedReply.isEmpty else {
            return
        }

        onSend(trimmedReply)
        reply = ""
    }
}

#Preview("채팅 상세") {
    @Previewable @State var reply = ""

    ChatDetailView(reply: $reply)
        .frame(width: 402, height: 874)
}
