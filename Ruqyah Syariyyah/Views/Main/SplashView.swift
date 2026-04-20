import SwiftUI

struct SplashView: View {
    @Binding var isActive: Bool
    @Environment(\.colorScheme) private var colorScheme

    @State private var bismillahOpacity: Double = 0
    @State private var bismillahScale: CGFloat = 0.9
    @State private var brandingOpacity: Double = 0

    var body: some View {
        ZStack {
            // Soft mint green background
            Color(red: 0.933, green: 0.965, blue: 0.945)
                .ignoresSafeArea()

            // Bismillah — center of screen
            Text("بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ")
                .font(.amiriQuran(32))
                .foregroundColor(Color(hex: "2D6A4F"))
                .multilineTextAlignment(.center)
                .scaleEffect(bismillahScale)
                .opacity(bismillahOpacity)

            // Branding — bottom
            VStack(spacing: 8) {
                Spacer()

                HStack(spacing: 8) {
                    Image("SplashIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    Text("MyRuqyah")
                        .font(.poppins(16, weight: .medium))
                        .foregroundColor(Color(hex: "2D6A4F"))
                }
                .padding(.bottom, 50)
            }
            .opacity(brandingOpacity)
        }
        .onAppear {
            // Bismillah fades in with subtle scale
            withAnimation(.easeOut(duration: 0.8)) {
                bismillahOpacity = 1.0
                bismillahScale = 1.0
            }

            // Branding fades in after a short delay
            withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
                brandingOpacity = 1.0
            }

            // Fade out everything
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeIn(duration: 0.4)) {
                    bismillahOpacity = 0
                    bismillahScale = 1.05
                    brandingOpacity = 0
                }
            }

            // Dismiss
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                isActive = false
            }
        }
    }
}

#Preview {
    SplashView(isActive: .constant(true))
}
