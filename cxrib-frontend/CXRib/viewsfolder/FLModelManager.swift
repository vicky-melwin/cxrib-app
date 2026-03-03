// FLModelManager.swift
// Handles saving & loading Federated Learning global models

import Foundation

class FLModelManager {

    static let shared = FLModelManager()
    private init() {
        createFoldersIfNeeded()
        loadModelVersion()
    }

    // ----------------------------------------------------------
    // MARK: - Storage Paths
    // ----------------------------------------------------------

    private let folderName = "FLModels"
    private let versionFileName = "fl_model_version.json"

    private var folderURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask).first!
        return docs.appendingPathComponent(folderName)
    }

    private var versionFileURL: URL {
        folderURL.appendingPathComponent(versionFileName)
    }

    // ----------------------------------------------------------
    // MARK: - Current Model Version
    // ----------------------------------------------------------

    private var currentVersion: Int = 0

    private func loadModelVersion() {
        guard let data = try? Data(contentsOf: versionFileURL) else { return }

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let version = json["version"] as? Int {
            currentVersion = version
        }
    }

    private func saveModelVersion() {
        let json: [String: Any] = ["version": currentVersion]

        if let data = try? JSONSerialization.data(withJSONObject: json,
                                                  options: .prettyPrinted) {
            try? data.write(to: versionFileURL)
        }
    }

    // ----------------------------------------------------------
    // MARK: - Folder
    // ----------------------------------------------------------

    private func createFoldersIfNeeded() {
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            try? FileManager.default.createDirectory(at: folderURL,
                                                     withIntermediateDirectories: true)
        }
    }

    // ----------------------------------------------------------
    // MARK: - Get Current Model Path
    // ----------------------------------------------------------

    func currentModelPath() -> String? {
        if currentVersion == 0 { return nil }

        let file = folderURL.appendingPathComponent("global_model_v\(currentVersion).tflite")

        if FileManager.default.fileExists(atPath: file.path) {
            return file.path
        }

        return nil
    }

    /// Return only the NAME (used for TFLitePredictor)
    func currentModelName() -> String {
        if currentModelPath() != nil {
            return "global_model_v\(currentVersion)"
        }

        // 🟣 Fallback to bundled model
        return "CERVISCAN_model"
    }

    // ----------------------------------------------------------
    // MARK: - Save new global model after FL aggregation
    // ----------------------------------------------------------

    func saveGlobalModel(_ data: Data) {

        // Step 1: Increase version
        currentVersion += 1
        saveModelVersion()

        // Step 2: Write new model to disk
        let path = folderURL.appendingPathComponent("global_model_v\(currentVersion).tflite")

        do {
            try data.write(to: path)
            print("📦 Saved global FL Model v\(currentVersion)")
        } catch {
            print("❌ Failed saving global model:", error.localizedDescription)
        }
    }

    // ----------------------------------------------------------
    // MARK: - Reset Models (Optional)
    // ----------------------------------------------------------

    func resetModels() {
        try? FileManager.default.removeItem(at: folderURL)
        currentVersion = 0
        createFoldersIfNeeded()
        saveModelVersion()
        print("🗑 Cleared all FL models → using bundled model")
    }
}

