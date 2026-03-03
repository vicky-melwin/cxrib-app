import UIKit
import TensorFlowLite

// =====================================================
// MARK: - TFLitePredictor (COLAB-ALIGNED • FINAL • SAFE)
// =====================================================

final class TFLitePredictor {

    private let inputSize = 224
    private let labels = ["left", "right", "bicrib", "normal"]
    private let interpreter: Interpreter

    // -------------------------------------------------
    // INIT
    // -------------------------------------------------
    init() throws {

        guard let modelPath = Bundle.main.path(
            forResource: "CERVISCAN_model_FINAL (2)",
            ofType: "tflite"
        ) else {
            throw NSError(
                domain: "Model",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "TFLite model not found"]
            )
        }

        var options = Interpreter.Options()
        options.threadCount = 1   // deterministic

        interpreter = try Interpreter(modelPath: modelPath, options: options)
        try interpreter.allocateTensors()

        let input = try interpreter.input(at: 0)
        let output = try interpreter.output(at: 0)

        print("📥 Input :", input.shape, input.dataType)
        print("📤 Output:", output.shape, output.dataType)
    }

    // -------------------------------------------------
    // PREDICT
    // -------------------------------------------------
    func predict(
        uiImage: UIImage
    ) throws -> (label: String, confidence: Double, vector: [Float]) {

        let fixed = uiImage.normalizedOrientation()
        let resized = fixed.resizedForTFLite(
            CGSize(width: inputSize, height: inputSize)
        )

        let inputData = try imageToTensor(resized)

        try interpreter.copy(inputData, toInputAt: 0)
        try interpreter.invoke()

        let outputTensor = try interpreter.output(at: 0)

        guard let vector = outputTensor.data.toArray(type: Float.self) else {
            throw NSError(domain: "Output", code: -20)
        }

        let idx = vector.argmax()
        let label = labels[idx]

        // ✅ MODEL OUTPUT IS ALREADY SOFTMAX
        let confidence = Double(vector[idx])   // 0.0 – 1.0

        print("🧠 Probability Vector:", vector)
        print("🩻 Prediction :", label)
        print("📊 Confidence :", confidence * 100, "%")

        return (label, confidence, vector)
    }

    // -------------------------------------------------
    // PREPROCESS (🔥 EXACT MATCH WITH COLAB)
    // -------------------------------------------------
    private func imageToTensor(_ image: UIImage) throws -> Data {

        guard let cgImage = image.cgImage else {
            throw NSError(domain: "Image", code: -10)
        }

        let width = inputSize
        let height = inputSize

        var rgbData = [UInt8](repeating: 0, count: width * height * 4)

        guard let context = CGContext(
            data: &rgbData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ) else {
            throw NSError(domain: "CGContext", code: -11)
        }

        context.interpolationQuality = .high
        context.draw(
            cgImage,
            in: CGRect(x: 0, y: 0, width: width, height: height)
        )

        var floats = [Float]()
        floats.reserveCapacity(width * height * 3)

        for i in stride(from: 0, to: rgbData.count, by: 4) {
            floats.append((Float(rgbData[i])     - 127.5) / 127.5) // R
            floats.append((Float(rgbData[i + 1]) - 127.5) / 127.5) // G
            floats.append((Float(rgbData[i + 2]) - 127.5) / 127.5) // B
        }

        return Data(
            buffer: UnsafeBufferPointer(start: floats, count: floats.count)
        )
    }
}

// =====================================================
// MARK: - UIImage helpers
// =====================================================

private extension UIImage {

    func normalizedOrientation() -> UIImage {
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return img
    }

    func resizedForTFLite(_ size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.interpolationQuality = .high
        draw(in: CGRect(origin: .zero, size: size))
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return img
    }
}

// =====================================================
// MARK: - Helpers
// =====================================================

private extension Array where Element == Float {
    func argmax() -> Int {
        indices.max(by: { self[$0] < self[$1] })!
    }
}

