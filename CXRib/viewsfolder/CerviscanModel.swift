// CerviscanModel.swift

import Foundation
import UIKit
import CoreImage
import CoreVideo
import TensorFlowLite

final class CerviscanModel {

    private var interpreter: Interpreter

    init?(_ modelName: String = "CERVISCAN_model") {

        guard let path = Bundle.main.path(forResource: modelName, ofType: "tflite") else {
            print("❌ Model not found:", modelName)
            return nil
        }

        do {
            interpreter = try Interpreter(modelPath: path, options: Interpreter.Options())
            try interpreter.allocateTensors()
        } catch {
            print("❌ Failed to load model:", error)
            return nil
        }
    }

    func predict(image: UIImage) -> [Float]? {

        let target = modelInputSize()

        guard let buffer = image.toCVPixelBuffer(targetSize: target) else {
            print("❌ Could not make pixel buffer")
            return nil
        }

        let inputData = buffer.normalizedData()

        do {
            try interpreter.copy(inputData, toInputAt: 0)
            try interpreter.invoke()

            let output = try interpreter.output(at: 0)
            let data = output.data

            guard let float32: [Float32] = data.toArray(type: Float32.self) else {
                print("❌ toArray nil")
                return nil
            }

            return float32.map { Float($0) }

        } catch {
            print("❌ Prediction error:", error)
            return nil
        }
    }

    func modelInputSize() -> CGSize {
        do {
            let input = try interpreter.input(at: 0)
            let dims = input.shape.dimensions
            if dims.count >= 3 {
                return CGSize(width: dims[2], height: dims[1])
            }
        } catch {}
        return CGSize(width: 150, height: 150)
    }
}

// MARK: - UIImage → CVPixelBuffer
private extension UIImage {
    func toCVPixelBuffer(targetSize: CGSize) -> CVPixelBuffer? {

        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!
        ] as CFDictionary

        var buffer: CVPixelBuffer?
        guard CVPixelBufferCreate(kCFAllocatorDefault,
                                  Int(targetSize.width),
                                  Int(targetSize.height),
                                  kCVPixelFormatType_32BGRA,
                                  attrs,
                                  &buffer) == kCVReturnSuccess,
              let pixelBuffer = buffer else { return nil }

        CVPixelBufferLockBaseAddress(pixelBuffer, [])

        guard let ctx = CGContext(
            data: CVPixelBufferGetBaseAddress(pixelBuffer),
            width: Int(targetSize.width),
            height: Int(targetSize.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        ) else {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
            return nil
        }

        ctx.clear(CGRect(origin: .zero, size: targetSize))
        ctx.translateBy(x: 0, y: targetSize.height)
        ctx.scaleBy(x: 1, y: -1)

        UIGraphicsPushContext(ctx)
        self.draw(in: CGRect(origin: .zero, size: targetSize))
        UIGraphicsPopContext()

        CVPixelBufferUnlockBaseAddress(pixelBuffer, [])

        return pixelBuffer
    }
}

// MARK: - CVPixelBuffer → RGB float32 data
private extension CVPixelBuffer {
    func normalizedData() -> Data {
        CVPixelBufferLockBaseAddress(self, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(self, .readOnly) }

        guard let base = CVPixelBufferGetBaseAddress(self) else { return Data() }

        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        let rowBytes = CVPixelBufferGetBytesPerRow(self)

        var data = Data(capacity: width * height * 3 * 4)

        for y in 0..<height {
            let row = base.advanced(by: y * rowBytes)
            for x in 0..<width {
                let pix = row.advanced(by: x * 4).assumingMemoryBound(to: UInt8.self)

                var r = Float32(pix[2]) / 255.0
                var g = Float32(pix[1]) / 255.0
                var b = Float32(pix[0]) / 255.0

                data.append(UnsafeBufferPointer(start: &r, count: 1))
                data.append(UnsafeBufferPointer(start: &g, count: 1))
                data.append(UnsafeBufferPointer(start: &b, count: 1))
            }
        }

        return data
    }
}
