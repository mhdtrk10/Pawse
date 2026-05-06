//
//  CustomPhotoService.swift
//  Pawse
//
//  Created by Mehdi Oturak on 5.05.2026.
//

import UIKit

final class CustomPhotoService {
    private let fileManager = FileManager.default
    private let fileName = "custom_break_photo.jpg"

    func saveImage(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.9) else { return nil }

        let url = documentsDirectory().appendingPathComponent(fileName)

        do {
            try data.write(to: url, options: .atomic)
            return fileName
        } catch {
            print("Failed to save custom photo: \(error)")
            return nil
        }
    }

    func loadImage(fileName: String?) -> UIImage? {
        guard let fileName else { return nil }

        let url = documentsDirectory().appendingPathComponent(fileName)
        return UIImage(contentsOfFile: url.path)
    }

    func deleteImage(fileName: String?) {
        guard let fileName else { return }

        let url = documentsDirectory().appendingPathComponent(fileName)

        do {
            if fileManager.fileExists(atPath: url.path) {
                try fileManager.removeItem(at: url)
            }
        } catch {
            print("Failed to delete custom photo: \(error)")
        }
    }

    private func documentsDirectory() -> URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
