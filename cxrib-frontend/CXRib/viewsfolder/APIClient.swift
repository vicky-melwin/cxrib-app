import Foundation
import UIKit

final class APIClient {
    
    static let shared = APIClient()
    private init() {}
    
    // =====================================================
    // MARK: - UPLOAD & SAVE SCAN
    // =====================================================
    func uploadAndSaveScan(
        patientID: Int,
        label: String,
        confidence: Double,
        image: UIImage,
        completion: @escaping (Int?) -> Void
    ) {
        
        guard let url = URL(string: AppConfig.saveScanURL) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )
        
        let body = MultipartFormDataBuilder(boundary: boundary)
            .addField("patient_id", "\(patientID)")
            .addField("label", label)
            .addField("confidence", "\(confidence)")
            .addImageField("image", image)
            .build()
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            
            if let error {
                print("❌ Scan upload error:", error.localizedDescription)
                completion(nil)
                return
            }
            
            guard
                let data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let scanID = json["scan_id"] as? Int
            else {
                print("❌ Invalid scan upload response")
                if let data = data, let str = String(data: data, encoding: .utf8) {
                    print("📄 Server Response:", str)
                }
                completion(nil)
                return
            }
            
            completion(scanID)
        }.resume()
    }
    
    // =====================================================
    // MARK: - SAVE PATIENT
    // =====================================================
    func savePatient(
        userId: Int,
        name: String,
        age: Int,
        gender: String,
        caseId: Int,
        completion: @escaping (Result<Int, Error>) -> Void
    ) {
        
        guard let url = URL(string: AppConfig.savePatientURL) else {
            completion(.failure(NSError(domain: "BadURL", code: -1)))
            return
        }
        
        let payload: [String: Any] = [
            "user_id": userId,
            "name": name,
            "age": age,
            "gender": gender,
            "case_id": caseId
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            
            if let error {
                completion(.failure(error))
                return
            }
            
            guard let data else {
                completion(.failure(NSError(domain: "NoData", code: -1)))
                return
            }
            
            do {
                let decoded = try JSONDecoder()
                    .decode(SavePatientResponse.self, from: data)
                
                if decoded.status == "success" {
                    completion(.success(decoded.patient_id))
                } else {
                    completion(.failure(NSError(domain: "ServerError", code: -2)))
                }
                
            } catch {
                print("❌ Patient decode error:", error)
                completion(.failure(error))
            }
        }.resume()
    }
    
    // =====================================================
    // MARK: - DELETE SCAN (SERVER)
    // =====================================================
    func deleteScan(
        serverScanID: Int,
        completion: @escaping (Bool) -> Void
    ) {
        
        guard let url = URL(string: AppConfig.deleteScanURL) else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "application/x-www-form-urlencoded",
            forHTTPHeaderField: "Content-Type"
        )
        request.httpBody = "scan_id=\(serverScanID)"
            .data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            
            if let error {
                print("❌ Delete scan error:", error.localizedDescription)
                completion(false)
                return
            }
            
            let success =
            (response as? HTTPURLResponse)?.statusCode == 200
            
            completion(success)
            
        }.resume()
    }
    
    // =====================================================
    // MARK: - FETCH SCAN HISTORY
    // =====================================================
    func fetchScanHistory(
        userId: Int,
        completion: @escaping (Result<[ScanHistoryDTO], Error>) -> Void
    ) {
        
        guard let url = URL(
            string: "\(AppConfig.getScanHistoryURL)?user_id=\(userId)"
        ) else {
            completion(.failure(NSError(domain: "BadURL", code: -1)))
            return
        }
        
        
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
        request.httpMethod = "GET"

        print("📡 Fetching Scan History: \(url.absoluteString)")

        URLSession.shared.dataTask(with: request) { data, _, error in
            
            if let error {
                completion(.failure(error))
                return
            }
            
            guard let data else {
                completion(.failure(NSError(domain: "NoData", code: -1)))
                return
            }
            
            do {
                let decoded = try JSONDecoder()
                    .decode(ScanHistoryResponse.self, from: data)
                
                completion(.success(decoded.scans))
                
            } catch {
                print("❌ Scan history decode error:", error)
                completion(.failure(error))
            }
        }.resume()
    }
    
    // =====================================================
    // MARK: - FETCH DELETED PATIENTS
    // =====================================================
    func fetchDeletedPatients(
        since: String,
        completion: @escaping (Result<[Int], Error>) -> Void
    ) {
        
        guard let url = URL(
            string: "\(AppConfig.apiBase)/get_deleted_patients.php?since=\(since)"
        ) else {
            completion(.success([]))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            
            if let error {
                completion(.failure(error))
                return
            }
            
            guard let data else {
                completion(.success([]))
                return
            }
            
            do {
                let decoded = try JSONDecoder()
                    .decode(DeletedPatientsResponse.self, from: data)
                
                completion(.success(decoded.deleted_ids))
                
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // =====================================================
    // MARK: - RESPONSE MODELS (KEEP ONLY ONCE)
    // =====================================================
    
    struct SavePatientResponse: Codable {
        let status: String
        let patient_id: Int
    }
    
    struct ScanHistoryResponse: Codable {
        let status: String
        let scans: [ScanHistoryDTO]
    }
    
    struct DeletedPatientsResponse: Codable {
        let deleted_ids: [Int]
    }
}
