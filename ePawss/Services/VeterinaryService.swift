//
//  VeterinaryService.swift
//  ePaw
//
//  Created by ESTUDIANTE on 07/11/25.
//

import Foundation

class VeterinaryService {
    private let api = APIService.shared
    
    /// Obtener todas las veterinarias con paginación
    func getAllVeterinaries(page: Int = 1, limit: Int = 10) async throws -> VeterinaryListResponse {
        let endpoint = "\(Endpoints.veterinaries)?page=\(page)&limit=\(limit)"
        
        let response = try await api.request(
            endpoint: endpoint,
            method: .GET,
            responseType: APIResponse<VeterinaryListResponse>.self
        )
        
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        
        return data
    }
    
    /// Buscar veterinarias por especialidad
    func searchBySpecialty(specialty: String, page: Int = 1, limit: Int = 10) async throws -> VeterinaryListResponse {
        let encodedSpecialty = specialty.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? specialty
        let endpoint = "\(Endpoints.veterinariesSearch)?specialty=\(encodedSpecialty)&page=\(page)&limit=\(limit)"
        
        let response = try await api.request(
            endpoint: endpoint,
            method: .GET,
            responseType: APIResponse<VeterinaryListResponse>.self
        )
        
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        
        return data
    }
    
    /// Obtener veterinarias cercanas
    func getNearbyVeterinaries(
        latitude: Double,
        longitude: Double,
        maxDistance: Int = 20000
    ) async throws -> [VeterinaryListItem] {
        let endpoint = "\(Endpoints.veterinariesNearby)?latitude=\(latitude)&longitude=\(longitude)&maxDistance=\(maxDistance)"
        
        let response = try await api.request(
            endpoint: endpoint,
            method: .GET,
            responseType: APIResponse<[VeterinaryListItem]>.self
        )
        
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        
        return data
    }
    
    /// Obtener detalle de veterinaria por ID
    func getVeterinaryById(id: String) async throws -> User {
        let endpoint = Endpoints.veterinaryDetail(id: id)
        
        let response = try await api.request(
            endpoint: endpoint,
            method: .GET,
            responseType: APIResponse<User>.self
        )
        
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        
        return data
    }
}
