import Foundation
import CoreData
import UIKit

final class CoreDataManager {

    static let shared = CoreDataManager()

    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "CerviScan")

        container.loadPersistentStores { _, error in
            if let error = error {
                print("❌ Core Data failed:", error.localizedDescription)
            } else {
                print("✅ Core Data ready")
            }
        }

        container.viewContext.mergePolicy =
            NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    var context: NSManagedObjectContext {
        container.viewContext
    }

    func save() {
        if context.hasChanges {
            try? context.save()
        }
    }
}

// ======================================================
// MARK: - PATIENT (OFFLINE FIRST)
// ======================================================

extension CoreDataManager {

    @discardableResult
    func savePatientLocally(
        name: String,
        age: Int,
        gender: String,
        caseID: Int
    ) -> Patient {

        let patient = Patient(context: context)

        patient.id = Int64(Date().timeIntervalSince1970)
        patient.name = name
        patient.age = Int16(age)
        patient.gender = gender
        patient.caseID = Int64(caseID)

        // 🔥🔥 THIS IS THE MISSING LINE (CRITICAL)
        patient.userID = Int64(SessionManager.shared.userID)

        patient.createdAt = Date()
        patient.serverPatientID = 0 // not synced yet

        save()

        print("👤 Patient saved locally:", name)

        return patient
    }

    func fetchPatients(for userID: Int) -> [Patient] {
        let req: NSFetchRequest<Patient> = Patient.fetchRequest()
        req.predicate = NSPredicate(format: "userID == %d", userID)
        return (try? context.fetch(req)) ?? []
    }

    func fetchUnsyncedPatients() -> [Patient] {
        let req: NSFetchRequest<Patient> = Patient.fetchRequest()
        req.predicate = NSPredicate(format: "serverPatientID == 0")
        let patients = (try? context.fetch(req)) ?? []
        print("🔄 Unsynced patients:", patients.count)
        return patients
    }

    func updatePatientServerID(
        localPatientID: Int,
        serverPatientID: Int
    ) {
        let req: NSFetchRequest<Patient> = Patient.fetchRequest()
        req.predicate = NSPredicate(format: "id == %d", localPatientID)

        if let patient = try? context.fetch(req).first {
            patient.serverPatientID = Int64(serverPatientID)
            save()
            print("☁️ Patient synced:", patient.name ?? "")
        }
    }
}

// ======================================================
// MARK: - FETCH UNSYNCED SCANS (SYNC SUPPORT)
// ======================================================

extension CoreDataManager {
    
    /// Returns scans that are not yet synced to server
    func fetchPendingScans() -> [ScanHistory] {
        
        let request: NSFetchRequest<ScanHistory> =
        ScanHistory.fetchRequest()
        
        request.predicate = NSPredicate(
            format: "isSynced == NO OR serverScanID == 0"
        )
        
        request.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: true)
        ]
        
        do {
            let scans = try context.fetch(request)
            print("🔍 Pending scans found:", scans.count)
            return scans
        } catch {
            print("❌ Patient sync failed:", error.localizedDescription)
            return []
        }
    }
    
    func deletePatients(withIDs ids: [Int]) {
        
        let context = container.viewContext   // ✅ FIXED
        
        let request: NSFetchRequest<Patient> = Patient.fetchRequest()
        request.predicate = NSPredicate(format: "serverId IN %@", ids)
        
        do {
            let patients = try context.fetch(request)
            patients.forEach { context.delete($0) }
            try context.save()
            print("🗑 Deleted patients locally:", ids)
        } catch {
            print("❌ Failed to delete local patients:", error)
        }
    }
    
    // ✅ NEW: Delete valid synced patients that are NOT in the active list
    func deleteSyncedPatients(excludingServerIDs: [Int], forUserID: Int) {
        let request: NSFetchRequest<Patient> = Patient.fetchRequest()
        
        // Find patients who:
        // 1. Belong to this user
        // 2. Are already synced (serverPatientID > 0)
        // 3. Are NOT in the "active" list from server
        request.predicate = NSPredicate(
            format: "userID == %d AND serverPatientID > 0 AND NOT (serverPatientID IN %@)",
            forUserID,
            excludingServerIDs
        )
        
        do {
            let stalePatients = try context.fetch(request)
            if !stalePatients.isEmpty {
                print("🗑 Found \(stalePatients.count) stale patients to delete")
                stalePatients.forEach { context.delete($0) }
                try context.save()
            }
        } catch {
            print("❌ Failed to delete stale patients:", error.localizedDescription)
        }
    }
    
    func deleteAllScanHistory() {
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(
            entityName: "ScanHistory"
        )
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetch)
        
        do {
            try container.viewContext.execute(deleteRequest)
            try container.viewContext.save()
            print("🗑️ Local scan history cleared")
        } catch {
            print("❌ Failed to clear scan history:", error)
        }
    }
    
    // ✅ ROBUST SYNC: Fetch all, Delete Missing, Insert/Update New
    func syncScanHistory(from scans: [ScanHistoryDTO], forUserID: Int) {
        
        // 1. Get IDs from server
        let serverIDs = scans.map { $0.id }
        
        // 2. Fetch existing synced scans for this user
        // SAFETY: Only fetch scans that HAVE a server ID to avoid deleting pending uploads
        let request: NSFetchRequest<ScanHistory> = ScanHistory.fetchRequest()
        request.predicate = NSPredicate(format: "userID == %d AND serverScanID > 0", forUserID)
        
        do {
            let existingScans = try context.fetch(request)
            
            // 3. IDENTIFY & DELETE STALE SCANS
            // (Scans that exist locally but NOT in the new server list)
            print("🔄 Sync Logic: Server has \(serverIDs.count) items vs Local \(existingScans.count) items (UserID: \(forUserID))")
            
            existingScans.forEach { scan in
                let serverID = Int(scan.serverScanID)
                if !serverIDs.contains(serverID) {
                    context.delete(scan)
                    print("🗑 Deleting stale scan locally: ID \(serverID) (Not in server list)")
                }
            }
            
            // 4. UPSERT (Update existing or Insert new)
            for dto in scans {
                // Check if we already have this scan
                if let existing = existingScans.first(where: { $0.serverScanID == Int64(dto.id) }) {
                    // OPTIONAL: Update fields if they can change (e.g. label correction)
                    // existing.predictedClass = dto.prediction
                } else {
                    // INSERT NEW
                    let scan = ScanHistory(context: context)
                    scan.id = Int64(dto.id)
                    scan.serverScanID = Int64(dto.id)
                    scan.userID = Int64(SessionManager.shared.userID)
                    scan.patientName = dto.patient_name
                    scan.patientAge = Int16(dto.age)
                    scan.patientGender = dto.gender
                    scan.caseID = Int64(dto.case_id)
                    scan.predictedClass = dto.prediction
                    scan.confidence = dto.confidence
                    scan.confidence = dto.confidence
                    
                    // ✅ FIX: Extract filename if server sends full URL
                    if let url = URL(string: dto.image_url) {
                        scan.imageFileName = url.lastPathComponent
                    } else {
                        scan.imageFileName = dto.image_url
                    }

                    scan.isSynced = true
                    scan.createdAt = Date() // Or parse from server if available
                    scan.dateString = ISO8601DateFormatter().string(from: Date())
                    print("📥 Inserted new scan from server: \(dto.id)")
                }
            }
            
            // 5. SYNC PATIENTS (Same logic: Remove if no longer referenced)
            let activePatientIDs = Set(scans.map { $0.patient_id })
            deleteSyncedPatients(excludingServerIDs: Array(activePatientIDs), forUserID: forUserID)
            
            try context.save()
            print("✅ Sync complete. Total server items: \(scans.count)")
            
        } catch {
            print("❌ Sync failed:", error.localizedDescription)
        }
    }
    
    func clearScanHistory() {
        let request: NSFetchRequest<ScanHistory> = ScanHistory.fetchRequest()
        
        do {
            let scans = try context.fetch(request)
            scans.forEach { context.delete($0) }
            save()
            print("🧹 Cleared local scan history")
        } catch {
            print("❌ Failed to clear scan history:", error.localizedDescription)
        }
    }
}
