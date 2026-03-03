import Network

final class NetworkMonitor {

    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")

    private(set) var isConnected = false
    private init() {}

    func start() {
        print("🌐 NetworkMonitor started at app launch")

        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {

                let wasConnected = self.isConnected
                self.isConnected = (path.status == .satisfied)

                print("🌐 Network:", self.isConnected ? "ONLINE" : "OFFLINE")

                if self.isConnected && !wasConnected {
                    print("🔄 Internet restored → waiting 3s to sync...")
                    
                    // DELAY: Give connection time to stabilize
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        print("🚀 Triggering delayed sync...")
                        SyncManager.shared.syncAll()
                    }
                }
            }
        }

        monitor.start(queue: queue)
    }
}

