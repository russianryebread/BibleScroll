import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color(red: 0.035, green: 0.10, blue: 0.13)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Text("B")
                    .font(.custom("Georgia", size: 94))
                    .foregroundStyle(Color(red: 0.98, green: 0.96, blue: 0.88))
                    .accessibilityHidden(true)

                Text("Bible Scroll")
                    .font(.custom("Georgia", size: 30))
                    .foregroundStyle(.white)
            }
            .accessibilityElement(children: .combine)
        }
    }
}
