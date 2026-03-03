import Foundation

class APIService {
    static let baseURL = "http://127.0.0.1:8000/api"

    static func login(email: String, password: String, completion: @escaping (Dictionary<String, Any>?) -> Void) {
        guard let url = URL(string: "\(baseURL)/login.php") else { return }

        let body = ["email": email, "password": password]

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try! JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: req) { data, _, _ in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                completion(json)
            }
        }.resume()
    }
}

