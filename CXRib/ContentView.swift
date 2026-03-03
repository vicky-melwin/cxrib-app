import SwiftUI
import UIKit

struct ContentView: View {

    // =====================================================
    // MARK: - SCREEN ENUM
    // =====================================================
    enum Screen: Equatable {

        // Auth
        case splash
        case onboarding
        case login
        case loginSignup
        case otpVerification

        // Main
        case homeDashboard
        case patientDetails
        case subscription

        case uploadXray
        case uploadXrayWithDetails(
            name: String,
            age: Int,
            gender: String,
            caseID: Int,
            patientID: Int
        )

        case aiProcessing
        case detectionResult(
            image: UIImage,
            label: String,
            confidence: Double
        )

        case history
        case aboutCervicalRib
        case helpUsage
        case reportSummary
        case reportDetails
        case detectionExplanation(
            side: String,
            confidence: Double
        )

        case profile
        case privacyPolicy
    }

    // =====================================================
    // MARK: - STATE
    // =====================================================
    @State private var currentScreen: Screen

    // =====================================================
    // MARK: - INIT
    // =====================================================
    init() {
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        let uid = UserDefaults.standard.integer(forKey: "loggedInUserID")

        if isLoggedIn && uid > 0 {
            _currentScreen = State(initialValue: .homeDashboard)
        } else {
            _currentScreen = State(initialValue: .login)
        }
    }

    // =====================================================
    // MARK: - BODY
    // =====================================================
    var body: some View {
        mainBody
            .onAppear {
                _ = NetworkMonitor.shared
            }
    }

    // =====================================================
    // MARK: - ROUTER
    // =====================================================
    @ViewBuilder
    private var mainBody: some View {

        switch currentScreen {

        case .splash:
            SplashView { currentScreen = $0 }

        case .onboarding:
            OnboardingView { _ in currentScreen = .login }

        case .login:
            LoginView { currentScreen = $0 }

        case .loginSignup:
            LoginSignupView { currentScreen = $0 }

        case .otpVerification:
            OTPVerificationView { currentScreen = $0 }

        case .subscription:
            SubscriptionView(currentScreen: $currentScreen)

        case .homeDashboard:
            HomeDashboardView { currentScreen = $0 }

        // ✅ PROFILE
        case .profile:
            ProfileView(
                navigateBack: {
                    currentScreen = .homeDashboard
                },
                navigateToLogin: {
                    currentScreen = .login
                },
                openPrivacyPolicy: {
                    currentScreen = .privacyPolicy
                }
            )
            
        // ✅ PRIVACY POLICY
        case .privacyPolicy:
            PrivacyPolicyView {
                currentScreen = .profile
            }

        case .patientDetails:
            PatientDetailsView(
                navigateToUpload: { n, a, g, cid, pid in
                    UserDefaults.standard.set(pid, forKey: "recentPatientID")
                    currentScreen = .uploadXrayWithDetails(
                        name: n,
                        age: a,
                        gender: g,
                        caseID: cid,
                        patientID: pid
                    )
                },
                goBack: { currentScreen = .homeDashboard }
            )

        case .uploadXray:
            let pid = UserDefaults.standard.integer(forKey: "recentPatientID")

            UploadXrayView(
                goToExplanation: { side, confidence in
                    currentScreen = .detectionExplanation(
                        side: side,
                        confidence: confidence
                    )
                },
                patientID: pid,
                patientName: "",
                patientAge: 0,
                patientGender: "",
                caseID: 0,
                goBack: { currentScreen = .homeDashboard },
                goToHistory: { currentScreen = .history },
                goToDashboard: { currentScreen = .homeDashboard }
            )

        case .uploadXrayWithDetails(let name, let age, let gender, let caseID, let pid):
            UploadXrayView(
                goToExplanation: { side, confidence in
                    currentScreen = .detectionExplanation(
                        side: side,
                        confidence: confidence
                    )
                },
                patientID: pid,
                patientName: name,
                patientAge: age,
                patientGender: gender,
                caseID: caseID,
                goBack: { currentScreen = .patientDetails },
                goToHistory: { currentScreen = .history },
                goToDashboard: { currentScreen = .homeDashboard }
            )

        case .history:
            HistoryView { currentScreen = .homeDashboard }

        case .aboutCervicalRib:
            AboutCervicalRibView { currentScreen = $0 }
            
        case .helpUsage:
            HelpUsageView { currentScreen = $0 }

        case .aiProcessing:
            VStack {
                Text("AI Processing…")
                ProgressView()
                Button("Cancel") {
                    currentScreen = .homeDashboard
                }
            }

        case .reportSummary:
            VStack {
                Text("Summary")
                Button("Home") {
                    currentScreen = .homeDashboard
                }
            }

        case .reportDetails:
            VStack {
                Text("Details")
                Button("Home") {
                    currentScreen = .homeDashboard
                }
            }

        case .detectionResult(let img, let label, let conf):
            DetectionResultView(
                image: img,
                label: label,
                confidence: conf
            ) { currentScreen = $0 }

        case .detectionExplanation(let side, let confidence):
            DetectionExplanationView(
                side: side,
                confidence: confidence
            ) {
                currentScreen = .homeDashboard
            }
        }
    }
}

