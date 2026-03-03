import Foundation

struct AppConfig {

    // =====================================================
    // 🔥 CHANGE ONLY THIS LINE WHEN SWITCHING SERVER 🔥
    // =====================================================
//    static let apiBase = "http://10.113.196.98/cerviscan-backend/api"
    // Example for college server:
     static let apiBase = "https://14.139.187.229:8081/april_2025_batch/cxrib/api"

    // =====================================================
    // MARK: - AUTH
    // =====================================================
    static let loginURL      = "\(apiBase)/login.php"
    static let signupURL     = "\(apiBase)/signup.php"
    static let sendOTPURL    = "\(apiBase)/send_otp.php"
    static let verifyOTPURL  = "\(apiBase)/verify_otp.php"

    // =====================================================
    // MARK: - ACCOUNT
    // =====================================================
    static let deleteAccountURL = "\(apiBase)/delete_account.php"

    // =====================================================
    // MARK: - PATIENT
    // =====================================================
    static let savePatientURL = "\(apiBase)/save_patient.php"

    // =====================================================
    // MARK: - SCANS
    // =====================================================
    static let saveScanURL        = "\(apiBase)/save_scan.php"
    static let getScanHistoryURL  = "\(apiBase)/get_scan_history.php"
    static let deleteScanURL      = "\(apiBase)/delete_scan.php"

    // =====================================================
    // MARK: - IMAGE
    // =====================================================
    static let uploadsBaseURL = "\(apiBase)/uploads"

    static func fullImageURL(_ filename: String) -> String {
        if filename.hasPrefix("http") {
            return filename
        }
        return "\(uploadsBaseURL)/\(filename)"
    }
}
