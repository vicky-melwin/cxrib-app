import SwiftUI

struct DetectionExplanationView: View {

    let side: String
    let confidence: Double
    let goBack: () -> Void

    var body: some View {
        ZStack {

            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.12, blue: 0.40),
                    Color(red: 0.36, green: 0.22, blue: 0.55),
                    Color(red: 0.70, green: 0.40, blue: 0.60)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {

                // Title
                Text("Detection Explanation")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 60)

                // Side + Confidence
                VStack(spacing: 8) {
                    Text("Detected Side: \(side.capitalized)")
                        .font(.headline)
                        .foregroundColor(.yellow)

                    Text(
                        "Confidence: \(String(format: "%.1f%%", confidence * 100))"
                    )
                    .foregroundColor(.white.opacity(0.9))
                }

                // ✅ SCROLLABLE CONTENT
                ScrollView(showsIndicators: false) {

                    VStack(alignment: .leading, spacing: 14) {

                        sectionTitle("What this means")
                        sectionText(
                            "The result indicates a high likelihood of a cervical rib on the \(side.lowercased()) side. A cervical rib is an extra rib arising from the neck region and is not part of normal anatomy."
                        )

                        divider

                        sectionTitle("Possible effects")
                        sectionText(
                            "Many individuals have no symptoms. If symptoms occur, they may include neck or shoulder pain, arm tingling, numbness, or weakness."
                        )

                        divider

                        sectionTitle("What to do next")
                        sectionText(
                            "Consult an orthopaedic doctor or neurologist for confirmation. Additional imaging is advised only if symptoms are present."
                        )

                        divider

                        sectionTitle("How to stay normal")
                        sectionText(
                            "Maintain good posture, perform regular neck and shoulder exercises, and avoid prolonged strain or heavy overhead activities."
                        )

                        Text("Treatment is required only if symptoms persist or worsen.")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(.ultraThinMaterial)
                    )
                    // ✅ SPACE OUTSIDE BORDER (like Patient Details)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }

                // Back Button
                Button(action: goBack) {
                    Text("Back to Dashboard")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Helpers
    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .foregroundColor(.white)
    }

    private func sectionText(_ text: String) -> some View {
        Text(text)
            .foregroundColor(.white.opacity(0.9))
    }

    private var divider: some View {
        Divider().background(Color.white.opacity(0.3))
    }
}
