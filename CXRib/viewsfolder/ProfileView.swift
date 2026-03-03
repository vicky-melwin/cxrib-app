import SwiftUI
import UIKit

struct ProfileView: View {

    // Navigation
    var navigateBack: () -> Void
    var navigateToLogin: () -> Void
    var openPrivacyPolicy: () -> Void

    private let headerHeight: CGFloat = 60

    // MARK: - STATE
    @State private var profileImage: UIImage?
    @State private var showImagePicker = false
    @State private var imageSource: UIImagePickerController.SourceType = .photoLibrary

    @State private var email = ""
    @State private var age = ""
    @State private var gender = "Male"
    @State private var phone = ""
    @State private var address = ""

    @State private var isEditing = false
    @State private var showDeleteSheet = false
    
    @State private var showPhotoOptions = false
    
    // Animation State
    @State private var appear = false

    var body: some View {
        ZStack {

            // 🌈 BACKGROUND
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

            // 🔒 FIXED HEADER
            VStack {
                header
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : -20)
                    .animation(.easeOut(duration: 0.5), value: appear)
                Spacer()
            }
            .zIndex(10)

            // 📜 SCROLLABLE CONTENT
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {

                    Spacer().frame(height: headerHeight + 10)

                    // Profile Image
                    profileImageSection
                    
                    // Main Info Card
                    VStack(spacing: 0) {
                        profileRow(icon: "envelope.fill", title: "Email", text: $email, isEditable: false)
                        Divider().background(Color.white.opacity(0.2))
                        
                        profileRow(icon: "calendar", title: "Age", text: $age, isEditable: isEditing, keyboardType: .numberPad)
                            .onChange(of: age) { newValue in
                                filterAge(newValue)
                            }
                        Divider().background(Color.white.opacity(0.2))
                        
                        genderRow
                        Divider().background(Color.white.opacity(0.2))
                        
                        profileRow(icon: "phone.fill", title: "Mobile", text: $phone, isEditable: isEditing, keyboardType: .numberPad)
                            .onChange(of: phone) { newValue in
                                var filtered = newValue.filter { $0.isNumber }
                                
                                // Enforce start with 6,7,8,9
                                while !filtered.isEmpty, let first = filtered.first, !["6", "7", "8", "9"].contains(first) {
                                    filtered.removeFirst()
                                }
                                
                                phone = String(filtered.prefix(10))
                            }
                        Divider().background(Color.white.opacity(0.2))
                        
                        profileRow(icon: "mappin.and.ellipse", title: "Location", text: $address, isEditable: isEditing)
                            .onChange(of: address) { newValue in
                                address = String(newValue.prefix(15))
                            }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.1))
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        Button(action: openPrivacyPolicy) {
                            HStack {
                                Image(systemName: "hand.raised.fill")
                                Text("Privacy Policy")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                        }
                        
                        Button(action: { showDeleteSheet = true }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("Delete Account")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.4))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 30)
                .animation(.easeOut(duration: 0.6), value: appear)
            }
            .zIndex(1)
        }
        .onAppear { 
            loadData()
            appear = true
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(
                sourceType: imageSource
            ) { image in
                profileImage = image
                saveProfileImage(image)
            }
        }
        .confirmationDialog(
            "Profile Photo",
            isPresented: $showPhotoOptions,
            titleVisibility: .visible
        ) {
            Button("Choose from Gallery") {
                imageSource = .photoLibrary
                showImagePicker = true
            }

            if profileImage != nil {
                Button("Remove Photo", role: .destructive) {
                    removeProfileImage()
                }
            }

            Button("Cancel", role: .cancel) {}
        }
        .overlay {
            if showDeleteSheet {
                deleteSheet
            }
        }
    }

    // MARK: - HEADER
    private var header: some View {
        ZStack {
            // Slight gradient for header legibility if scrolled
            LinearGradient(
                colors: [
                    Color.black.opacity(0.3),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            HStack {
                Button(action: { navigateBack() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text("My Profile")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    if isEditing {
                        saveProfileData()
                    }
                    withAnimation {
                        isEditing.toggle()
                    }
                }) {
                    Text(isEditing ? "Done" : "Edit")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(isEditing ? Color.green.opacity(0.8) : Color.white.opacity(0.1))
                        .cornerRadius(20)
                        
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 0) // Adjusted since we have safe area
        }
        .frame(height: headerHeight)
    }
    
    // MARK: - PROFILE IMAGE
    private var profileImageSection: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                if let img = profileImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                } else {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
                        
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(width: 110, height: 110)
                }
                
                // Camera Icon overlay
                Button(action: {
                    if isEditing { showPhotoOptions = true }
                }) {
                    ZStack {
                        Circle()
                            .fill(isEditing ? Color.blue : Color.white.opacity(0.2))
                            .frame(width: 32, height: 32)
                            .shadow(radius: 2)
                        
                        Image(systemName: "camera.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                }
                .offset(x: 4, y: 0)
                .disabled(!isEditing)
            }
            
            if isEditing {
                Text("Change Photo")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.top, 4)
            }
        }
    }

    // MARK: - ROWS
    private func profileRow(icon: String, title: String, text: Binding<String>, isEditable: Bool, keyboardType: UIKeyboardType = .default) -> some View {
        HStack(spacing: 16) {
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.9))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                if isEditable {
                    TextField("", text: text)
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                        .keyboardType(keyboardType)
                } else {
                    Text(text.wrappedValue.isEmpty ? "Not Set" : text.wrappedValue)
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                }
            }
            
            Spacer()
            
            if isEditable {
                Image(systemName: "pencil")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.3))
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }

    private var genderRow: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: "person.2.fill")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.9))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Gender")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                if isEditing {
                    Menu {
                        Button("Male") { gender = "Male" }
                        Button("Female") { gender = "Female" }
                        Button("Other") { gender = "Other" }
                        Button("Prefer not to say") { gender = "Prefer not to say" }
                    } label: {
                        HStack {
                            Text(gender)
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .medium))
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                } else {
                    Text(gender)
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                }
            }
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }

    // MARK: - LOGIC
    private func filterAge(_ newValue: String) {
        let filtered = newValue.filter { $0.isNumber }
        if let value = Int(filtered) {
            age = value <= 125 ? String(value) : "125"
        } else {
            age = ""
        }
    }

    private func saveProfileData() {
        let defaults = UserDefaults.standard
        defaults.set(age, forKey: "profileAge")
        defaults.set(gender, forKey: "profileGender")
        defaults.set(phone, forKey: "profilePhone")
        defaults.set(address, forKey: "profileAddress")
    }

    private func saveProfileImage(_ image: UIImage) {
        let userID = UserDefaults.standard.integer(forKey: "loggedInUserID")
        if let url = getProfileURL(for: userID),
           let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: url)
        }
    }
    
    private func removeProfileImage() {
        let userID = UserDefaults.standard.integer(forKey: "loggedInUserID")
        if let url = getProfileURL(for: userID) {
            try? FileManager.default.removeItem(at: url)
            profileImage = nil
        }
    }
    
    private func loadProfileImage() {
        let userID = UserDefaults.standard.integer(forKey: "loggedInUserID")
        if let url = getProfileURL(for: userID),
           let data = try? Data(contentsOf: url),
           let image = UIImage(data: data) {
            profileImage = image
        } else {
            profileImage = nil
        }
    }
    
    private func getProfileURL(for userID: Int) -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("profile_\(userID).jpg")
    }
    
    private func deleteAccountPermanently() {
        let userID = UserDefaults.standard.integer(forKey: "loggedInUserID")
        guard userID != 0 else {
            navigateToLogin()
            return
        }

        var request = URLRequest(url: URL(string: AppConfig.deleteAccountURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["user_id": userID])

        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                let defaults = UserDefaults.standard
                ["loggedInUserID", "loggedInEmail", "profileAge", "profileGender", "profilePhone", "profileAddress", "profileDOB"].forEach { defaults.removeObject(forKey: $0) }
                removeProfileImage()
                navigateToLogin()
            }
        }.resume()
    }

    private func loadData() {
        let defaults = UserDefaults.standard
        email = defaults.string(forKey: "loggedInEmail") ?? ""
        age = defaults.string(forKey: "profileAge") ?? ""
        gender = defaults.string(forKey: "profileGender") ?? "Male"
        phone = defaults.string(forKey: "profilePhone") ?? ""
        address = defaults.string(forKey: "profileAddress") ?? ""
        loadProfileImage()
    }
    
    // MARK: - DELETE SHEET
    @ViewBuilder
    private var deleteSheet: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
                    .padding(.top, 10)
                
                Text("Delete Account")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Are you sure you want to delete your account? This action cannot be undone.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                HStack(spacing: 16) {
                    Button(action: { showDeleteSheet = false }) {
                        Text("Cancel")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(10)
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: {
                        showDeleteSheet = false
                        deleteAccountPermanently()
                    }) {
                        Text("Delete")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                }
                .padding(.top, 10)
            }
            .padding(24)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(24)
            .shadow(radius: 20)
            .padding(30)
        }
        .transition(.opacity)
        .zIndex(100)
    }
}
