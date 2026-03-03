import Foundation

// MARK: - LOGIN
struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Codable {
    let status: String
    let message: String
    let user_id: Int?
    let name: String?
}

// MARK: - SIGNUP
struct SignupRequest: Codable {
    let name: String
    let email: String
    let password: String
}

struct SignupResponse: Codable {
    let status: String
    let message: String
}

// MARK: - PATIENT SAVE
struct PatientRequest: Codable {
    let user_id: Int
    let name: String
    let age: Int
    let gender: String
    let case_id: String
}

struct PatientResponse: Codable {
    let status: String
    let patient_id: Int?
}

// MARK: - RESULT SAVE
struct ResultRequest: Codable {
    let patient_id: Int
    let prediction_label: String
    let confidence_value: Double
    let image_path: String?
}

struct ResultResponse: Codable {
    let status: String
    let message: String
}

