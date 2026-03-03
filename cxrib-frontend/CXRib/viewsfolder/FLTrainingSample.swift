// FLTrainingSample.swift
// Federated Learning Training Sample Model

import Foundation

/// Each FL training sample saved on device
struct FLTrainingSample: Codable, Identifiable {
    let id: String
    let imageFileName: String
    let label: String
    let createdAt: TimeInterval

    init(imageFileName: String, label: String) {
        self.id = UUID().uuidString
        self.imageFileName = imageFileName
        self.label = label
        self.createdAt = Date().timeIntervalSince1970
    }
}

