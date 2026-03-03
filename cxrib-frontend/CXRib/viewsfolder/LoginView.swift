import SwiftUI
import CoreData
import Foundation

@available(iOS 16.0, *)
struct LoginView: View {

    var navigate: (ContentView.Screen) -> Void

    // MARK: - STATES
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showMessage = false
    @State private var message = ""
    @State private var showPassword = false

    private let titleColor = Color.white
    private let textColor  = Color.white.opacity(0.85)

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
                Color(.displayP3, red: 0.16, green: 0.18, blue: 0.50),
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
            titleSection
            formFields
            helperSection
            actionButtons
            toggleButton
        }
        .padding(26)
        .background(.ultraThinMaterial)
        .overlay(glassBorder)
        .cornerRadius(26)
        .shadow(color: .black.opacity(0.35), radius: 24, x: 0, y: 12)
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
            Text("Welcome Back")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(titleColor)

            Text("Login to continue")
                .font(.subheadline)
                .foregroundColor(textColor)
        }
    }

    private var formFields: some View {
        VStack(spacing: 14) {
            input("envelope.fill", "Email", $email)
            passwordField
        }
    }

    private var helperSection: some View {
        Group {
            if showMessage {
                Text(message)
                    .foregroundColor(.red)
                    .font(.caption)
            } else {
                EmptyView()
            }
        }
    }

    private var actionButtons: some View {
        Button(action: loginUser) {
            ZStack {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Login")
                        .fontWeight(.semibold)
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

    private var toggleButton: some View {
        Button {
            navigate(.loginSignup)
        } label: {
            Text("Don’t have an account? Sign Up")
                .foregroundColor(textColor)
        }
        .padding(.top, 8)
    }

    private var passwordField: some View {
        HStack {
            Image(systemName: "lock.fill")
                .foregroundColor(.white)

            if showPassword {
                TextField("Password", text: $password)
                    .foregroundColor(.white)
            } else {
                SecureField("Password", text: $password)
                    .foregroundColor(.white)
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

    // =====================================================
    // MARK: - LOGIN LOGIC (FIXED)
    // =====================================================
    private func loginUser() {

        // 🔹 CLEAN INPUTS (DEFINE ONCE)
        let cleanEmail = email
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        let cleanPassword = password
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanEmail.isEmpty, !cleanPassword.isEmpty else {
            showError("Email and password required")
            return
        }

        isLoading = true
        showMessage = false

        // ================= ONLINE LOGIN =================
        if NetworkMonitor.shared.isConnected {

            var req = URLRequest(url: URL(string: AppConfig.loginURL)!)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = try? JSONSerialization.data(withJSONObject: [
                "email": cleanEmail,
                "password": cleanPassword
            ])

            URLSession.shared.dataTask(with: req) { data, _, _ in
                DispatchQueue.main.async {

                    self.isLoading = false

                    let json =
                        (try? JSONSerialization.jsonObject(with: data ?? Data()))
                        as? [String: Any] ?? [:]

                    if json["status"] as? String == "success",
                       let userID = json["user_id"] as? Int {

                        let userName =
                            json["name"] as? String ?? cleanEmail

                        UserDefaults.standard.set(
                            userName,
                            forKey: "loggedInUserName"
                        )

                        saveUserLocal(
                            id: userID,
                            email: cleanEmail,
                            password: cleanPassword
                        )

                        SessionManager.shared.userID = userID
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        UserDefaults.standard.set(userID, forKey: "loggedInUserID")
                        UserDefaults.standard.set(cleanEmail, forKey: "loggedInEmail")
                        UserDefaults.standard.synchronize()

                        self.navigate(.homeDashboard)
                    } else {
                        self.showError(
                            json["message"] as? String
                            ?? "Invalid email or password"
                        )
                    }
                }
            }.resume()

            return
        }

        // ================= OFFLINE LOGIN =================
        let req: NSFetchRequest<LocalUser> = LocalUser.fetchRequest()
        req.predicate = NSPredicate(
            format: "email ==[c] %@ AND passwordHash == %@",
            cleanEmail,
            cleanPassword
        )
        req.fetchLimit = 1

        if let user = try? CoreDataManager.shared.context.fetch(req).first {

            UserDefaults.standard.set(
                user.email ?? "User",
                forKey: "loggedInUserName"
            )

            SessionManager.shared.userID = Int(user.id)
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            UserDefaults.standard.set(Int(user.id), forKey: "loggedInUserID")
            UserDefaults.standard.set(cleanEmail, forKey: "loggedInEmail")

            UserDefaults.standard.synchronize()

            isLoading = false
            navigate(.homeDashboard)

        } else {
            showError("Invalid email or password")
        }
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
}

// =====================================================
// MARK: - SAVE USER LOCALLY (REQUIRED)
// =====================================================
func saveUserLocal(
    id: Int,
    email: String,
    password: String
) {
    DispatchQueue.main.async {

        let context = CoreDataManager.shared.context

        let req: NSFetchRequest<LocalUser> = LocalUser.fetchRequest()
        req.predicate = NSPredicate(format: "id == %d", id)
        req.fetchLimit = 1

        if let existing = try? context.fetch(req).first {
            existing.email = email
            existing.passwordHash = password
            existing.isSynced = true
        } else {
            let user = LocalUser(context: context)
            user.id = Int64(id)
            user.email = email
            user.passwordHash = password
            user.isSynced = true
            user.createdAt = Date()
        }

        CoreDataManager.shared.save()
        print("💾 User saved locally for offline login:", email)
    }
}

