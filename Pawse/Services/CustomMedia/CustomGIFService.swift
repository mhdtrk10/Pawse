//
//  CustomGIFService.swift
//  Pawse
//
//  Created by Mehdi Oturak on 8.05.2026.
//

import Foundation

final class CustomGIFService {
    private let fileManager = FileManager.default
    private let fileName = "custom_break_animation.gif"

    func saveGIFData(_ data: Data) -> String? {
        let url = documentsDirectory().appendingPathComponent(fileName)

        do {
            try data.write(to: url, options: .atomic)
            return fileName
        } catch {
            print("Failed to save custom GIF: \(error)")
            return nil
        }
    }

    func loadGIFURL(fileName: String?) -> URL? {
        guard let fileName else { return nil }

        let url = documentsDirectory().appendingPathComponent(fileName)
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        return url
    }

    func loadGIFData(fileName: String?) -> Data? {
        guard let url = loadGIFURL(fileName: fileName) else { return nil }
        return try? Data(contentsOf: url)
    }

    func deleteGIF(fileName: String?) {
        guard let fileName else { return }

        let url = documentsDirectory().appendingPathComponent(fileName)

        do {
            if fileManager.fileExists(atPath: url.path) {
                try fileManager.removeItem(at: url)
            }
        } catch {
            print("Failed to delete custom GIF: \(error)")
        }
    }

    private func documentsDirectory() -> URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
