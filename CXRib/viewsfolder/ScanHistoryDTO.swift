struct ScanHistoryDTO: Codable {
    let id: Int
    let patient_id: Int
    let patient_name: String
    let age: Int
    let gender: String
    let case_id: Int
    let prediction: String
    let confidence: Double
    let image_url: String
}

