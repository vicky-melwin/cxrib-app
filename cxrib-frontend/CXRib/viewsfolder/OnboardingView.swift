import SwiftUI

struct OnboardingView: View {
    var navigate: (ContentView.Screen) -> Void

    var body: some View {
        ZStack {
            // MARK: - 🌌 Background Gradient (Midnight Aurora)
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

            VStack(spacing: 35) {
                Spacer()

                // MARK: - App Icon
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
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.68, green: 0.36, blue: 0.90),
                                    Color(red: 0.40, green: 0.20, blue: 0.60)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.purple.opacity(0.5), radius: 15, x: 0, y: 6)
                }

                // MARK: - Frosted Welcome Card
                VStack(spacing: 18) {
                    Text("Welcome to CXRib")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("Detect cervical ribs easily with AI-powered analysis.")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                .padding(30)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 8)
                .padding(.horizontal, 25)

                // MARK: - Get Started Button
                Button(action: {
                    navigate(.loginSignup)
                }) {
                    Text("Get Started")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.33, green: 0.55, blue: 0.90),
                                    Color(red: 0.20, green: 0.35, blue: 0.70)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: Color.blue.opacity(0.5), radius: 10, x: 0, y: 6)
                        .padding(.horizontal, 40)
                }
                .padding(.top, 10)

                Spacer()

                // MARK: - Footer Tagline
                Text("Empowered by AI for Cervical Rib Detection")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// ✅ Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView { _ in }
            .preferredColorScheme(.dark)
            .previewDisplayName("Aurora Onboarding Screen")
    }
}

