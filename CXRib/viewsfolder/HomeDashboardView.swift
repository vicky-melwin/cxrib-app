import SwiftUI

// =====================================================
// MARK: - HOME DASHBOARD VIEW
// =====================================================
struct HomeDashboardView: View {
    var navigate: (ContentView.Screen) -> Void
    @State private var showLogoutAlert = false
    @State private var showCards = false
    @State private var userName: String = ""

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

            VStack(spacing: 25) {

                // MARK: - TITLE (Name at top)
                VStack(spacing: 6) {

                    if !userName.isEmpty {
                        Text(userName)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }

                    Text("Welcome to CXRib Dashboard")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 8)
                }
                .padding(.top, 44)
                .padding(.horizontal, 30)
                .opacity(showCards ? 1 : 0)
                .offset(y: showCards ? 0 : -20)
                .animation(.easeOut(duration: 0.6), value: showCards)

                // MARK: - DASHBOARD BUTTONS
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {

                        AnimatedDashboardButton(
                            index: 0,
                            show: showCards,
                            title: "Upload X-Ray Image",
                            subtitle: "Analyze and detect cervical ribs using AI.",
                            systemImage: "photo.on.rectangle.angled",
                            gradient: [
                                Color(red: 0.30, green: 0.60, blue: 0.90),
                                Color(red: 0.20, green: 0.35, blue: 0.70)
                            ]
                        ) { navigate(.patientDetails) }

                        AnimatedDashboardButton(
                            index: 1,
                            show: showCards,
                            title: "View Report History",
                            subtitle: "Access and manage your previous reports.",
                            systemImage: "folder.fill",
                            gradient: [
                                Color(red: 0.64, green: 0.34, blue: 0.75),
                                Color(red: 0.36, green: 0.22, blue: 0.55)
                            ]
                        ) { navigate(.history) }
                        
                        AnimatedDashboardButton(
                            index: 2,
                            show: showCards,
                            title: "Profile",
                            subtitle: "View and edit your profile",
                            systemImage: "person.crop.circle",
                            gradient: [
                                Color.blue,
                                Color.purple
                            ]
                        ) {
                            navigate(.profile)
                        }

                        AnimatedDashboardButton(
                            index: 3,
                            show: showCards,
                            title: "About Cervical Rib",
                            subtitle: "Learn what cervical ribs are and how they affect the body.",
                            systemImage: "info.circle.fill",
                            gradient: [
                                Color(red: 0.90, green: 0.55, blue: 0.40),
                                Color(red: 0.70, green: 0.25, blue: 0.30)
                            ]
                        ) { navigate(.aboutCervicalRib) }

                        AnimatedDashboardButton(
                            index: 4,
                            show: showCards,
                            title: "Help & Usage",
                            subtitle: "Get tips on how to use the app and AI assistant effectively.",
                            systemImage: "questionmark.circle.fill",
                            gradient: [
                                Color(red: 0.45, green: 0.65, blue: 0.95),
                                Color(red: 0.25, green: 0.45, blue: 0.80)
                            ]
                        ) { navigate(.helpUsage) }
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }

                Spacer()

                // MARK: - LOGOUT BUTTON
                Button {
                    showLogoutAlert = true
                } label: {
                    Text("Logout")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.90, green: 0.30, blue: 0.30),
                                    Color(red: 0.70, green: 0.10, blue: 0.10)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: Color.red.opacity(0.4), radius: 8, x: 0, y: 5)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 30)
                }
                .alert("Are you sure you want to logout?", isPresented: $showLogoutAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Yes, Logout", role: .destructive) {
                        UserDefaults.standard.set(false, forKey: "isLoggedIn")
                        UserDefaults.standard.removeObject(forKey: "loggedInUserID")
                        UserDefaults.standard.removeObject(forKey: "loggedInUserName")

                        SessionManager.shared.clear()

                        navigate(.login)
                    }
                }
            }
        }
        .onAppear {
            showCards = true
            userName = UserDefaults.standard.string(forKey: "loggedInUserName") ?? ""
        }
        .navigationBarHidden(true)
    }
}

// =====================================================
// MARK: - ANIMATED DASHBOARD BUTTON
// =====================================================
struct AnimatedDashboardButton: View {
    let index: Int
    let show: Bool
    let title: String
    let subtitle: String
    let systemImage: String
    let gradient: [Color]
    let action: () -> Void

    @GestureState private var pressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {

                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: gradient),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 55, height: 55)

                    Image(systemName: systemImage)
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)

                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                }

                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding()
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
            .cornerRadius(18)
            .shadow(
                color: Color.black.opacity(0.25),
                radius: pressed ? 3 : 8,
                y: pressed ? 1 : 6
            )
            .scaleEffect(pressed ? 0.97 : 1)
            .opacity(show ? 1 : 0)
            .offset(y: show ? 0 : 30)
            .animation(
                .easeOut(duration: 0.5)
                    .delay(Double(index) * 0.12),
                value: show
            )
        }
        .buttonStyle(.plain)
        .gesture(
            DragGesture(minimumDistance: 0)
                .updating($pressed) { _, state, _ in state = true }
        )
    }
}

