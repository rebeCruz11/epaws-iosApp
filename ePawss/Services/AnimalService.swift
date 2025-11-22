//
//  AnimalService.swift
//  ePaw
//

import Foundation

class AnimalService {
    private let api = APIService.shared

    func fetchAnimals() async throws -> ApiResponse<[Animal]> {
        try await api.request(
            endpoint: Endpoints.animals + "?status=available",
            method: .GET,
            responseType: ApiResponse<[Animal]>.self
        )
    }
    
    // MARK: - Crear Animal desde Reporte
    func crearAnimal(request: CrearAnimalRequest) async throws -> Animal {
        struct Response: Codable {
            let success: Bool
            let data: Animal
        }
        
        let encoder = JSONEncoder()
        let bodyData = try encoder.encode(request)
        
        let response = try await api.request(
            endpoint: "/api/animals",
            method: .POST,
            body: bodyData,
            responseType: Response.self
        )
        
        return response.data
    }
}

// MARK: - Request para crear animal
struct CrearAnimalRequest: Codable {
    let name: String
    let species: String
    let breed: String?
    let gender: String
    let ageEstimate: String?
    let size: String
    let color: String?
    let story: String?
    let personalityTraits: [String]?
    let specialNeeds: String?
    let photoUrls: [String]
    let videoUrl: String?
    let healthInfo: HealthInfoRequest?
    let reportId: String
    
    struct HealthInfoRequest: Codable {
        let isVaccinated: Bool
        let isSterilized: Bool
        let isDewormed: Bool
        let medicalNotes: String?
    }
}
