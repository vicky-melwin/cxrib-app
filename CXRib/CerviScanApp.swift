import SwiftUI
import UIKit

@main
struct CerviScanApp: App {

    // ✅ Hook UIKit AppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate

    // ✅ App-level init (runs ONCE)
    init() {
        NetworkMonitor.shared.start()
        print("🌐 NetworkMonitor started at app launch")
    }

    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // ✅ Enable background fetch safely
                    UIApplication.shared.setMinimumBackgroundFetchInterval(
                        UIApplication.backgroundFetchIntervalMinimum
                    )
                }
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        print("🚀 App active: Triggering immediate sync check")
                        if NetworkMonitor.shared.isConnected {
                            SyncManager.shared.syncAll()
                        }
                    }
                }
        }
    }
}

