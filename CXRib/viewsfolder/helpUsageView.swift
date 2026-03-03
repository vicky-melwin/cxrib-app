import SwiftUI

struct HelpUsageView: View {
    var navigate: (ContentView.Screen) -> Void

    // 🔹 Animation states
    @State private var appear = false
    @GestureState private var pressed = false

    var body: some View {
        ZStack {

            // 🌌 Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.10, green: 0.12, blue: 0.40),
                    Color(red: 0.36, green: 0.22, blue: 0.55),
                    Color(red: 0.78, green: 0.36, blue: 0.60)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // ================= BACK BUTTON =================
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
                .animation(.easeOut(duration: 0.45), value: appear)

                Spacer()
            }

            VStack(spacing: 0) {

                // ================= HEADER =================
                VStack(spacing: 6) {
                    Text("Help & Usage")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("How to use CXRib effectively")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 70)
                .padding(.bottom, 24)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : -20)
                .animation(.easeOut(duration: 0.5), value: appear)

                // ================= CONTENT =================
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {

                        animatedCard(
                            HelpCard(
                                title: "1. Uploading an X-ray",
                                icon: "xray",
                                points: [
                                    "Go to the Dashboard and tap Upload X-Ray Image",
                                    "Enter patient details carefully",
                                    "Upload a valid chest X-ray image only",
                                    "Color photos or normal images will be rejected",
                                    "Ensure the image is clear and properly oriented"
                                ]
                            ),
                            delay: 0
                        )

                        animatedCard(
                            HelpCard(
                                title: "2. Model Processing",
                                icon: "cpu",
                                points: [
                                    "The detection model is trained in Python using Google Colab",
                                    "The trained model is converted and integrated into the iOS app",
                                    "The model runs directly on the device",
                                    "Internet connection is not required",
                                    "Processing is fast and privacy-safe"
                                ]
                            ),
                            delay: 0.08
                        )

                        animatedCard(
                            HelpCard(
                                title: "3. Viewing Results",
                                icon: "doc.text.magnifyingglass",
                                points: [
                                    "After processing, the result screen will appear",
                                    "Detected condition is clearly displayed",
                                    "Confidence score indicates prediction reliability",
                                    "Users can return to the dashboard anytime"
                                ]
                            ),
                            delay: 0.16
                        )

                        animatedCard(
                            HelpCard(
                                title: "4. Report History",
                                icon: "clock.arrow.circlepath",
                                points: [
                                    "All scans are saved in Report History",
                                    "Works even when the app is offline",
                                    "Previous images and results can be reviewed anytime"
                                ]
                            ),
                            delay: 0.24
                        )

                        animatedCard(
                            HelpCard(
                                title: "Important Notes",
                                icon: "exclamationmark.triangle.fill",
                                points: [
                                    "Upload only chest X-ray scan images",
                                    "This application is developed for educational and academic purposes",
                                    "The results are supportive and not a medical diagnosis",
                                    "Final diagnosis should always be done by a qualified medical professional"
                                ]
                            ),
                            delay: 0.32
                        )
                    }
                    .padding(.horizontal, 25)
                    .padding(.bottom, 30)
                }

                // ================= BACK BUTTON =================
                Button {
                    navigate(.homeDashboard)
                } label: {
                    Text("Back to Dashboard")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
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
                        .cornerRadius(14)
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
                .animation(.easeOut(duration: 0.45), value: appear)
            }
        }
        .onAppear {
            appear = true
        }
        .navigationBarHidden(true)
    }

    // ======================================================
    // MARK: - Animated Wrapper
    // ======================================================
    private func animatedCard(_ card: HelpCard, delay: Double) -> some View {
        card
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 30)
            .animation(
                .easeOut(duration: 0.45).delay(delay),
                value: appear
            )
    }
}

// ======================================================
// MARK: - HELP CARD (UNCHANGED)
// ======================================================
struct HelpCard: View {
    let title: String
    let icon: String
    let points: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.white)

                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 6) {
                ForEach(points, id: \.self) { point in
                    Text("• \(point)")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 190, alignment: .topLeading)
        .background(Color.white.opacity(0.14))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 5)
    }
}

