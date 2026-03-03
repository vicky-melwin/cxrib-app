import Foundation

final class AuthStore {
    static let shared = AuthStore()
    private let kToken = "cerviscan.jwt"
    var token: String? {
        get { UserDefaults.standard.string(forKey: kToken) }
        set { UserDefaults.standard.setValue(newValue, forKey: kToken) }
    }
    private init() {}
}

