//
//  FLConfig.swift
//  CerviScan
//
//  Global configuration for Federated Learning
//

import Foundation

struct FLConfig {

    // ---------------------------------------------------------
    // MARK: - Server Base URL
    // ---------------------------------------------------------
    // Adjust based on your LAN IP or simulator use

    #if targetEnvironment(simulator)
    static let serverBaseURL = "http://127.0.0.1:8000/fl"
    #else
    static let serverBaseURL = "http://10.61.91.98:8000/fl"
    #endif



    // ---------------------------------------------------------
    // MARK: - Training Settings
    // ---------------------------------------------------------

    /// Maximum number of samples used for each local FL update
    static let maxLocalSamples = 20

    /// Fake update size (replaced with real gradients later)
    static let fakeGradientSize = 256



    // ---------------------------------------------------------
    // MARK: - Sync Scheduling
    // ---------------------------------------------------------

    /// First sync starts after app launch
    static let initialSyncDelay: TimeInterval = 10

    /// Time between sync attempts if update is successful
    static let nextSyncDelay: TimeInterval = 60

    /// Delay if no local samples were found
    static let noSampleDelay: TimeInterval = 20



    // ---------------------------------------------------------
    // MARK: - Logging
    // ---------------------------------------------------------

    static let enableDebugLogs = true
}

