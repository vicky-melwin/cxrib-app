import SwiftUI
import CoreData

// =====================================================
// MARK: - Notification Name
// =====================================================
extension Notification.Name {
    static let refreshHistory =
        Notification.Name("REFRESH_HISTORY")
}

@available(iOS 16.0, *)
struct HistoryView: View {
    
    var goBack: (() -> Void)?
    
    @State private var history: [ScanHistory] = []
    
    @State private var fullscreenUIImage: UIImage?
    @State private var fullscreenURL: URL?
    @State private var showFullscreen = false
    
    // ✅ DELETE CONFIRMATION STATES
    @State private var showDeleteConfirm = false
    @State private var itemToDelete: ScanHistory?
    
    // 🔹 Animation state
    @State private var appear = false
    
    var body: some View {
        ZStack {
            background
            
            VStack {
                topBar
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : -20)
                    .animation(.easeOut(duration: 0.5), value: appear)
                
                content
            }
            .padding(.top, 25)   // 🔽 reduced from 50
        }
        .onAppear {
            appear = true
            loadHistory()
        }
        
        .onReceive(NotificationCenter.default.publisher(for: .refreshHistory)) { _ in
            loadHistory()
        }
        .fullScreenCover(isPresented: $showFullscreen) {
            FullscreenImageViewer(
                imageURL: fullscreenURL,
                image: fullscreenUIImage
            ) {
                fullscreenURL = nil
                fullscreenUIImage = nil
                showFullscreen = false
            }
        }
        // ✅ CONFIRM DELETE ALERT
        .alert("Confirm Delete", isPresented: $showDeleteConfirm) {

            // 🔴 DELETE BUTTON
            Button("Delete", role: .destructive) {

                guard let item = itemToDelete else { return }

                let serverID = Int(item.serverScanID)

                if serverID > 0 {
                    APIClient.shared.deleteScan(serverScanID: serverID) { success in
                        DispatchQueue.main.async {
                            if success {
                                CoreDataManager.shared.context.delete(item)
                                CoreDataManager.shared.save()
                                loadHistory()
                            }
                        }
                    }
                } else {
                    CoreDataManager.shared.context.delete(item)
                    CoreDataManager.shared.save()
                    loadHistory()
                }
            }

            // ⚪ CANCEL BUTTON (must be separate)
            Button("Cancel", role: .cancel) {
                itemToDelete = nil
            }

        } message: {
            Text("Are you sure you want to delete this scan?")
        }
    }

    // =====================================================
    // MARK: - Background
    // =====================================================
    private var background: some View {
        LinearGradient(
            colors: [
                Color(red: 0.10, green: 0.12, blue: 0.40),
                Color(red: 0.40, green: 0.22, blue: 0.55),
                Color(red: 0.78, green: 0.36, blue: 0.60)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    // =====================================================
    // MARK: - Top Bar
    // =====================================================
    private var topBar: some View {
        HStack {
            IOSBackButton(title: "Back") {
                goBack?()
            }

            Spacer()

            Text("Scan History")
                .font(.title.bold())
                .foregroundColor(.white)

            Spacer()

            Button(action: syncWithServerThenLoad) {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }

        }
        .padding(.horizontal)
        .padding(.top, 6)   // 🔽 explicitly control top spacing
    }

    // =====================================================
    // MARK: - Content
    // =====================================================
    private var content: some View {
        Group {
            if history.isEmpty {
                Spacer()
                Text("No scan history found")
                    .foregroundColor(.white.opacity(0.8))
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                    .animation(.easeOut(duration: 0.4), value: appear)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(Array(history.enumerated()), id: \.element) { index, scan in
                            historyCard(scan)
                                .opacity(appear ? 1 : 0)
                                .offset(y: appear ? 0 : 30)
                                .animation(
                                    .easeOut(duration: 0.45)
                                        .delay(Double(index) * 0.08),
                                    value: appear
                                )
                        }
                    }
                    .padding()
                }
            }
        }
    }

    // =====================================================
    // MARK: - History Card
    // =====================================================
    private func historyCard(_ item: ScanHistory) -> some View {

        let filename = item.imageFileName ?? ""

        let localPath =
            CoreDataManager.shared.buildLocalImagePath(
                filename: filename
            )

        let localImage = UIImage(contentsOfFile: localPath)

        let remoteURL: URL? = {
            guard !filename.isEmpty else { return nil }
            return URL(string: AppConfig.fullImageURL(filename))
        }()

        return HStack(alignment: .top, spacing: 14) {

            // IMAGE
            Group {
                if let img = localImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .onTapGesture {
                            fullscreenUIImage = img
                            showFullscreen = true
                        }
                } else if let url = remoteURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()

                        case .empty:
                            ProgressView()

                        default:
                            imageMissing
                        }
                    }
                } else {
                    imageMissing
                }
            }
            .frame(width: 90, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // DETAILS
            VStack(alignment: .leading, spacing: 6) {

                Text(item.patientName ?? "-")
                    .font(.headline)
                    .foregroundColor(.white)

                Text(
                    "Age: \(item.patientAge) • \(item.patientGender ?? "-")"
                )
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))

                Text("Case ID: \(item.caseID)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))

                Divider().background(Color.white.opacity(0.4))

                Text(
                    "Prediction: \(item.predictedClass?.capitalized ?? "-")"
                )
                .foregroundColor(.yellow)

                Text(
                    "Confidence: \(String(format: "%.1f%%", item.confidence * 100))"
                )
                .foregroundColor(.green)

                Text(item.dateString ?? "")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            // ✅ DELETE WITH CONFIRM
            Button {
                itemToDelete = item
                showDeleteConfirm = true
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.white.opacity(0.08))
        .cornerRadius(18)
    }

    private var imageMissing: some View {
        Rectangle()
            .fill(Color.white.opacity(0.15))
            .overlay(
                Text("No Image")
                    .foregroundColor(.white.opacity(0.7))
            )
    }

    // =====================================================
    // MARK: - SERVER → LOCAL SYNC + LOAD
    // =====================================================
    private func syncWithServerThenLoad() {

        let uid = SessionManager.shared.userID
        guard uid > 0 else {
            loadHistoryFromCoreData()
            return
        }

        APIClient.shared.fetchScanHistory(userId: uid) { result in
            DispatchQueue.main.async {

                switch result {

                case .success(let serverScans):

                    // 🚨 VERY IMPORTANT
                    // 🚨 REMOVED GUARD to allow deleting all scans
                    // if serverScans.isEmpty { ... }


                    // ✅ ROBUST SYNC: Upsert + Delete
                     CoreDataManager.shared.syncScanHistory(
                         from: serverScans,
                         forUserID: uid
                     )
                     
                     self.loadHistory()

                case .failure:
                    print("❌ Server failed – using local DB")
                    self.loadHistoryFromCoreData()
                }
            }
        }
    }
    
    // =====================================================
    // MARK: - LOAD LOCAL HISTORY
    // =====================================================
    private func loadHistory() {

        let uid = SessionManager.shared.userID

        guard uid > 0 else {
            history = []
            print("❌ History not loaded: userID = 0")
            return
        }

        let request: NSFetchRequest<ScanHistory> = ScanHistory.fetchRequest()
        request.predicate = NSPredicate(format: "userID == %d", uid)
        request.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]

        do {
            history = try CoreDataManager.shared.context.fetch(request)
            print("📜 History loaded from CoreData:", history.count)
        } catch {
            print("❌ History fetch failed:", error.localizedDescription)
            history = []
        }
    }

    // =====================================================
    // MARK: - OFFLINE FALLBACK
    // =====================================================
    private func loadHistoryFromCoreData() {

        let uid = SessionManager.shared.userID

        let request: NSFetchRequest<ScanHistory> = ScanHistory.fetchRequest()
        request.predicate = NSPredicate(format: "userID == %d", uid)
        request.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]

        history = (try? CoreDataManager.shared.context.fetch(request)) ?? []
        print("📦 History loaded from CoreData:", history.count)
    }

    // =====================================================
    // MARK: - Fullscreen Image Viewer
    // =====================================================
    struct FullscreenImageViewer: View {

        let imageURL: URL?
        let image: UIImage?
        var dismiss: () -> Void

        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()

                if let img = image {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                } else if let url = imageURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().scaledToFit()
                        case .empty:
                            ProgressView().tint(.white)
                        default:
                            Text("Failed to load image")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .onTapGesture { dismiss() }
        }
    }
}

// ======================================================
// MARK: - LOCAL IMAGE PATH
// ======================================================

extension CoreDataManager {

    func localImagesFolder() -> URL {

        let folder = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("XrayImages")

        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(
                at: folder,
                withIntermediateDirectories: true
            )
        }
        return folder
    }

    func buildLocalImagePath(filename: String) -> String {
        localImagesFolder()
            .appendingPathComponent(filename)
            .path
    }
}