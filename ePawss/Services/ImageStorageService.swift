//
//  ImageStorageService.swift
//  ePaw
//
//  Created by ESTUDIANTE on 07/11/25.
//

import Foundation
import UIKit

class ImageStorageService {
    static let shared = ImageStorageService()
    
    private let fileManager = FileManager.default
    private var imagesDirectory: URL {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let imagesDir = documentsDirectory.appendingPathComponent("ReportImages")
        
        // Crear directorio si no existe
        if !fileManager.fileExists(atPath: imagesDir.path) {
            try? fileManager.createDirectory(at: imagesDir, withIntermediateDirectories: true)
        }
        
        return imagesDir
    }
    
    /// Guarda imágenes localmente y devuelve los nombres de archivo
    func saveImages(_ images: [UIImage]) -> [String] {
        var filenames: [String] = []
        
        for (index, image) in images.enumerated() {
            let filename = "\(UUID().uuidString).jpg"
            let fileURL = imagesDirectory.appendingPathComponent(filename)
            
            if let imageData = image.jpegData(compressionQuality: 0.7) {
                do {
                    try imageData.write(to: fileURL)
                    filenames.append(filename)
                    print("✅ Imagen \(index + 1) guardada: \(filename)")
                } catch {
                    print("❌ Error guardando imagen \(index + 1): \(error)")
                }
            }
        }
        
        return filenames
    }
    
    /// Carga una imagen desde el almacenamiento local
    func loadImage(filename: String) -> UIImage? {
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        
        if fileManager.fileExists(atPath: fileURL.path),
           let imageData = try? Data(contentsOf: fileURL) {
            return UIImage(data: imageData)
        }
        
        return nil
    }
    
    /// Elimina una imagen
    func deleteImage(filename: String) {
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        try? fileManager.removeItem(at: fileURL)
    }
    
    /// Lista todas las imágenes guardadas (para debug)
    func listAllImages() -> [String] {
        let contents = try? fileManager.contentsOfDirectory(atPath: imagesDirectory.path)
        return contents ?? []
    }
}
