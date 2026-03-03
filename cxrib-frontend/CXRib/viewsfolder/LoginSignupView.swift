import SwiftUI
import CoreData

@available(iOS 16.0, *)
struct LoginSignupView: View {

    var navigate: (ContentView.Screen) -> Void

    enum SignupStep {
        case email
        case otp
        case password
    }

    @State private var signupStep: SignupStep = .email

    @State private var isLoading = false
    @State private var showMessage = false
    @State private var message = ""

    @State private var name = ""
    @State private var email = ""
    @State private var gender = ""
    @State private var contact = ""
    @State private var location = ""
    @State private var age = ""
    @State private var otp = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @State private var showPassword = false
    @State private var showConfirmPassword = false
    
    @State private var showNameWarning = false
    
    @State private var canResendOTP = false
    @State private var resendCountdown = 30
    @State private var resendTimer: Timer?

    @State private var otpDigits: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedOTPIndex: Int?

    private var isSignupFormValid: Bool {

        let validName =
            !name.trimmingCharacters(in: .whitespaces).isEmpty &&
            isValidName(name)

        let validEmail = isValidGmail(email)

        let validContact =
            contact.count == 10 &&
            contact.allSatisfy(\.isNumber)

        let validGender = !gender.isEmpty

        let validLocation =
            !location.trimmingCharacters(in: .whitespaces).isEmpty

        let validAge =
            Int(age) != nil &&
            (Int(age) ?? 0) > 0 &&
            (Int(age) ?? 0) <= 125

        return validName &&
               validEmail &&
               validContact &&
               validGender &&
               validLocation &&
               validAge
    }
    
    private let titleColor = Color.white
    private let textColor  = Color.white.opacity(0.85)

    // =====================================================
    // MARK: - BODY
    // =====================================================
    var body: some View {
        ZStack {
            background
            VStack {
                Spacer()
                card
                Spacer()
            }
            .padding()
        }
        .navigationBarHidden(true)
    }

    // =====================================================
    // MARK: - UI
    // =====================================================
    private var background: some View {
        LinearGradient(
            colors: [
                Color(.displayP3, red: 0.16, green: 0.18, blue: 0.50, opacity: 1),
                Color(.displayP3, red: 0.32, green: 0.24, blue: 0.55),
                Color(.displayP3, red: 0.70, green: 0.42, blue: 0.60)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var card: some View {
        VStack(spacing: 22) {
            
            // ✅ BACK BUTTON (For Password AND OTP Steps)
            if signupStep == .password || signupStep == .otp {
                HStack {
                    Button {
                        if signupStep == .password {
                            signupStep = .email // Reset to start
                        } else {
                            signupStep = .email // Go back to email
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.footnote)
                        .foregroundColor(textColor)
                    }
                    Spacer()
                }
                .padding(.bottom, -10) // Pull closer to title
            }

            titleSection
            formFields
            helperSection
            actionButtons
            toggleButton
        }
        .padding(26)
        .background(.ultraThinMaterial)   // ✅ REAL glass blur
        .overlay(glassBorder)             // ✅ Glass border
        .cornerRadius(26)
        .shadow(
            color: .black.opacity(0.35),
            radius: 24,
            x: 0,
            y: 12
        )
    }
    
    private var glassBorder: some View {
        RoundedRectangle(cornerRadius: 26)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.35),
                        Color.white.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1.2
            )
    }

    private var titleSection: some View {
        VStack(spacing: 6) {
            Text("Create Secure Account")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(titleColor)

            Text("Signup with OTP verification")
                .font(.subheadline)
                .foregroundColor(textColor)
        }
    }

    private var formFields: some View {
        VStack(spacing: 14) {

            // =========================
            // EMAIL STEP
            // =========================
            if signupStep == .email {

                // Full Name
                input("person.fill", "Full Name", $name)
                    .onChange(of: name) { newValue in
                        let filtered = filterName(newValue)
                        showNameWarning = filtered != newValue
                        name = filtered
                    }

                if showNameWarning {
                    Text("Name should contain letters only")
                        .font(.caption2)
                        .foregroundColor(.red.opacity(0.9))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Email
                input("envelope.fill", "Email", $email)
                    .onChange(of: email) { email = $0.lowercased() }

                // Contact
                input("phone.fill", "Contact Number", $contact)
                    .onChange(of: contact) { newValue in
                        var filtered = newValue.filter { $0.isNumber }
                        
                        // Enforce start with 6,7,8,9
                        while !filtered.isEmpty, let first = filtered.first, !["6", "7", "8", "9"].contains(first) {
                            filtered.removeFirst()
                        }
                        
                        contact = String(filtered.prefix(10))
                    }
                
                // Age (max 125)
                input("calendar", "Age", $age)
                    .keyboardType(.numberPad)
                    .onChange(of: age) { newValue in
                        let filtered = newValue.filter { $0.isNumber }

                        if let value = Int(filtered) {
                            if value <= 125 {
                                age = String(value)
                            } else {
                                age = "125"
                            }
                        } else {
                            age = ""
                        }
                    }

                // Gender
                Menu {
                    Button("Male") { gender = "Male" }
                    Button("Female") { gender = "Female" }
                    Button("Other") { gender = "Other" }
                    Button("Prefer not to say") { gender = "Prefer not to say" }
                } label: {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)

                        Text(gender.isEmpty ? "Select Gender" : gender)
                            .foregroundColor(gender.isEmpty ? .white.opacity(0.6) : .white)

                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(14)
                }

                // Location
                input("map.fill", "Location", $location)
                    .onChange(of: location) {
                        location = String($0.prefix(15))
                    }

                // Gmail warning
                if !email.isEmpty && !isValidGmail(email) {
                    Text("Only Google (Gmail) accounts are allowed")
                        .font(.caption2)
                        .foregroundColor(.red.opacity(0.9))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            
            // =========================
            // OTP STEP (6 BOXES)
            // =========================
            if signupStep == .otp {

                VStack(spacing: 12) {

                    HStack(spacing: 10) {
                        ForEach(0..<6, id: \.self) { index in
                            otpBox(index: index)
                        }
                    }

                    // 🔁 RESEND OTP
                    if !canResendOTP {
                        Text("Resend OTP in \(resendCountdown)s")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    } else {
                        Button("Resend OTP") {
                            resendOTP()
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
                .onAppear {
                    focusedOTPIndex = 0
                    startResendTimer()
                }
                .onDisappear {
                    resendTimer?.invalidate()   // ✅ FIX MEMORY LEAK
                }
            }

            // =========================
            // PASSWORD STEP
            // =========================
            if signupStep == .password {

                passwordField

                let strength = passwordStrength(password)

                VStack(alignment: .leading, spacing: 6) {

                    HStack(spacing: 6) {
                        ForEach(0..<5, id: \.self) { index in
                            Rectangle()
                                .frame(height: 5)
                                .foregroundColor(
                                    index < strength
                                    ? strengthColor(strength)
                                    : Color.white.opacity(0.2)
                                )
                                .cornerRadius(3)
                        }
                    }

                    Text("Password strength: \(strengthText(strength))")
                        .font(.caption2)
                        .foregroundColor(strengthColor(strength))
                }

                confirmPasswordField

                VStack(alignment: .leading, spacing: 4) {
                    ruleRow("8–10 characters", password.count >= 8 && password.count <= 10)
                    ruleRow("One uppercase letter", password.range(of: "[A-Z]", options: .regularExpression) != nil)
                    ruleRow("One lowercase letter", password.range(of: "[a-z]", options: .regularExpression) != nil)
                    ruleRow("One number", password.range(of: "[0-9]", options: .regularExpression) != nil)
                    ruleRow("One special character", password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil)
                }
                .font(.caption2)
            }
        }
    }
    
    private var dobRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let today = Date()

        let minDOB = calendar.date(
            byAdding: .year,
            value: -124,
            to: today
        )!

        return minDOB...today
    }
    
    private func resendOTP() {
        canResendOTP = false
        showMessage = false

        // ✅ CLEAR OTP INPUT
        otpDigits = Array(repeating: "", count: 6)
        otp = ""
        focusedOTPIndex = 0

        startResendTimer()

        postSilently("\(AppConfig.apiBase)/send_otp.php", ["email": email]) { success in
            if success {
                message = "OTP resent successfully"
                showMessage = true
            } else {
                showError("Failed to resend OTP")
            }
        }
    }

    private func otpBox(index: Int) -> some View {
        TextField("", text: $otpDigits[index])
            .keyboardType(.numberPad)
            .focused($focusedOTPIndex, equals: index)
            .multilineTextAlignment(.center)
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: 45, height: 50)
            .background(Color.white.opacity(0.15))
            .cornerRadius(10)
            .onChange(of: otpDigits[index]) { newValue in

                // Allow only numbers & single digit
                let filtered = newValue.filter { $0.isNumber }
                otpDigits[index] = String(filtered.prefix(1))

                // Move forward
                if !filtered.isEmpty {
                    if index < 5 {
                        focusedOTPIndex = index + 1
                    } else {
                        focusedOTPIndex = nil
                    }
                }

                // Move backward on delete
                if newValue.isEmpty && index > 0 {
                    focusedOTPIndex = index - 1
                }

                // Combine OTP
                otp = otpDigits.joined()
            }
    }
    
    private func ruleRow(_ text: String, _ isValid: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isValid ? .green : .red)

            Text(text)
                .foregroundColor(.white.opacity(0.85))
        }
    }

    // =====================================================
    // MARK: - OTP INPUT FILTER
    // =====================================================

    private func filterOTP(_ value: String) -> String {
        let filtered = value.filter { $0.isNumber }
        return String(filtered.prefix(6)) // limit to 6 digits
    }

    private var helperSection: some View {
        Group {
            if showMessage {
                Text(message)
                    .foregroundColor(
                        message.lowercased().contains("success")
                        ? .green : .red
                    )
                    .font(.caption)
            }
        }
    }

    // =====================================================
    // MARK: - ACTION BUTTONS ✅ FIXED
    // =====================================================
    private var actionButtons: some View {
        VStack(spacing: 12) {

            if signupStep == .email {
                mainButton("Continue", systemImage: "arrow.right", sendOTP)
                    .disabled(!isSignupFormValid || isLoading)
                    .opacity(isSignupFormValid ? 1 : 0.6)
            }

            if signupStep == .otp {
                mainButton("Verify & Proceed", systemImage: "checkmark.circle.fill", verifyOTP)
                    .disabled(isLoading || otp.count != 6)
                    .opacity(isLoading || otp.count != 6 ? 0.6 : 1)
            }

            if signupStep == .password {
                mainButton("Create Account", systemImage: "person.badge.plus", createAccount)
                    .disabled(
                        passwordStrength(password) < 5 ||
                        password != confirmPassword ||
                        isLoading
                    )
                    .opacity(
                        passwordStrength(password) < 5 ||
                        password != confirmPassword ? 0.6 : 1
                    )
            }
        }
    }
    
    private func verifyOTP() {
        guard otp.count == 6 else {
            showError("Enter valid OTP")
            return
        }

        isLoading = true
        showMessage = false

        post(
            "\(AppConfig.apiBase)/verify_otp.php",
            ["email": email, "otp": otp]
        ) { _ in
            self.isLoading = false
            self.otp = ""
            self.signupStep = .password
            self.message = "OTP verified"
            self.showMessage = true
        }
    }

    // =====================================================
    // MARK: - NAME INPUT FILTER
    // =====================================================

    private func filterName(_ value: String) -> String {
        let allowedCharacters = CharacterSet.letters.union(.whitespaces)
        return value
            .unicodeScalars
            .filter { allowedCharacters.contains($0) }
            .map(String.init)
            .joined()
    }

    // Limit password length to max 10 characters
    private func limitPassword(_ value: String) -> String {
        String(value.prefix(10))
    }

    private var gmailInputField: some View {
        HStack(spacing: 10) {

            Image("google") // 🟢 Google logo asset
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)

            TextField("Email", text: $email)
                .foregroundColor(.white)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .onChange(of: email) { email = $0.lowercased() }
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(14)
    }

    private var toggleButton: some View {
        Button {

            // ✅ CLEAR AUTO-LOGIN STATE
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
            UserDefaults.standard.removeObject(forKey: "loggedInUserID")
            SessionManager.shared.clear()

            // ✅ GO TO LOGIN VIEW
            navigate(.login)

        } label: {
            Text("Already have an account? Login")
                .foregroundColor(textColor)
        }
        .padding(.top, 8)
    }

    // =====================================================
    // MARK: - MAIN BUTTON ✅ MUST BE INSIDE STRUCT
    // =====================================================
    private func mainButton(
        _ title: String,
        systemImage: String? = nil,
        _ action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    HStack {
                        Text(title)
                            .fontWeight(.semibold)
                        
                        if let icon = systemImage {
                            Image(systemName: icon)
                                .fontWeight(.bold)
                        }
                    }
                    .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.85, green: 0.40, blue: 0.60),
                        Color(red: 0.45, green: 0.30, blue: 0.60)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
        .disabled(isLoading)
    }

    // =====================================================
    // MARK: - PASSWORD FIELDS (EYE ICON)
    // =====================================================
    private var passwordField: some View {
        HStack {
            Image(systemName: "lock.fill").foregroundColor(.white)

            if showPassword {
                TextField("Password", text: $password)
                    .foregroundColor(.white)
                    .onChange(of: password) { password = limitPassword($0) }
            } else {
                SecureField("Password", text: $password)
                    .foregroundColor(.white)
                    .onChange(of: password) { password = limitPassword($0) }
            }

            Button {
                showPassword.toggle()
            } label: {
                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(14)
    }

    private var confirmPasswordField: some View {
        HStack {
            Image(systemName: "lock.fill").foregroundColor(.white)

            if showConfirmPassword {
                TextField("Confirm Password", text: $confirmPassword)
                    .foregroundColor(.white)
                    .onChange(of: confirmPassword) { confirmPassword = limitPassword($0) }
            } else {
                SecureField("Confirm Password", text: $confirmPassword)
                    .foregroundColor(.white)
                    .onChange(of: confirmPassword) { confirmPassword = limitPassword($0) }
            }

            Button {
                showConfirmPassword.toggle()
            } label: {
                Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(14)
    }
    
    private func startResendTimer() {
        resendTimer?.invalidate()

        canResendOTP = false
        resendCountdown = 60

        resendTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            resendCountdown -= 1

            if resendCountdown <= 0 {
                canResendOTP = true
                timer.invalidate()
            }
        }
    }

    // =====================================================
    // MARK: - VALIDATION HELPERS
    // =====================================================

    // Name: letters + spaces only
    private func isValidName(_ name: String) -> Bool {
        let regex = "^[A-Za-z ]+$"
        return NSPredicate(format: "SELF MATCHES %@", regex)
            .evaluate(with: name.trimmingCharacters(in: .whitespaces))
    }

    // Email: proper email format
    private func isValidEmail(_ email: String) -> Bool {
        let regex =
        #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex)
            .evaluate(with: email)
    }
    
    // =====================================================
    // MARK: - PASSWORD STRENGTH
    // =====================================================

    private func passwordStrength(_ password: String) -> Int {
        var strength = 0

        if password.count >= 8 {
            strength += 1
        }

        if password.range(of: "[A-Z]", options: .regularExpression) != nil {
            strength += 1
        }

        if password.range(of: "[a-z]", options: .regularExpression) != nil {
            strength += 1
        }

        if password.range(of: "[0-9]", options: .regularExpression) != nil {
            strength += 1
        }

        if password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil {
            strength += 1
        }

        return strength // 0 to 5
    }

    private func strengthText(_ value: Int) -> String {
        switch value {
        case 0, 1: return "Weak"
        case 2: return "Fair"
        case 3: return "Good"
        case 4: return "Very Good"
        case 5: return "Strong"
        default: return ""
        }
    }

    private func strengthColor(_ value: Int) -> Color {
        switch value {
        case 0, 1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return .blue
        case 5: return .green
        default: return .clear
        }
    }

    // =====================================================
    // MARK: - ACTIONS (UNCHANGED)
    // =====================================================
    private func sendOTP() {

        // 🔴 Name validation
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            showError("Name is required")
            return
        }

        guard isValidName(name) else {
            showError("Name must contain letters only")
            return
        }

        // 🔴 Email validation (Gmail only)
        guard !email.isEmpty else {
            showError("Email is required")
            return
        }

        guard isValidGmail(email) else {
            showError("Only Google (Gmail) accounts are allowed")
            return
        }

        // ✅ Passed all validations
        isLoading = true
        showMessage = false

        postSilently("\(AppConfig.apiBase)/send_otp.php", ["email": email]) { success in
            self.isLoading = false

            if success {
                self.signupStep = .otp
                self.otp = ""
                self.otpDigits = Array(repeating: "", count: 6) // ✅ CLEAR OTP UI
                self.message = "OTP sent successfully"
                self.showMessage = true
            } else {
                self.showError("Failed to send OTP")
            }
        }
    }
    
    // =====================================================
    // MARK: - GMAIL VALIDATION
    // =====================================================

    // Only allow Gmail accounts
    private func isValidGmail(_ email: String) -> Bool {
        let regex =
        #"^[A-Z0-9a-z._%+-]+@gmail\.com$"#
        return NSPredicate(format: "SELF MATCHES %@", regex)
            .evaluate(with: email)
    }
    
    private func postSilently(
        _ url: String,
        _ body: [String: Any],
        completion: @escaping (Bool) -> Void
    ) {
        guard let url = URL(string: url) else {
            completion(false)
            return
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: req) { data, response, error in
            DispatchQueue.main.async {

                // ❌ Network error
                if error != nil {
                    completion(false)
                    return
                }

                // ❌ No response data
                guard let data = data, !data.isEmpty else {
                    completion(false)
                    return
                }

                // ✅ ANY response = OTP sent (email is proof)
                completion(true)
            }
        }.resume()
    }

    private func createAccount() {
        guard password == confirmPassword else {
            showError("Passwords do not match")
            return
        }

        isLoading = true

        let body: [String: Any] = [
            "name": name,
            "email": email,
            "password": password,
            "age": age,                // ✅ ADD THIS
            "gender": gender,
            "phone": contact,
            "address": location
        ]

        post(
            AppConfig.signupURL,
            body
        ) { _ in
            // Save these locally so ProfileView can reflect them
            UserDefaults.standard.set(self.age, forKey: "profileAge")  
            UserDefaults.standard.set(self.contact, forKey: "profilePhone")
            UserDefaults.standard.set(self.location, forKey: "profileAddress")
            UserDefaults.standard.set(self.gender, forKey: "profileGender")

            navigate(.login)   // ✅ GO TO LOGIN PAGE
        }
    }
// =====================================================
    // MARK: - NETWORK / INPUT HELPERS
    // =====================================================
    private func post(
        _ url: String,
        _ body: [String: Any],
        success: @escaping ([String: Any]) -> Void
    ) {
        guard let url = URL(string: url) else { return }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: req) { data, _, _ in
            DispatchQueue.main.async {
                self.isLoading = false
                let json =
                    (try? JSONSerialization.jsonObject(with: data ?? Data()))
                    as? [String: Any] ?? [:]

                if json["status"] as? String == "success" {
                    success(json)
                } else {
                    showError(json["message"] as? String ?? "Action failed")
                }
            }
        }.resume()
    }

    private func input(
        _ icon: String,
        _ placeholder: String,
        _ text: Binding<String>
    ) -> some View {
        HStack {
            Image(systemName: icon).foregroundColor(.white)
            TextField(placeholder, text: text)
                .foregroundColor(.white)
                .autocapitalization(.none)
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(14)
    }

    private func showError(_ msg: String) {
        message = msg
        showMessage = true
        isLoading = false
    }

    private func showSuccess(_ msg: String) {
        message = msg
        showMessage = true
        isLoading = false
    }
}

