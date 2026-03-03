import UIKit
import CoreImage

extension UIImage {

    func computeImageFeatures(sampleSize: CGSize = CGSize(width: 64, height: 64))
    -> (isMostlyGrayscale: Bool, luminanceStdDev: CGFloat, colorSaturation: CGFloat) {

        guard let cg = self.cgImage else {
            return (false, 0, 1)
        }

        let width = Int(sampleSize.width)
        let height = Int(sampleSize.height)
        let bytesPerPixel = 4
        let bytes = width * height * bytesPerPixel
        var raw = [UInt8](repeating: 0, count: bytes)

        guard let context = CGContext(
            data: &raw,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * bytesPerPixel,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return (false, 0, 1)
        }

        context.interpolationQuality = .low
        context.draw(cg, in: CGRect(x: 0, y: 0, width: width, height: height))

        var sumR = 0.0, sumG = 0.0, sumB = 0.0
        var sumL = 0.0, sumL2 = 0.0
        var sumSat = 0.0

        for y in 0..<height {
            for x in 0..<width {
                let i = (y * width + x) * bytesPerPixel
                let r = Double(raw[i])
                let g = Double(raw[i+1])
                let b = Double(raw[i+2])

                let lum = 0.299*r + 0.587*g + 0.114*b
                sumR += r; sumG += g; sumB += b
                sumL += lum; sumL2 += lum * lum

                let rf = r/255, gf = g/255, bf = b/255
                let maxv = max(rf, gf, bf)
                let minv = min(rf, gf, bf)
                let delta = maxv - minv
                let sat = maxv == 0 ? 0 : delta / maxv
                sumSat += sat
            }
        }

        let n = Double(width * height)
        let meanR = sumR / n
        let meanG = sumG / n
        let meanB = sumB / n
        let meanL = sumL / n
        let meanSat = sumSat / n

        let avgChannelDiff = (abs(meanR - meanG)
                              + abs(meanG - meanB)
                              + abs(meanR - meanB)) / 3.0
        let stdL = sqrt(max(0, (sumL2/n) - (meanL * meanL)))

        let isGrayscale = avgChannelDiff < 12.0

        return (isGrayscale, CGFloat(stdL), CGFloat(meanSat))
    }
}

