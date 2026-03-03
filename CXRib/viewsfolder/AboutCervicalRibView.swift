import SwiftUI

struct AboutCervicalRibView: View {
    var navigate: (ContentView.Screen) -> Void

    // 🔹 Animation states
    @State private var appear = false
    @GestureState private var pressed = false

    var body: some View {
        ZStack {
            // 🌌 Aurora Gradient Background
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

            // ================= iOS BACK BUTTON =================
            VStack {
                HStack {
                    IOSBackButton(title: "Back") {
                        navigate(.homeDashboard)
                    }
                    Spacer()
                }
                .padding(.leading, 16)
                .padding(.top, 12)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : -20)
                .animation(.easeOut(duration: 0.5), value: appear)

                Spacer()
            }

            VStack(spacing: 25) {
                // MARK: - Title
                Text("About Cervical Rib")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 60)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : -20)
                    .animation(.easeOut(duration: 0.5), value: appear)

                // MARK: - Frosted Glass Info Card
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {

                        Text("🩺 What is a Cervical Rib?")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)

                        Text("""
A cervical rib is an **extra rib** that develops from the seventh cervical vertebra — located just above the collarbone. This additional rib is a **congenital condition**, meaning a person is born with it.

While many individuals with a cervical rib experience **no symptoms**, in some cases, it can cause **Thoracic Outlet Syndrome (TOS)** — a condition that results from compression of nerves or blood vessels between the rib and collarbone.
""")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(6)

                        Text("📷 How is it Detected?")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)

                        Text("""
Cervical ribs are most commonly detected using **X-rays**, **CT scans**, or **MRI**. AI-assisted systems like **CXRib** can help radiologists detect such conditions early, improving accuracy and diagnosis speed.
""")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(6)

                        Text("💡 Treatment and Care")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)

                        Text("""
In most cases, treatment is **not required** unless symptoms occur. When discomfort or nerve compression arises, **physiotherapy**, **posture correction**, or, in severe cases, **surgical removal** of the rib may be advised.
""")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(6)
                    }
                    .padding(25)
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
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 25)
                    .padding(.bottom, 100)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 30)
                    .animation(.easeOut(duration: 0.6), value: appear)
                }

                Spacer()

                // MARK: - Bottom Button
                Button(action: {
                    navigate(.homeDashboard)
                }) {
                    Text("Back to Dashboard")
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
                        .shadow(
                            color: Color.blue.opacity(0.4),
                            radius: pressed ? 3 : 8,
                            x: 0,
                            y: pressed ? 1 : 5
                        )
                        .scaleEffect(pressed ? 0.97 : 1)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 30)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .updating($pressed) { _, state, _ in
                            state = true
                        }
                )
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)
                .animation(.easeOut(duration: 0.5), value: appear)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            appear = true
        }
        .navigationBarHidden(true)
    }
}

// ✅ Preview
struct AboutCervicalRibView_Previews: PreviewProvider {
    static var previews: some View {
        AboutCervicalRibView(navigate: { _ in })
            .preferredColorScheme(.dark)
            .previewDisplayName("Aurora - About Cervical Rib")
    }
}

