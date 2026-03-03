import CoreData
import Foundation

extension ScanHistory {

    static func serverObject(_ json: [String: Any]) -> ScanHistory {

        let ctx = CoreDataManager.shared.context
        let item = ScanHistory(context: ctx)

        item.serverScanID = Int64(json["id"] as? Int ?? 0)
        item.userID = Int64(SessionManager.shared.userID)

        item.patientName = json["patient_name"] as? String
        item.patientAge = Int16(json["age"] as? Int ?? 0)
        item.patientGender = json["gender"] as? String
        item.caseID = Int64(json["case_id"] as? Int ?? 0)

        item.predictedClass = json["label"] as? String
        item.confidence = json["confidence"] as? Double ?? 0.0

        item.imageFileName = json["image"] as? String
        item.createdAt = Date()

        return item
    }
}
