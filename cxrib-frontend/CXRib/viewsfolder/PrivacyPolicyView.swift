import SwiftUI

struct PrivacyPolicyView: View {

    var goBack: () -> Void

    var body: some View {
        ZStack(alignment: .top) {

            // 🔹 BACKGROUND
            background
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // 🔹 HEADER
                header

                // 🔹 CONTENT
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        Text("Effective Date: \(formattedDate)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.bottom, 10)

                        section(
                            title: "1. Introduction",
                            content: "Welcome to CXRib. We are committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, and safeguard your data when you use our mobile application."
                        )

                        section(
                            title: "2. Information We Collect",
                            content: """
                            We collect only the information necessary to provide our services:
                            • **Personal Information**: Name, email address, age, and gender for account management.
                            • **Medical Data**: X-ray images uploaded for analysis and diagnostic reports.
                            • **Usage Data**: Logs related to app performance and crash reports to improve stability.
                            """
                        )

                        section(
                            title: "3. How We Use Your Data",
                            content: """
                            Your data is used strictly for the following purposes:
                            • To provide AI-based analysis of Cervical Rib conditions.
                            • To manage user accounts and secure login sessions via OTP.
                            • To maintain a history of your uploaded scans for your reference.
                            • We **do not** sell, rent, or trade your personal data to third parties.
                            """
                        )

                        section(
                            title: "4. Data Security",
                            content: "We implement industry-standard security measures to protect your data. All transmission of sensitive information is encrypted, and access to medical records is restricted to authorized users only."
                        )
                        
                        section(
                            title: "5. User Rights",
                            content: "You have the right to access, update, or delete your personal information at any time. You can delete your account permanently from the Profile section of the app, which will remove all your data from our servers."
                        )

                        section(
                            title: "6. Changes to This Policy",
                            content: "We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page."
                        )
                        
                        // Bottom Padding
                        Spacer().frame(height: 40)
                    }
                    .padding(24)
                }
            }
        }
    }

    // =====================================================
    // MARK: - HEADER
    // =====================================================
    private var header: some View {
        HStack {
            Button(action: goBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Circle())
            }

            Spacer()

            Text("Privacy Policy")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)

            Spacer()

            // Balance
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10) // Adjust for safe area if needed, but ZStack handles ignoresSafeArea usually
        .padding(.bottom, 12)
        .background(
            Color.black.opacity(0.2)
                .ignoresSafeArea(edges: .top)
        )
    }

    // =====================================================
    // MARK: - COMPONENTS
    // =====================================================
    private func section(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(.init(content)) // .init allows markdown parsing for bolding
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }

    // =====================================================
    // MARK: - BACKGROUND
    // =====================================================
    private var background: some View {
        LinearGradient(
            colors: [
                Color(.displayP3, red: 0.16, green: 0.18, blue: 0.50),
                Color(.displayP3, red: 0.32, green: 0.24, blue: 0.55),
                Color(.displayP3, red: 0.70, green: 0.42, blue: 0.60)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
