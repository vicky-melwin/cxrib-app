import SwiftUI

struct OTPVerificationView: View {
    var navigate: (ContentView.Screen) -> Void

    @State private var email = ""
    @State private var otpFields = Array(repeating: "", count: 6)
    @FocusState private var focusedField: Int?
    @State private var showEmailError = false
    @State private var otpSent = false

    var body: some View {
        ZStack {
            // 🌌 Background Gradient (Midnight Aurora)
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

            VStack(spacing: 35) {
                // MARK: - Back Button
                HStack {
                    Button(action: {
                        navigate(.loginSignup)
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
                Text("OTP Verification")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 10)

                // MARK: - Email Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Enter your Email ID")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))

                    TextField("Email", text: $email)
                        .font(.system(size: 16))
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .onChange(of: email) { _, _ in
                            showEmailError = false
                        }

                    if showEmailError {
                        Text("Please enter a valid email address.")
                            .foregroundColor(.red.opacity(0.9))
                            .font(.caption)
                    }

                    // MARK: - Send OTP Button
                    Button(action: {
                        if isEmailValid() {
                            otpSent = true
                            showEmailError = false
                            // You can later add actual API call to send OTP here
                        } else {
                            showEmailError = true
                        }
                    }) {
                        Text(otpSent ? "OTP Sent ✅" : "Send OTP")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
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
                            .cornerRadius(10)
                            .shadow(color: Color.blue.opacity(0.3), radius: 6, x: 0, y: 4)
                            .padding(.top, 5)
                    }
                    .disabled(email.isEmpty)
                    .opacity(email.isEmpty ? 0.6 : 1.0)
                }
                .padding(20)
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
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 5)
                .padding(.horizontal, 25)

                // MARK: - OTP Fields
                VStack(alignment: .leading, spacing: 20) {
                    Text("Enter OTP sent to your email")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))

                    HStack(spacing: 12) {
                        ForEach(0..<6, id: \.self) { index in
                            TextField("", text: $otpFields[index])
                                .frame(width: 45, height: 55)
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .keyboardType(.numberPad)
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(10)
                                .focused($focusedField, equals: index)
                                .onChange(of: otpFields[index]) { _, newValue in
                                    if newValue.count > 1 {
                                        otpFields[index] = String(newValue.last!)
                                    }
                                    if !newValue.isEmpty {
                                        if index < 5 {
                                            focusedField = index + 1
                                        } else {
                                            focusedField = nil
                                        }
                                    }
                                }
                        }
                    }
                }
                .padding(20)
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
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 5)
                .padding(.horizontal, 25)

                // MARK: - Verify OTP Button
                Button(action: {
                    if isEmailValid() && isOTPComplete() {
                        navigate(.homeDashboard)
                    } else {
                        showEmailError = true
                    }
                }) {
                    Text("Verify OTP")
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
                }
                .disabled(!(isOTPComplete() && isEmailValid()))
                .opacity(isOTPComplete() && isEmailValid() ? 1.0 : 0.6)

                Spacer()
            }
        }
        .onAppear {
            focusedField = 0
        }
        .navigationBarHidden(true)
    }

    // MARK: - Helper Functions
    private func isOTPComplete() -> Bool {
        otpFields.joined().count == 6
    }

    private func isEmailValid() -> Bool {
        let emailRegEx = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }
}

// ✅ Preview
struct OTPVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        OTPVerificationView(navigate: { _ in })
            .preferredColorScheme(.dark)
            .previewDisplayName("Aurora OTP Verification")
    }
}

