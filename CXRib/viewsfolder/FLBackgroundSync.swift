//
//  FLBackgroundSync.swift
//  CerviScan
//
//  Handles:
//  1. FL client registration
//  2. Local training
//  3. Uploading updates to server
//  4. Downloading new global model
//  5. Auto-scheduling background sync
//

import Foundation
import UIKit

class FLBackgroundSync {

    static let shared = FLBackgroundSync()

    private init() {}

    private var isSyncing = false
    private var timer: Timer?


    // ---------------------------------------------------
    // MARK: - PUBLIC API (Called from App Startup)
    // ---------------------------------------------------
    func startAutoSync() {
        print("🔁 FL Auto-Sync Enabled")
        scheduleNextSync(after: 10)   // First sync after 10 sec
    }


    // ---------------------------------------------------
    // Schedule manual sync (called after training example)
    // ---------------------------------------------------
    func scheduleNextSync(after seconds: TimeInterval = 10) {

        timer?.invalidate()

        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { _ in
                self.performSync()
            }
        }
    }


    // ---------------------------------------------------
    // MARK: - MAIN SYNC LOGIC
    // ---------------------------------------------------
    private func performSync() {

        guard !isSyncing else {
            print("⏳ FL sync skipped: already syncing")
            return
        }

        isSyncing = true
        print("🚀 Starting FL background sync...")


        // 1️⃣ REGISTER CLIENT WITH SERVER
        FLClient.shared.registerClient { clientID in

            guard let clientID = clientID else {
                print("❌ FL Sync Error: Could not get clientID")
                self.isSyncing = false
                return
            }


            // 2️⃣ RUN LOCAL TRAINING
            let (updateVector, sampleCount) = FLTrainer.shared.runLocalTraining()

            if sampleCount == 0 {
                print("⚠️ No local FL samples → scheduling later")
                self.isSyncing = false
                self.scheduleNextSync(after: 30)
                return
            }


            // 3️⃣ UPLOAD UPDATE TO SERVER
            FLClient.shared.submitUpdate(
                clientID: clientID,
                update: updateVector,
                samples: sampleCount
            ) { success in

                if success {
                    print("📤 Update uploaded successfully")
                } else {
                    print("❌ Update upload failed")
                }


                // 4️⃣ DOWNLOAD LATEST GLOBAL MODEL
                self.downloadModel { _ in
                    self.isSyncing = false
                    self.scheduleNextSync(after: 60)   // Sync every 1 min
                }
            }
        }
    }


    // ---------------------------------------------------
    // MARK: - Model Download
    // ---------------------------------------------------
    private func downloadModel(completion: @escaping (Bool) -> Void) {

        FLClient.shared.downloadLatestModel { data in

            guard let data = data else {
                print("⚠️ No new global model available")
                completion(false)
                return
            }

            FLModelManager.shared.saveGlobalModel(data)
            print("📦 Updated global FL model")

            completion(true)
        }
    }
}

