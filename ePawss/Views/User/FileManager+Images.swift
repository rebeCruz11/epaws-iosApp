//
//  FileManager+Images.swift
//  ePaw
//
//  Created by ESTUDIANTE on 7/11/25.
//

import UIKit

extension FileManager {
    static func saveImage(_ image: UIImage, withName name: String) -> URL? {
        guard let data = image.jpegData(compressionQuality: 0.9) else { return nil }
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = url.appendingPathComponent("\(name).jpg")
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("No se pudo guardar la imagen:", error)
            return nil
        }
    }
}
