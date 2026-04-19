import SwiftUI

struct SplashView: View {
    @Binding var isActive: Bool

    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.92

    var body: some View {
        ZStack {
            // Clean pastel green background
            Color(red: 0.933, green: 0.965, blue: 0.945)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // App Icon
                Image("SplashIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                    .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 6)

                // App Name
                Text("MyRuqyah")
                    .font(.poppins(22, weight: .semibold))
                    .foregroundColor(Color(hex: "2D6A4F"))
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            // Smooth fade-in + subtle scale
            withAnimation(.easeOut(duration: 0.6)) {
                opacity = 1.0
                scale = 1.0
            }

            // Fade out and dismiss
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeIn(duration: 0.4)) {
                    opacity = 0
                    scale = 1.04
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                isActive = false
            }
        }
    }
}

#Preview {
    SplashView(isActive: .constant(true))
}
