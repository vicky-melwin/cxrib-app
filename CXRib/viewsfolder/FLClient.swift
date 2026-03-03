//
//  FLClient.swift
//  CerviScan
//
//  Handles:
//  - Federated client registration
//  - Uploading local gradients/updates
//  - Downloading latest global model
//

import Foundation

class FLClient {

    static let shared = FLClient()
    private init() {}

    // MARK: - Base URL
    private var baseURL: String {
        #if targetEnvironment(simulator)
        return "http://127.0.0.1:8000/fl"
        #else
        return "http://10.61.91.98:8000/fl"
        #endif
    }

    private let clientIDKey = "FLClientID"


    // ----------------------------------------------------------
    // MARK: - REGISTER CLIENT
    // ----------------------------------------------------------

    func registerClient(completion: @escaping (String?) -> Void) {

        // Return existing client ID
        if let existing = UserDefaults.standard.string(forKey: clientIDKey) {
            completion(existing)
            return
        }

        guard let url = URL(string: "\(baseURL)/register_client.php") else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let id = json["client_id"] as? String
            else {
                completion(nil)
                return
            }

            UserDefaults.standard.set(id, forKey: self.clientIDKey)
            completion(id)

        }.resume()
    }


    // ----------------------------------------------------------
    // MARK: - SUBMIT LOCAL UPDATE
    // ----------------------------------------------------------

    func submitUpdate(clientID: String,
                      update: [Float],
                      samples: Int,
                      completion: @escaping (Bool) -> Void)
    {
        guard let url = URL(string: "\(baseURL)/upload_update.php") else {
            completion(false)
            return
        }

        // Convert to JSON-safe format
        let updateDouble = update.map { Double($0) }

        let payload: [String: Any] = [
            "client_id": clientID,
            "update": updateDouble,
            "samples": samples
        ]

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: req) { data, _, _ in
            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let status = json["status"] as? String,
                status == "success"
            else {
                completion(false)
                return
            }

            completion(true)

        }.resume()
    }


    // ----------------------------------------------------------
    // MARK: - DOWNLOAD GLOBAL MODEL
    // ----------------------------------------------------------

    func downloadLatestModel(completion: @escaping (Data?) -> Void) {

        guard let url = URL(string: "\(baseURL)/get_global_model.php") else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in

            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let modelDict = json["model"] as? [String: Any],
                let weights = modelDict["weights"] as? [Double]
            else {
                completion(nil)
                return
            }

            // Convert Double → Float → Data
            var floatWeights = weights.map { Float($0) }
            let buffer = UnsafeBufferPointer(start: &floatWeights, count: floatWeights.count)
            let dataOut = Data(buffer: buffer)

            completion(dataOut)

        }.resume()
    }
}

