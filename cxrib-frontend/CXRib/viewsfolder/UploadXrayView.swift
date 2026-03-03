import SwiftUI
import UIKit
import PDFKit
import CoreData

@available(iOS 16.0, *)
struct UploadXrayView: View {

    // =====================================================
    // MARK: - NAVIGATION
    // =====================================================
    var goToExplanation: (_ side: String, _ confidence: Double) -> Void = { _, _ in }

    // =====================================================
    // MARK: - INPUTS
    // =====================================================
    var patientID: Int
    var patientName: String
    var patientAge: Int
    var patientGender: String
    var caseID: Int

    var goBack: () -> Void
    var goToHistory: () -> Void
    var goToDashboard: () -> Void

    // =====================================================
    // MARK: - STATE
    // =====================================================
    @State private var selectedImage: UIImage?
    @State private var showCamera = false
    @State private var showGallery = false
    @State private var isLoading = false
    @State private var errorText = ""

    @State private var predictionLabel = ""
    @State private var predictionConfidence: Double = 0
    @State private var showResult = false
    @State private var analysisDone = false

    // =====================================================
    // MARK: - BODY
    // =====================================================
    var body: some View {
        ZStack {

            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.10, green: 0.12, blue: 0.40),
                    Color(red: 0.36, green: 0.22, blue: 0.55),
                    Color(red: 0.78, green: 0.36, blue: 0.60)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 25) {

                topBar
                imageCard
                buttons

                if showResult {
                    resultCard
                    explanationButton
                }

                if isLoading {
                    ProgressView("Analyzing...")
                        .tint(.white)
                }

                if !errorText.isEmpty {
                    Text(errorText)
                        .foregroundColor(.red)
                }

                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(sourceType: .camera) {
                handlePickedImage($0)
            }
        }
        .sheet(isPresented: $showGallery) {
            ImagePicker(sourceType: .photoLibrary) {
                handlePickedImage($0)
            }
        }
    }

    // =====================================================
    // MARK: - IMAGE HANDLER
    // =====================================================
    private func handlePickedImage(_ image: UIImage) {
        if isValidXrayImage(image) {
            selectedImage = image
            errorText = ""
        } else {
            selectedImage = nil
            errorText = "❌ Only valid X-ray images are allowed"
        }
    }

    // =====================================================
    // MARK: - X-RAY VALIDATION
    // =====================================================
    private func isValidXrayImage(_ image: UIImage) -> Bool {

        guard let cg = image.cgImage else { return false }
        if cg.width < 200 || cg.height < 200 { return false }

        let bytesPerRow = cg.width * 4
        var data = [UInt8](repeating: 0, count: cg.height * bytesPerRow)

        guard let ctx = CGContext(
            data: &data,
            width: cg.width,
            height: cg.height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return false }

        ctx.draw(cg, in: CGRect(x: 0, y: 0, width: cg.width, height: cg.height))

        var colorPixels = 0
        for i in stride(from: 0, to: data.count, by: 4) {
            if abs(Int(data[i]) - Int(data[i+1])) > 30 ||
               abs(Int(data[i+1]) - Int(data[i+2])) > 30 {
                colorPixels += 1
            }
        }

        return Double(colorPixels) / Double(cg.width * cg.height) < 0.08
    }

    // =====================================================
    // MARK: - UI
    // =====================================================
    private var topBar: some View {
        HStack {

            Button {
                goBack()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))

                    Text("Back")
                        .font(.system(size: 17))
                }
                .foregroundColor(.white)
            }

            Spacer()

            Text("Upload X-Ray")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)

            Spacer()
        }
        .padding(.top, 12)
    }

    private var imageCard: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white.opacity(0.15))
            .overlay {
                if let img = selectedImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                } else {
                    Text("No Image Selected")
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .frame(height: 260)
    }

    private var buttons: some View {
        VStack(spacing: 12) {

            if !analysisDone {

                HStack {
                    Button("Gallery") { showGallery = true }
                        .buttonStyle(ActionButtonStyle())
                    Button("Camera") { showCamera = true }
                        .buttonStyle(ActionButtonStyle())
                }

                Button("Analyze & Save") {
                    analyzeAndSave()
                }
                .buttonStyle(ActionButtonStyle(primary: true))
                .disabled(selectedImage == nil || isLoading)

            } else {

                Button("Download Report (PDF)") {
                    generatePDFReport()
                }
                .buttonStyle(ActionButtonStyle(primary: true))

                Button("Scan Again") {
                    scanAgain()
                }
                .buttonStyle(ActionButtonStyle())

                Button("View History") {
                    goToHistory()
                }
                .buttonStyle(ActionButtonStyle())
            }
        }
    }

    // =====================================================
    // MARK: - RESULT CARD
    // =====================================================
    private var resultCard: some View {
        VStack(spacing: 16) {

            Text("Diagnostic Result")
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))

            Text(predictionLabel)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.yellow)

            Text("Confidence: \(String(format: "%.1f%%", predictionConfidence * 100))")
                .foregroundColor(.white)

            Text("Verify clinically before final decision")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.white.opacity(0.2))
                )
        )
    }

    private var explanationButton: some View {
        Button {
            goToExplanation(predictionLabel, predictionConfidence)
        } label: {
            Text("View Detailed Explanation")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(14)
        }
    }

    // =====================================================
    // MARK: - ANALYSIS + SAVE (FIXED)
    // =====================================================
    private func analyzeAndSave() {
        guard let image = selectedImage else { return }

        isLoading = true
        errorText = ""

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let predictor = try TFLitePredictor()
                let (label, confidence, _) = try predictor.predict(uiImage: image)

                DispatchQueue.main.async {
                    predictionLabel = label
                    predictionConfidence = confidence
                    showResult = true
                    analysisDone = true
                    isLoading = false

                    // ✅ SAVE LOCALLY (OFFLINE HISTORY)
                    saveToHistory(
                        image: image,
                        label: label,
                        confidence: confidence
                    )

                    // 🔍 CHECK IF PATIENT IS SYNCED
                    let ctx = CoreDataManager.shared.context
                    let request: NSFetchRequest<Patient> = Patient.fetchRequest()
                    request.predicate = NSPredicate(format: "id == %d", patientID)

                    if let patient = try? ctx.fetch(request).first, patient.serverPatientID > 0 {
                        
                        // ✅ SYNCED: Upload with SERVER ID
                        APIClient.shared.uploadAndSaveScan(
                            patientID: Int(patient.serverPatientID),
                            label: label,
                            confidence: confidence,
                            image: image
                        ) { serverScanID in

                            DispatchQueue.main.async {
                                if let scanID = serverScanID {
                                    print("✅ Scan saved to SERVER with ID:", scanID)
                                    linkLastLocalScanToServer(scanID)
                                } else {
                                    print("❌ Failed to save scan to SERVER")
                                }
                                
                                // ✅ refresh
                                NotificationCenter.default.post(
                                    name: .refreshHistory,
                                    object: nil
                                )
                            }
                        }
                    } else {
                         print("⚠️ Patient not synced yet. Scan saved locally only. SyncManager will handle upload.")
                         // Still refresh UI
                         NotificationCenter.default.post(
                             name: .refreshHistory,
                             object: nil
                         )
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    errorText = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }

    private func scanAgain() {
        selectedImage = nil
        predictionLabel = ""
        predictionConfidence = 0
        showResult = false
        analysisDone = false
        errorText = ""
    }

    // =====================================================
    // MARK: - CORE DATA SAVE
    // =====================================================
    private func saveToHistory(
        image: UIImage,
        label: String,
        confidence: Double
    ) {

        let uid = SessionManager.shared.userID
        guard uid > 0 else {
            print("❌ History NOT saved: userID = 0")
            return
        }

        let ctx = CoreDataManager.shared.context
        let item = ScanHistory(context: ctx)

        let filename = "scan_\(UUID().uuidString).jpg"
        let path = CoreDataManager.shared.buildLocalImagePath(filename: filename)

        try? image.jpegData(compressionQuality: 0.9)?
            .write(to: URL(fileURLWithPath: path))

        item.id = Int64(Date().timeIntervalSince1970)
        item.userID = Int64(uid)                 // ✅ REQUIRED
        item.patientName = patientName
        item.patientAge = Int16(patientAge)
        item.patientGender = patientGender
        item.caseID = Int64(caseID)
        item.predictedClass = label
        item.confidence = confidence
        item.imageFileName = filename
        item.createdAt = Date()

        // 🔹 IMPORTANT FOR SYNC
        item.serverScanID = 0                    // ⬅️ MARK AS PENDING
        item.serverPatientID = Int64(patientID) // ⬅️ LINK PATIENT

        CoreDataManager.shared.save()
        print("✅ Scan saved to LOCAL history")
    }
    
    private func linkLastLocalScanToServer(_ serverID: Int) {

        let ctx = CoreDataManager.shared.context
        let request: NSFetchRequest<ScanHistory> = ScanHistory.fetchRequest()

        // ✅ Link only the pending scan for this patient
        request.predicate = NSPredicate(
            format: "serverScanID == 0 AND serverPatientID == %d",
            patientID
        )

        request.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]
        request.fetchLimit = 1

        do {
            if let scan = try ctx.fetch(request).first {
                scan.serverScanID = Int64(serverID)
                CoreDataManager.shared.save()
                print("🔗 Linked pending scan with server ID:", serverID)
            }
        } catch {
            print("❌ Failed linking scan:", error.localizedDescription)
        }
    }

    // =====================================================
    // MARK: - PDF
    // =====================================================
    private func generatePDFReport() {

        guard let image = selectedImage else { return }

        let pdfURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("CXRib_Report_\(UUID().uuidString).pdf")

        let renderer = UIGraphicsPDFRenderer(
            bounds: CGRect(x: 0, y: 0, width: 595, height: 842)
        )

        try? renderer.writePDF(to: pdfURL) { ctx in
            ctx.beginPage()
            drawPDFText()
            image.draw(in: CGRect(x: 100, y: 300, width: 400, height: 400))
        }

        UIApplication.shared.windows.first?.rootViewController?
            .present(
                UIActivityViewController(
                    activityItems: [pdfURL],
                    applicationActivities: nil
                ),
                animated: true
            )
    }

    private func drawPDFText() {

        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 20)
        ]

        let bodyAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14)
        ]

        "CXRib MEDICAL REPORT"
            .draw(at: CGPoint(x: 160, y: 30), withAttributes: titleAttrs)

        let text = """
        Patient Name : \(patientName)
        Age          : \(patientAge)
        Gender       : \(patientGender)
        Case ID      : \(caseID)

        Diagnosis    : \(predictionLabel)
        Confidence   : \(String(format: "%.2f%%", predictionConfidence * 100))
        """

        text.draw(
            in: CGRect(x: 40, y: 80, width: 520, height: 200),
            withAttributes: bodyAttrs
        )
    }
}

// =====================================================
// MARK: - IMAGE PICKER
// =====================================================
struct ImagePicker: UIViewControllerRepresentable {

    let sourceType: UIImagePickerController.SourceType
    let onPicked: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: Context
    ) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPicked: onPicked)
    }

    final class Coordinator: NSObject,
        UINavigationControllerDelegate,
        UIImagePickerControllerDelegate {

        let onPicked: (UIImage) -> Void

        init(onPicked: @escaping (UIImage) -> Void) {
            self.onPicked = onPicked
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            if let img = info[.originalImage] as? UIImage {
                onPicked(img)
            }
            picker.dismiss(animated: true)
        }
    }
}

// =====================================================
// MARK: - ACTION BUTTON STYLE
// =====================================================
struct ActionButtonStyle: ButtonStyle {

    var primary: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(primary ? Color.yellow : Color.white.opacity(0.25))
            .foregroundColor(primary ? .black : .white)
            .cornerRadius(14)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
    }
}
