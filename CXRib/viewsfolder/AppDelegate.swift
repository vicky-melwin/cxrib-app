import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        print("🚀 AppDelegate: Application Launched")

        // Enable background fetch
        application.setMinimumBackgroundFetchInterval(
            UIApplication.backgroundFetchIntervalMinimum
        )

        // Start network monitoring
        NetworkMonitor.shared.start()

        return true
    }

    // Background fetch handler
    func application(
        _ application: UIApplication,
        performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("🟢 Background Fetch → Sync Triggered")

        SyncManager.shared.syncAll()

        completionHandler(.newData)
    }
}

