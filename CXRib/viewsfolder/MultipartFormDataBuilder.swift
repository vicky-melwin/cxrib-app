import Foundation
import UIKit

final class MultipartFormDataBuilder {

    private let boundary: String
    private var body = Data()

    init(boundary: String) {
        self.boundary = boundary
    }

    // -------------------------------------------------
    // TEXT FIELD
    // -------------------------------------------------
    func addField(_ name: String, _ value: String) -> Self {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
        body.append("\(value)\r\n")
        return self
    }

    // -------------------------------------------------
    // IMAGE FIELD
    // -------------------------------------------------
    func addImageField(
        _ name: String,
        _ image: UIImage,
        filename: String = "scan.jpg"
    ) -> Self {

        guard let imageData = image.jpegData(compressionQuality: 0.9) else {
            return self
        }

        body.append("--\(boundary)\r\n")
        body.append(
            "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n"
        )
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")

        return self
    }

    // -------------------------------------------------
    // FINALIZE
    // -------------------------------------------------
    func build() -> Data {
        body.append("--\(boundary)--\r\n")
        return body
    }
}

// =====================================================
// MARK: - Data EXTENSION
// =====================================================
private extension Data {

    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

