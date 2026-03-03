import SwiftUI

struct ReportDetailsView: View {
    var navigate: (ContentView.Screen) -> Void

    var body: some View {
        ZStack {
            // 🌌 Aurora Background
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

            VStack(spacing: 25) {

                // MARK: - Back Button (No Border)
                HStack {
                    Button(action: {
                        navigate(.reportSummary) // ✅ Goes back to summary
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                            Text("Back")
                                .font(.body)
                        }
                        .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 15)

                // MARK: - Title
                Text("Detailed Report")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)

                // MARK: - Report Content (Glass Style)
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        // Patient Info
                        Group {
                            Text("👤 Patient Information")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)

                            Text("**Name:** John Doe\n**Date:** October 9, 2025")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.bottom, 10)
                        }

                        Divider().background(Color.white.opacity(0.3))

                        // Detailed Findings
                        Group {
                            Text("🩻 Detailed Findings")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)

                            Text("An **extra cervical rib** is present on the **left side**. The structure appears well-formed and distinct from normal rib anatomy. No abnormal bone density or fractures observed.")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(6)
                        }

                        Divider().background(Color.white.opacity(0.3))

                        // Recommendations
                        Group {
                            Text("💡 Recommendations")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)

                            Text("• Clinical correlation is advised.\n• Further imaging may be performed if symptoms persist.\n• Routine follow-up and physiotherapy can be considered for mild discomfort.")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(6)
                        }
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
                }

                Spacer()

                // MARK: - Bottom “Back” Button
                Button(action: {
                    navigate(.reportSummary) // ✅ Return to summary
                }) {
                    Text("Back to Summary")
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
                        .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 0, y: 5)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 30)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarHidden(true)
    }
}

struct ReportDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ReportDetailsView(navigate: { _ in })
            .preferredColorScheme(.dark)
            .previewDisplayName("Aurora Report Details Screen")
    }
}
