import SwiftUI

struct DetectionResultView: View {

    let image: UIImage
    let label: String
    let confidence: Double

    var navigate: (ContentView.Screen) -> Void
    @State private var pulse = false

    var body: some View {
        ZStack {
            background
            ScrollView { content }
        }
        .ignoresSafeArea()
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color(red: 0.10, green: 0.12, blue: 0.40),
                Color(red: 0.36, green: 0.22, blue: 0.55),
                Color(red: 0.78, green: 0.36, blue: 0.60)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var content: some View {
        VStack(spacing: 25) {

            Text("🧠 AI Result")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 40)

            // X-ray preview
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 300)
                .cornerRadius(12)
                .shadow(radius: 10)
                .padding(.horizontal)

            resultCard
            confidenceBar
            actionButtons

            Spacer()
        }
        .padding()
    }

    private var resultCard: some View {
        VStack(spacing: 8) {

            Text(formattedLabel)
                .font(.title2.bold())
                .foregroundColor(.white)

            Text("Confidence: \(String(format: "%.2f", confidence * 100))%")
                .foregroundColor(.white.opacity(0.9))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.12))
        .cornerRadius(16)
        .scaleEffect(pulse ? 1.03 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 1).repeatForever()) {
                pulse.toggle()
            }
        }
    }

    private var confidenceBar: some View {
        VStack(alignment: .leading) {
            Text("Confidence Level")
                .foregroundColor(.white)
                .font(.headline)

            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.2)).frame(height: 12)

                Capsule()
                    .fill(Color.green)
                    .frame(width: CGFloat(confidence) * 280, height: 12)
            }
        }
        .padding(.horizontal, 30)
    }

    private var actionButtons: some View {
        VStack(spacing: 15) {

            Button("Scan Again") {
                navigate(.uploadXray)
            }
            .resultButton(color: .blue)

            Button("Back to Dashboard") {
                navigate(.homeDashboard)
            }
            .resultButton(color: .purple)
        }
        .padding(.top, 20)
    }

    private var formattedLabel: String {
        switch label.lowercased() {
        case "left": return "Left Cervical Rib Detected"
        case "right": return "Right Cervical Rib Detected"
        case "bilateral", "bicrib": return "Bilateral Cervical Rib Detected"
        default: return "No Cervical Rib Detected"
        }
    }
}

extension View {
    func resultButton(color: Color) -> some View {
        self.frame(maxWidth: .infinity)
            .font(.headline)
            .padding()
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal, 40)
    }
}


