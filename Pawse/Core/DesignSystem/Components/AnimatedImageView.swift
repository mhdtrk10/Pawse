//
//  AnimatedImageView.swift
//  Pawse
//
//  Created by Mehdi Oturak on 6.05.2026.
//

import SwiftUI
import UIKit
import ImageIO

struct AnimatedImageView: UIViewRepresentable {
    let fileName: String?
    let fileURL: URL?

    var contentMode: UIView.ContentMode = .scaleAspectFill
    var cornerRadius: CGFloat = 0
    var internalScale: CGFloat = 1.0

    init(
        fileName: String,
        contentMode: UIView.ContentMode = .scaleAspectFill,
        cornerRadius: CGFloat = 0,
        internalScale: CGFloat = 1.0
    ) {
        self.fileName = fileName
        self.fileURL = nil
        self.contentMode = contentMode
        self.cornerRadius = cornerRadius
        self.internalScale = internalScale
    }

    init(
        fileURL: URL,
        contentMode: UIView.ContentMode = .scaleAspectFill,
        cornerRadius: CGFloat = 0,
        internalScale: CGFloat = 1.0
    ) {
        self.fileName = nil
        self.fileURL = fileURL
        self.contentMode = contentMode
        self.cornerRadius = cornerRadius
        self.internalScale = internalScale
    }

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = contentMode
        imageView.layer.cornerRadius = cornerRadius
        return imageView
    }

    func updateUIView(_ imageView: UIImageView, context: Context) {
        imageView.contentMode = contentMode
        imageView.layer.cornerRadius = cornerRadius
        imageView.clipsToBounds = true
        imageView.transform = CGAffineTransform(scaleX: internalScale, y: internalScale)

        let data: Data?

        if let fileURL {
            data = try? Data(contentsOf: fileURL)
        } else if let fileName,
                  let url = Bundle.main.url(forResource: fileName, withExtension: nil) {
            data = try? Data(contentsOf: url)
        } else {
            data = nil
        }

        guard let data,
              let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return
        }

        let frameCount = CGImageSourceGetCount(source)
        var images: [UIImage] = []
        var totalDuration: Double = 0

        for index in 0..<frameCount {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) else { continue }

            let frameDuration = Self.frameDuration(at: index, source: source)
            totalDuration += frameDuration
            images.append(UIImage(cgImage: cgImage))
        }

        guard !images.isEmpty else { return }

        imageView.stopAnimating()
        imageView.image = images.first
        imageView.animationImages = images
        imageView.animationDuration = max(totalDuration, 0.1)
        imageView.animationRepeatCount = 0
        imageView.startAnimating()
    }

    static func frameDuration(at index: Int, source: CGImageSource) -> Double {
        let defaultFrameDuration = 0.1

        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
              let gifInfo = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any] else {
            return defaultFrameDuration
        }

        if let unclampedDelay = gifInfo[kCGImagePropertyGIFUnclampedDelayTime] as? Double,
           unclampedDelay > 0 {
            return unclampedDelay
        }

        if let delay = gifInfo[kCGImagePropertyGIFDelayTime] as? Double,
           delay > 0 {
            return delay
        }

        return defaultFrameDuration
    }
}
