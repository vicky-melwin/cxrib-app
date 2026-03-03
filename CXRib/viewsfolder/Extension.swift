import UIKit
import Foundation

// MARK: - UIImage Global Helpers
extension UIImage {

    func resized(to newSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    func rgbData224() -> Data? {
        guard let cg = self.cgImage else { return nil }

        let width = 224, height = 224
        let bytesPerRow = width * 4

        var raw = [UInt8](repeating: 0, count: bytesPerRow * height)

        guard let ctx = CGContext(
            data: &raw,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        ctx.draw(cg, in: CGRect(x: 0, y: 0, width: width, height: height))

        var floats: [Float] = []
        floats.reserveCapacity(width * height * 3)

        for i in stride(from: 0, to: raw.count, by: 4) {
            floats.append(Float(raw[i]) / 255)
            floats.append(Float(raw[i + 1]) / 255)
            floats.append(Float(raw[i + 2]) / 255)
        }

        return Data(
            buffer: UnsafeBufferPointer(start: floats, count: floats.count)
        )
    }
}

// MARK: - Data → Typed Array
extension Data {

    func toArray<T>(type: T.Type) -> [T]? {
        guard self.count % MemoryLayout<T>.stride == 0 else { return nil }

        return self.withUnsafeBytes {
            Array($0.bindMemory(to: T.self))
        }
    }
}

// MARK: - App Notifications
extension Notification.Name {
    static let navigateToHistory = Notification.Name("navigateToHistory")
}

