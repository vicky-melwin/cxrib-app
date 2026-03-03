//
//  FLDatasetManager.swift
//  CerviScan
//

import UIKit

class FLDatasetManager {

    static let shared = FLDatasetManager()

    private init() {
        createFolderIfNeeded()
        loadMetadata()
    }

    private let folderName = "FLSamples"
    private let metadataFile = "metadata.json"

    private var samples: [FLTrainingSample] = []

    // MARK: - Paths

    private var folderURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask).first!
        return docs.appendingPathComponent(folderName)
    }

    private var metadataURL: URL {
        folderURL.appendingPathComponent(metadataFile)
    }

    // MARK: - Setup

    private func createFolderIfNeeded() {
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            try? FileManager.default.createDirectory(
                at: folderURL,
                withIntermediateDirectories: true
            )
        }
    }

    private func loadMetadata() {
        guard let data = try? Data(contentsOf: metadataURL) else { return }
        samples = (try? JSONDecoder().decode([FLTrainingSample].self, from: data)) ?? []
    }

    private func saveMetadata() {
        guard let encoded = try? JSONEncoder().encode(samples) else { return }
        try? encoded.write(to: metadataURL)
    }

    // MARK: - Save Training Example

    func saveTrainingExample(image: UIImage, label: String) {

        guard let resized = image.fl_resized(to: CGSize(width: 224, height: 224)),
              let jpeg = resized.jpegData(compressionQuality: 0.85)
        else {
            print("❌ FL resize error")
            return
        }

        let fileName = "FL_\(UUID().uuidString).jpg"
        let fileURL = folderURL.appendingPathComponent(fileName)

        do { try jpeg.write(to: fileURL) }
        catch {
            print("❌ Save error", error.localizedDescription)
            return
        }

        samples.append(FLTrainingSample(imageFileName: fileName, label: label))
        saveMetadata()

        print("📥 Saved FL sample:", fileName)
    }

    // MARK: - Load

    func listSamples() -> [FLTrainingSample] { samples }

    func loadSampleImage(sample: FLTrainingSample) -> UIImage? {
        UIImage(contentsOfFile: folderURL.appendingPathComponent(sample.imageFileName).path)
    }

    // MARK: - Delete All

    func deleteAllSamples() {
        try? FileManager.default.removeItem(at: folderURL)
        samples.removeAll()
        createFolderIfNeeded()
        saveMetadata()
    }

    // MARK: - Stats

    func totalSamples() -> Int { samples.count }

    func sampleBatch(limit: Int) -> [FLTrainingSample] {
        Array(samples.prefix(limit))
    }
}


// MARK: - Safe Resize (No Conflict)
extension UIImage {
    func fl_resized(to size: CGSize) -> UIImage? {
        UIGraphicsImageRenderer(size: size).image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

