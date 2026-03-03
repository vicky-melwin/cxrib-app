import SwiftUI
import CoreData


@available(iOS 16.0, *)
struct PatientDetailsView: View {

    // navigateToUpload(name, age, gender, caseID, patientID)
    var navigateToUpload: (String, Int, String, Int, Int) -> Void
    var goBack: () -> Void

    // =====================================================
    // MARK: - STATE
    // =====================================================
    @State private var name = ""
    @State private var age = ""
    @State private var gender = "Select Gender"
    @State private var caseID = ""

    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    // 🔴 LIVE VALIDATION STATES
    @State private var showNameWarning = false
    @State private var showAgeWarning = false
    @State private var showCaseIDWarning = false

    @State private var appear = false
    @GestureState private var pressed = false

    // =====================================================
    // MARK: - BODY
    // =====================================================
    var body: some View {
        ZStack {
            background

            VStack {
                header
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : -20)
                    .animation(.easeOut(duration: 0.5), value: appear)

                Spacer()

                glassCard
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 30)
                    .animation(.easeOut(duration: 0.6), value: appear)

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .onAppear { appear = true }
        .alert("Warning", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
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
        .ignoresSafeArea()
    }

    // =====================================================
    // MARK: - HEADER
    // =====================================================
    private var header: some View {
        HStack {
            Button {
                goBack()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))

                    Text("Back")
                        .font(.system(size: 17))
                }
                .foregroundColor(.white)
            }

            Spacer()
        }
        .padding(.leading, 16)
        .padding(.top, 12)
    }

    // =====================================================
    // MARK: - GLASS CARD
    // =====================================================
    private var glassCard: some View {
        VStack(spacing: 22) {

            VStack(spacing: 6) {
                Text("Patient Details")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)

                Text("Enter details to continue")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }

            VStack(spacing: 16) {

                // =========================
                // NAME
                // =========================
                inputField(
                    icon: "person.fill",
                    placeholder: "Patient Name",
                    text: $name,
                    numbersOnly: false
                )
                .onChange(of: name) { newValue in
                    let filtered = newValue.filter { $0.isLetter || $0.isWhitespace }
                    showNameWarning = filtered != newValue
                    name = filtered
                }

                if showNameWarning {
                    Text("Name should contain letters only")
                        .font(.caption2)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // =========================
                // AGE
                // =========================
                inputField(
                    icon: "number.circle.fill",
                    placeholder: "Age",
                    text: $age,
                    numbersOnly: true
                )
                .onChange(of: age) { newValue in
                    let filtered = newValue.filter(\.isNumber)
                    let limited = String(filtered.prefix(3))
                    age = limited

                    if let ageInt = Int(limited) {
                        showAgeWarning = ageInt > 125
                    } else {
                        showAgeWarning = false
                    }
                }

                if showAgeWarning {
                    Text("Age must be numeric and max 3 digits")
                        .font(.caption2)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // =========================
                // GENDER
                // =========================
                genderDropdown

                // =========================
                // CASE ID
                // =========================
                inputField(
                    icon: "doc.text.fill",
                    placeholder: "Case ID",
                    text: $caseID,
                    numbersOnly: true
                )
                .onChange(of: caseID) { newValue in
                    let filtered = newValue.filter(\.isNumber)
                    showCaseIDWarning = filtered != newValue
                    caseID = filtered
                }

                if showCaseIDWarning {
                    Text("Case ID must contain numbers only")
                        .font(.caption2)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Button {
                savePatientDetails()
            } label: {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text("Continue to Scan")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.92, green: 0.45, blue: 0.65),
                        Color(red: 0.55, green: 0.35, blue: 0.75)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .scaleEffect(pressed ? 0.97 : 1)
            .shadow(color: Color.black.opacity(0.25),
                    radius: pressed ? 3 : 8,
                    y: pressed ? 1 : 6)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($pressed) { _, state, _ in
                        state = true
                    }
            )
            .disabled(
                isLoading ||
                name.isEmpty ||
                age.isEmpty ||
                caseID.isEmpty ||
                gender == "Select Gender" ||
                showNameWarning ||
                showAgeWarning ||
                showCaseIDWarning
            )
            .opacity(
                name.isEmpty ||
                age.isEmpty ||
                caseID.isEmpty ||
                gender == "Select Gender" ||
                showNameWarning ||
                showAgeWarning ||
                showCaseIDWarning
                ? 0.5 : 1
            )
        }
        .padding(26)
        .background(.ultraThinMaterial)
        .overlay(glassBorder)
        .cornerRadius(26)
        .shadow(color: .black.opacity(0.35),
                radius: 24,
                x: 0,
                y: 12)
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

    // =====================================================
    // MARK: - GENDER DROPDOWN
    // =====================================================
    private var genderDropdown: some View {
        Menu {
            Button("Male") { gender = "Male" }
            Button("Female") { gender = "Female" }
            Button("Other") { gender = "Other" }
        } label: {
            HStack {
                Text(gender)
                    .foregroundColor(
                        gender == "Select Gender"
                        ? .white.opacity(0.6)
                        : .white
                    )
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
            .background(Color.white.opacity(0.15))
            .cornerRadius(14)
        }
    }

    // =====================================================
    // MARK: - INPUT FIELD (UNCHANGED)
    // =====================================================
    private func inputField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        numbersOnly: Bool
    ) -> some View {

        HStack {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.85))
                .frame(width: 28)

            TextField(placeholder, text: text)
                .foregroundColor(.white)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(14)
    }

    // =====================================================
    // MARK: - SAVE LOGIC (UNCHANGED)
    // =====================================================
    private func savePatientDetails() {

        guard
            let ageInt = Int(age),
            let caseIDInt = Int(caseID)
        else {
            showError("Invalid age or case ID")
            return
        }

        isLoading = true

        // 1️⃣ SAVE LOCALLY (ALWAYS — OFFLINE FIRST)
        let patient = CoreDataManager.shared.savePatientLocally(
            name: name,
            age: ageInt,
            gender: gender,
            caseID: caseIDInt
        )

        // 2️⃣ IF ONLINE → SYNC TO SERVER
        if true {

            APIClient.shared.savePatient(
                userId: SessionManager.shared.userID,
                name: name,
                age: ageInt,
                gender: gender,
                caseId: caseIDInt
            ) { result in

                DispatchQueue.main.async {
                    self.isLoading = false

                    switch result {
                    case .success(let serverPatientId):
                        // ✅ Save server ID locally
                        patient.serverPatientID = Int64(serverPatientId)
                        CoreDataManager.shared.save()

                        print("✅ Patient synced:", serverPatientId)

                        self.navigateToUpload(
                            self.name,
                            ageInt,
                            self.gender,
                            caseIDInt,
                            Int(patient.id)
                        )

                    case .failure(let error):
                        print("❌ Patient sync failed:", error.localizedDescription)

                        // Offline-style continuation
                        self.navigateToUpload(
                            self.name,
                            ageInt,
                            self.gender,
                            caseIDInt,
                            Int(patient.id)
                        )
                    }
                }
            }

        } else {
            // 3️⃣ OFFLINE → CONTINUE WITHOUT SERVER
            isLoading = false

            navigateToUpload(
                name,
                ageInt,
                gender,
                caseIDInt,
                Int(patient.id)
            )
        }
    }
    // =====================================================
    // MARK: - ALERT
    // =====================================================
    private func showError(_ msg: String) {
        alertMessage = msg
        showAlert = true
        isLoading = false
    }
}

