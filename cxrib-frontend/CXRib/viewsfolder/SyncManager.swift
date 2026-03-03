import UIKit
import CoreData

final class SyncManager {

    static let shared = SyncManager()
    private init() {}

    // =====================================================
    // MARK: - ENTRY
    // =====================================================
    func syncAll() {
        // 1. First sync patients (Parents)
        syncPendingPatients { [weak self] in
            // 2. Then sync scans (Children)
            self?.syncPendingScans()
            
            // 3. Finally sync deletions
            self?.syncDeletedPatients()
            
            // 4. And refresh list to match server state
            self?.refreshScanHistoryFromServer()
        }
    }

    // =====================================================
    // MARK: - PATIENT SYNC
    // =====================================================
    func syncPendingPatients(completion: @escaping () -> Void = {}) {
        guard NetworkMonitor.shared.isConnected else {
            completion()
            return
        }

        let patients = CoreDataManager.shared.fetchUnsyncedPatients()
        
        if patients.isEmpty {
            completion()
            return
        }

        let group = DispatchGroup()

        for patient in patients {
            group.enter()
            APIClient.shared.savePatient(
                userId: Int(patient.userID),
                name: patient.name ?? "",
                age: Int(patient.age),
                gender: patient.gender ?? "",
                caseId: Int(patient.caseID)
            ) { result in
                
                DispatchQueue.main.async { // Ensure Core Data access is on main thread/context
                    if case .success(let serverId) = result {
                        patient.serverPatientID = Int64(serverId)
                        CoreDataManager.shared.save()
                        print("✅ Patient synced:", serverId)
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }

    // =====================================================
    // MARK: - SCAN SYNC
    // =====================================================
    func syncPendingScans() {
        guard NetworkMonitor.shared.isConnected else { return }

        let scans = CoreDataManager.shared.fetchPendingScans()
        for scan in scans {
            syncOneScan(scan)
        }
    }

    private func syncOneScan(_ scan: ScanHistory) {
        
        var serverIDToUse = scan.serverPatientID
        
        // 🔍 RESOLVE LOCAL ID TO SERVER ID
        // If the ID stored is a Local Patient ID (Timestamp), we need to find the real Server ID.
        let ctx = CoreDataManager.shared.context
        let request: NSFetchRequest<Patient> = Patient.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", scan.serverPatientID)
        
        if let patient = try? ctx.fetch(request).first {
            if patient.serverPatientID > 0 {
                serverIDToUse = patient.serverPatientID
                
                // Update local record to use server ID for future stability
                scan.serverPatientID = serverIDToUse
                try? ctx.save()
                print("🔗 Resolved Scan Local Patient ID \(patient.id) -> Server ID \(serverIDToUse)")
            } else {
                print("⏳ Patient not synced yet for scan \(scan.imageFileName ?? ""). Skipping.")
                return 
            }
        }
        
        if serverIDToUse == 0 {
            return
        }
        
        syncScanOnly(scan, patientId: Int(serverIDToUse))
    }

    // ✅ MUST BE OUTSIDE OTHER FUNCTIONS
    private func syncScanOnly(_ scan: ScanHistory, patientId: Int) {

        guard
            let fileName = scan.imageFileName,
            let label = scan.predictedClass
        else { return }

        let path = CoreDataManager.shared.buildLocalImagePath(filename: fileName)

        guard let image = UIImage(contentsOfFile: path) else { return }

        APIClient.shared.uploadAndSaveScan(
            patientID: patientId,
            label: label,
            confidence: scan.confidence,
            image: image
        ) { serverScanId in
            if let id = serverScanId {
                scan.serverScanID = Int64(id)
                scan.isSynced = true
                CoreDataManager.shared.save()
                print("✅ Scan synced:", id)
            }
        }
    }
    
    func syncDeletedPatients() {

        let lastSync = UserDefaults.standard.string(
            forKey: "lastDeleteSync"
        ) ?? "1970-01-01 00:00:00"

        APIClient.shared.fetchDeletedPatients(since: lastSync) { result in
            switch result {
            case .success(let ids):
                if !ids.isEmpty {
                    CoreDataManager.shared.deletePatients(withIDs: ids)
                }

                UserDefaults.standard.set(
                    ISO8601DateFormatter().string(from: Date()),
                    forKey: "lastDeleteSync"
                )

            case .failure(let error):
                print("❌ Delete sync failed:", error.localizedDescription)
            }
        }
    }
    
    func refreshScanHistoryFromServer() {

        guard NetworkMonitor.shared.isConnected else {
            print("📴 Offline — cannot refresh")
            return
        }

        APIClient.shared.fetchScanHistory(
            userId: SessionManager.shared.userID
        ) { result in

            DispatchQueue.main.async {

                switch result {

                case .success(let scans):
                    CoreDataManager.shared.syncScanHistory(
                        from: scans,
                        forUserID: SessionManager.shared.userID
                    )
                    print("🔄 Scan history refreshed from server")

                case .failure(let error):
                    print("❌ Failed to refresh history:", error.localizedDescription)
                }
            }
        }
    }
}
