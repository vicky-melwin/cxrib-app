import Foundation

final class SessionManager {

    static let shared = SessionManager()

    private init() {
        // 🔥 Restore userID when app launches
        userID = UserDefaults.standard.integer(forKey: userIDKey)
        print("🟢 Session restored userID:", userID)
    }

    private let userIDKey = "loggedInUserID"

    var userID: Int = 0 {
        didSet {
            UserDefaults.standard.set(userID, forKey: userIDKey)
            print("🆔 UserID updated:", userID)
        }
    }

    func clear() {
        userID = 0
        UserDefaults.standard.removeObject(forKey: userIDKey)
        print("🧹 Session cleared")
    }
}

