// FLDebugTools.swift
// Optional debug helpers for Federated Learning

import Foundation
import UIKit

class FLDebugTools {

    static let shared = FLDebugTools()
    private init() {}

    // ----------------------------------------------------
    // MARK: - Print all local FL samples
    // ----------------------------------------------------
    func printLocalSamples() {
        let samples = FLDatasetManager.shared.listSamples()

        print("\n====== LOCAL FL SAMPLES ======")
        if samples.isEmpty {
            print("(none)")
            return
        }

        for s in samples {
            print("- File: \(s.imageFileName), Label: \(s.label)")
        }
    }

    // ----------------------------------------------------
    // MARK: - Delete all local samples
    // ----------------------------------------------------
    func clearAllSamples() {
        FLDatasetManager.shared.deleteAllSamples()
        print("🗑 Cleared all local FL samples")
    }

    // ----------------------------------------------------
    // MARK: - Model Debugging
    // ----------------------------------------------------
    func printCurrentModel() {
        if let path = FLModelManager.shared.currentModelPath() {
            print("📦 Current FL Model Path → \(path)")
        } else {
            print("📦 Currently using bundled model: CERVISCAN_model.tflite")
        }
    }

    // ----------------------------------------------------
    // MARK: - Force Model Reset
    // ----------------------------------------------------
    func resetModels() {
        FLModelManager.shared.resetModels()
        print("🔄 All FL models reset. Using bundled model now.")
    }
}

