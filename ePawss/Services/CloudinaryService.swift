//
//  CloudinaryService.swift
//  ePaw
//

import Foundation
import UIKit

class CloudinaryService {
    static let shared = CloudinaryService()
    
    // ⚠️ IMPORTANTE: Configura estos valores con tus credenciales de Cloudinary
    // Puedes obtenerlos en: https://console.cloudinary.com/
    private let cloudName = "dnux3wmic"  // Reemplaza con tu cloud name
    private let uploadPreset = "epaws_preset"  // Reemplaza con tu upload preset (unsigned)
    
    private init() {}
    
    /// Sube una imagen a Cloudinary y devuelve la URL pública
    func uploadImage(_ image: UIImage, folder: String = "epaws") async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw CloudinaryError.invalidImage
        }
        
        let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Upload preset
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(uploadPreset)\r\n".data(using: .utf8)!)
        
        // Folder
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"folder\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(folder)\r\n".data(using: .utf8)!)
        
        // Image file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        print("🔵 [Cloudinary] Subiendo imagen...")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CloudinaryError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ [Cloudinary] Error: Status \(httpResponse.statusCode)")
            if let errorString = String(data: data, encoding: .utf8) {
                print("Response: \(errorString)")
            }
            throw CloudinaryError.uploadFailed(statusCode: httpResponse.statusCode)
        }
        
        let cloudinaryResponse = try JSONDecoder().decode(CloudinaryUploadResponse.self, from: data)
        
        print("🟢 [Cloudinary] Imagen subida: \(cloudinaryResponse.secureUrl)")
        
        return cloudinaryResponse.secureUrl
    }
    
    /// Sube múltiples imágenes a Cloudinary
    func uploadImages(_ images: [UIImage], folder: String = "epaws") async throws -> [String] {
        var urls: [String] = []
        
        for (index, image) in images.enumerated() {
            do {
                let url = try await uploadImage(image, folder: folder)
                urls.append(url)
                print("✅ Imagen \(index + 1)/\(images.count) subida")
            } catch {
                print("❌ Error subiendo imagen \(index + 1): \(error)")
                throw error
            }
        }
        
        return urls
    }
}

// MARK: - Cloudinary Response Model
struct CloudinaryUploadResponse: Codable {
    let publicId: String
    let version: Int
    let signature: String
    let width: Int
    let height: Int
    let format: String
    let resourceType: String
    let createdAt: String
    let bytes: Int
    let type: String
    let url: String
    let secureUrl: String
    
    enum CodingKeys: String, CodingKey {
        case publicId = "public_id"
        case version, signature, width, height, format
        case resourceType = "resource_type"
        case createdAt = "created_at"
        case bytes, type, url
        case secureUrl = "secure_url"
    }
}

// MARK: - Cloudinary Errors
enum CloudinaryError: LocalizedError {
    case invalidImage
    case invalidResponse
    case uploadFailed(statusCode: Int)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "No se pudo procesar la imagen"
        case .invalidResponse:
            return "Respuesta inválida del servidor"
        case .uploadFailed(let code):
            return "Error al subir imagen (código: \(code))"
        case .networkError(let error):
            return "Error de red: \(error.localizedDescription)"
        }
    }
}
