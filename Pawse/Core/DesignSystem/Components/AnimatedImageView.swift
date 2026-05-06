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
    let fileName: String
    var contentMode: UIView.ContentMode = .scaleAspectFill
    var cornerRadius: CGFloat = 0

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

        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil),
              let data = try? Data(contentsOf: url),
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
