import SwiftUI

struct SplashView: View {
    var navigate: (ContentView.Screen) -> Void
    @State private var animate = false

    var body: some View {
        ZStack {
            // MARK: - 🌌 Background: Midnight Aurora Gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.10, green: 0.12, blue: 0.40), // Deep Indigo
                    Color(red: 0.36, green: 0.22, blue: 0.55), // Royal Violet
                    Color(red: 0.78, green: 0.36, blue: 0.60)  // Magenta Mist
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 25) {
                Spacer()

                // MARK: - Animated App Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.15),
                                    Color.white.opacity(0.05)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 160, height: 160)
                        .shadow(color: Color.purple.opacity(0.3), radius: 20, x: 0, y: 8)

                    Image("Image")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 150)
                        .opacity(0.9)
                        .shadow(color: Color.purple.opacity(0.5), radius: 15, x: 0, y: 6)
                        .animation(.easeInOut(duration: 1.6)
                            .repeatForever(autoreverses: true),
                                   value: animate)
                }

                // MARK: - Title
                Text("Welcome to CXRib")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .opacity(animate ? 1 : 0)
                    .animation(.easeIn(duration: 1.2).delay(0.4), value: animate)

                Spacer()

                // MARK: - Tagline
                Text("Powered by AI for Cervical Rib Detection")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(10)
                    .opacity(animate ? 1 : 0)
                    .animation(.easeOut(duration: 1.2).delay(0.8), value: animate)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            animate = true

            // ==================================================
            // 🔥 PART 4 – FILE 5 ADDITIONS (Federated Learning)
            // ==================================================

            // Boot all subsystems immediately
            _ = FLDatasetManager.shared      // initializes training folder
            _ = FLModelManager.shared        // loads global model
            _ = NetworkMonitor.shared        // starts wifi monitoring

            // Start background FL sync timer
            FLBackgroundSync.shared.startAutoSync()

            // ==================================================

            // Navigate to onboarding after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                navigate(.onboarding)
            }
        }
    }
}

// PREVIEW
struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView { _ in }
            .preferredColorScheme(.dark)
            .previewDisplayName("Clean Aurora Splash Screen")
    }
}

