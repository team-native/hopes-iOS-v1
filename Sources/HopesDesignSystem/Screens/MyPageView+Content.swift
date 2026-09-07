import SwiftUI

extension MyPageView {
    var header: some View {
        HStack {
            HopesLogo()
            Spacer()
            HopesButton("설정", variant: .secondary, size: .small, width: .fixed(54)) {
                focusedField = nil
                onOpenSettings()
            }
        }
        .frame(height: 42, alignment: .top)
    }

    var profileCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("프로필")
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.hopesTextPrimary)
            focusedNameField.padding(.top, 24)
            Text("자기소개 (AI 응답 개인화에 활용됩니다)")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.hopesTextPrimary)
                .padding(.top, 24)
                .simultaneousGesture(TapGesture().onEnded { focusedField = nil })

            ZStack(alignment: .topLeading) {
                if introduction.isEmpty {
                    Text("예: 프론트엔드에 관심 많은 8기 학생이에요.")
                        .font(.subheadline)
                        .foregroundStyle(Color.hopesTextSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $introduction)
                    .font(.subheadline)
                    .foregroundStyle(Color.hopesTextPrimary)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 8)
                    .frame(height: 92)
                    .focused($focusedField, equals: .introduction)
            }
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius)
                    .stroke(Color.hopesBorder, lineWidth: 1)
            }
            .padding(.top, 24)
        }
        .padding(.horizontal, cardContentHorizontalPadding)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, minHeight: 326, maxHeight: 326, alignment: .topLeading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius)
                .stroke(Color.hopesBorder, lineWidth: 1)
        }
    }

    var focusedNameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("이름")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.hopesTextPrimary)
                .simultaneousGesture(TapGesture().onEnded { focusedField = nil })
            TextField("이름", text: $name)
                .textFieldStyle(.plain)
                .font(.subheadline)
                .foregroundStyle(Color.hopesTextPrimary)
                .padding(.horizontal, 16)
                .frame(height: HopesMetrics.textFieldHeight)
                .background(Color.hopesInputBackground)
                .clipShape(RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: HopesMetrics.controlCornerRadius)
                        .stroke(Color.hopesBorder, lineWidth: 1)
                }
                .focused($focusedField, equals: .name)
        }
    }

    var accountCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("계정 정보 (수정 불가)")
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.hopesTextPrimary)
            Text("이메일: \(email)").padding(.top, 22)
            Text("전공: \(major)").padding(.top, 10)
        }
        .font(.footnote)
        .foregroundStyle(Color.hopesTextPrimary)
        .padding(.horizontal, cardContentHorizontalPadding)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, minHeight: 128, maxHeight: 128, alignment: .topLeading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: HopesMetrics.cardCornerRadius)
                .stroke(Color.hopesBorder, lineWidth: 1)
        }
    }
}
