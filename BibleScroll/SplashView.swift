import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color(red: 0.035, green: 0.10, blue: 0.13)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Image("BrandIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 116, height: 116)
                    .accessibilityHidden(true)

                Text("Bible Scroll")
                    .font(.custom("Georgia", size: 30))
                    .foregroundStyle(.white)
            }
            .accessibilityElement(children: .combine)
        }
    }
}
