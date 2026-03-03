import SwiftUI

struct SubscriptionView: View {
    @Binding var currentScreen: ContentView.Screen

    var body: some View {
        ScrollView {
            
            HStack {
                Spacer()
                Button(action: {
                    currentScreen = .homeDashboard
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            VStack(spacing: 28) {

                // Logo
                ZStack {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color.white)
                        .frame(width: 120, height: 120)
                        .shadow(radius: 20)

                    Image("AppLogo") // Add image to Assets
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                }
                .padding(.top, 60)

                // Title
                Text("CXRib Premium")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)

                Text("PREMIUM")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .foregroundColor(.yellow)

                Text("Access advanced cervical screening insights and AI-powered reports")
                    .font(.body)
                    .foregroundColor(Color.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                // Features
                featureRow(icon: "stethoscope", title: "AI Diagnostic Reports", subtitle: "Accurate cervical scan analysis")
                featureRow(icon: "chart.bar.xaxis", title: "Advanced Analytics", subtitle: "Detailed insights & trends")

                // Price
                VStack(spacing: 8) {
                    Text("₹10")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)

                    Text("/ Month")
                        .foregroundColor(.white.opacity(0.8))

                    Text("Cancel anytime")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.purple)
                .cornerRadius(24)

                // Subscribe Button
                Button(action: {
                    print("Subscribe tapped")
                }) {
                    Text("Activate CXRib Premium")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.white)
                        .cornerRadius(30)
                }
            }
            .padding(.horizontal, 20)
        }
        .background(Color(red: 0.04, green: 0.06, blue: 0.15))
        .ignoresSafeArea()
    }
}

@ViewBuilder
func featureRow(icon: String, title: String, subtitle: String) -> some View {
    HStack(spacing: 16) {
        Image(systemName: icon)
            .font(.title2)
            .foregroundColor(.white)

        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .foregroundColor(.white)
                .fontWeight(.bold)

            Text(subtitle)
                .foregroundColor(.white.opacity(0.6))
                .font(.caption)
        }

        Spacer()

        Image(systemName: "checkmark.circle.fill")
            .foregroundColor(.green)
    }
    .padding()
    .background(Color.white.opacity(0.08))
    .cornerRadius(20)
}

