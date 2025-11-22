//
//  APIError.swift
//  ePaw
//
//  Created by ESTUDIANTE on 25/10/25.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)
    case unauthorized
    case notFound
    case custom(String)
    case noData
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "La URL es inválida"
        case .invalidResponse:
            return "Respuesta del servidor inválida"
        case .serverError(let code):
            return "Error del servidor (código \(code))"
        case .decodingError(let error):
            return "Error al procesar datos: \(error.localizedDescription)"
        case .networkError(let error):
            return "Error de red: \(error.localizedDescription)"
        case .unauthorized:
            return "No autorizado. Inicia sesión nuevamente"
        case .notFound:
            return "Recurso no encontrado"
        
        case .custom(let message):
            return message
        case .noData:
            return "No se recibieron datos del servidor"
        
        }
    }
}
