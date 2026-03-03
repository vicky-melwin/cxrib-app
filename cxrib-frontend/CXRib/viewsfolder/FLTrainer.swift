//
//  FLTrainer.swift
//  CerviScan
//
//  Performs local federated learning training
//

import UIKit
import Accelerate

class FLTrainer {

    static let shared = FLTrainer()
    private init() {}


    // -------------------------------------------------------
    // MARK: - MAIN LOCAL TRAINING ENTRY
    // -------------------------------------------------------
    func runLocalTraining() -> ([Float], Int) {

        let samples = FLDatasetManager.shared.listSamples()

        guard !samples.isEmpty else {
            print("⚠️ No FL training samples found")
            return ([], 0)
        }

        print("🧠 Starting local training on \(samples.count) samples")

        var trainingBatch: [(pixels: [Float], labelIndex: Int)] = []

        // Load and preprocess each saved FL sample
        for sample in samples {

            guard let uiImage = FLDatasetManager.shared.loadSampleImage(sample: sample) else {
                print("⚠️ Unable to load saved FL image:", sample.imageFileName)
                continue
            }

            guard let pixelArray = preprocessImage224(image: uiImage) else {
                print("⚠️ Failed to preprocess sample:", sample.imageFileName)
                continue
            }

            let targetClass = classIndex(for: sample.label)
            trainingBatch.append((pixelArray, targetClass))
        }

        if trainingBatch.isEmpty {
            print("❌ No valid training samples available")
            return ([], 0)
        }

        // -------------------------------------------------------
        // STEP 6 (REAL TRAINING WILL BE ADDED LATER)
        // CURRENTLY: Generate FAKE gradient update
        // -------------------------------------------------------

        let fakeUpdate = generateFakeGradientDemo()

        print("📤 Local model update generated → \(fakeUpdate.count) floats")
        return (fakeUpdate, trainingBatch.count)
    }


    // -------------------------------------------------------
    // MARK: - SAVE TRAINING EXAMPLE
    // -------------------------------------------------------
    func saveTrainingExample(image: UIImage, label: String) {
        FLDatasetManager.shared.saveTrainingExample(image: image, label: label)
    }


    // -------------------------------------------------------
    // MARK: - IMAGE PREPROCESSING (→ 224×224 Float Array)
    // -------------------------------------------------------
    private func preprocessImage224(image: UIImage) -> [Float]? {

        guard let cgImage = image.cgImage else { return nil }

        let width = 224
        let height = 224
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel

        var rawBytes = [UInt8](repeating: 0, count: Int(bytesPerRow * height))

        guard let ctx = CGContext(
            data: &rawBytes,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }

        ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        // Convert BGRA → RGB normalized floats
        var floats: [Float] = []
        floats.reserveCapacity(width * height * 3)

        for i in stride(from: 0, to: rawBytes.count, by: 4) {
            let r = Float(rawBytes[i]) / 255.0
            let g = Float(rawBytes[i+1]) / 255.0
            let b = Float(rawBytes[i+2]) / 255.0
            floats.append(contentsOf: [r, g, b])
        }

        return floats
    }


    // -------------------------------------------------------
    // MARK: - LABEL → INDEX MAPPING
    // -------------------------------------------------------
    private func classIndex(for label: String) -> Int {
        switch label.lowercased() {
        case "right": return 0
        case "left": return 1
        case "bilateral": return 2
        default: return 3  // "no_rib"
        }
    }


    // -------------------------------------------------------
    // MARK: - FAKE GRADIENT GENERATOR (DEMO)
    // -------------------------------------------------------
    private func generateFakeGradientDemo() -> [Float] {
        let count = 256
        return (0..<count).map { _ in Float.random(in: -0.01 ... 0.01) }
    }
}

