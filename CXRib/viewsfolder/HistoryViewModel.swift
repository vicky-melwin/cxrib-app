import Foundation
import Combine

class HistoryViewModel: ObservableObject {

    @Published var history: [ScanItem] = []
    @Published var isLoading = false
    @Published var errorMessage = ""

    // =======================================================
    // LOAD SCAN HISTORY
    // =======================================================
    func loadHistory(userID: Int) {
        guard userID != 0 else {
            self.errorMessage = "User not logged in"
            return
        }

        let urlString = "\(AppConfig.apiBase)/get_history.php?user_id=\(userID)"
        guard let url = URL(string: urlString) else {
            self.errorMessage = "Invalid API URL"
            return
        }

        isLoading = true
        errorMessage = ""

        URLSession.shared.dataTask(with: url) { data, response, error in

            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No response from server"
                    self.isLoading = false
                }
                return
            }

            print("📥 RAW HISTORY RESPONSE:")
            print(String(data: data, encoding: .utf8) ?? "nil")

            do {
                let decoded = try JSONDecoder().decode(HistoryResponse.self, from: data)

                DispatchQueue.main.async {
                    if decoded.status == "success" {
                        self.history = decoded.history
                    } else {
                        self.history = []
                        self.errorMessage = "Server returned failure"
                    }
                    self.isLoading = false
                }

            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Decode failed: \(error.localizedDescription)"
                    self.isLoading = false
                }
                print("❌ JSON DECODE ERROR:", error)
            }

        }.resume()
    }
}

//
// =======================================================
// MARK: - MODELS (REQUIRED)
// =======================================================
//

struct HistoryResponse: Codable {
    let status: String
    let history: [ScanItem]
}

struct ScanItem: Identifiable, Codable {
    var id: Int { scan_id }   // Helps SwiftUI List
    
    let scan_id: Int
    let patient_id: Int
    let name: String
    let age: Int
    let gender: String
    let case_id: String
    let image_path: String
    let label: String
    let confidence: Double
    let created_at: String
}

