//
//  ReportService.swift
//  ePaw
//
//  Created by ESTUDIANTE on 07/11/25.
//

import Foundation

class ReportService {
    private let api = APIService.shared
    
    /// Obtener todos los reportes con filtros
    func getAllReports(
        page: Int = 1,
        limit: Int = 20,
        status: ReportStatus? = nil,
        urgencyLevel: UrgencyLevel? = nil,
        animalType: AnimalType? = nil
    ) async throws -> ReportListResponse {
        var endpoint = "/api/reports?page=\(page)&limit=\(limit)"
        
        if let status = status {
            endpoint += "&status=\(status.rawValue)"
        }
        if let urgencyLevel = urgencyLevel {
            endpoint += "&urgencyLevel=\(urgencyLevel.rawValue)"
        }
        if let animalType = animalType {
            endpoint += "&animalType=\(animalType.rawValue)"
        }
        
        return try await api.request(
            endpoint: endpoint,
            method: .GET,
            responseType: ReportListResponse.self
        )
    }
    
    /// Obtener reportes asignados a la veterinaria actual (autenticada)
    func getVeterinaryReports(page: Int = 1, limit: Int = 20) async throws -> ReportListResponse {
        let endpoint = "\(Endpoints.veterinaryReports)?page=\(page)&limit=\(limit)"
        
        print("🔵 Iniciando petición a: \(endpoint)")
        
        let response = try await api.request(
            endpoint: endpoint,
            method: .GET,
            responseType: ReportListResponse.self
        )
        
        print("🟢 Respuesta recibida: \(response.data.count) reportes")
        
        return response
    }
    
    /// Obtener reportes cercanos
    func getNearbyReports(
        latitude: Double,
        longitude: Double,
        maxDistance: Int = 10000
    ) async throws -> [Report] {
        let endpoint = "/api/reports/nearby?latitude=\(latitude)&longitude=\(longitude)&maxDistance=\(maxDistance)"
        
        let response = try await api.request(
            endpoint: endpoint,
            method: .GET,
            responseType: APIResponse<[Report]>.self
        )
        
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        
        return data
    }
    
    /// Obtener mis reportes (como usuario)
    func getMyReports(page: Int = 1, limit: Int = 20) async throws -> ReportListResponse {
        let endpoint = "/api/reports/my-reports?page=\(page)&limit=\(limit)"
        
        return try await api.request(
            endpoint: endpoint,
            method: .GET,
            responseType: ReportListResponse.self
        )
    }
    
    /// ✅ NUEVO: Obtener reportes del usuario actual (retorna array directo)
    func getUserReports(page: Int = 1, limit: Int = 20) async throws -> [Report] {
        let endpoint = "/api/reports/my-reports?page=\(page)&limit=\(limit)"
        
        print("🔵 Obteniendo reportes del usuario")
        
        let response = try await api.request(
            endpoint: endpoint,
            method: .GET,
            responseType: ReportListResponse.self
        )
        
        print("🟢 \(response.data.count) reportes del usuario obtenidos")
        return response.data
    }
    
    /// Obtener reportes asignados a mi organización
    func getOrganizationReports(page: Int = 1, limit: Int = 20, status: ReportStatus? = nil) async throws -> ReportListResponse {
        var endpoint = "/api/reports/organization/assigned?page=\(page)&limit=\(limit)"
        
        if let status = status {
            endpoint += "&status=\(status.rawValue)"
        }
        
        return try await api.request(
            endpoint: endpoint,
            method: .GET,
            responseType: ReportListResponse.self
        )
    }
    
    /// Obtener detalle de un reporte
    func getReportById(id: String) async throws -> Report {
        let endpoint = "/api/reports/\(id)"
        
        let response = try await api.request(
            endpoint: endpoint,
            method: .GET,
            responseType: APIResponse<Report>.self
        )
        
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        
        return data
    }
    
    func createReport(
        description: String,
        urgencyLevel: UrgencyLevel,
        animalType: AnimalType,
        latitude: Double,
        longitude: Double,
        locationAddress: String?,
        photoUrls: [String],
        organizationId: String?
    ) async throws -> Report {
        struct CreateReportRequest: Codable {
            let description: String
            let urgencyLevel: String
            let animalType: String
            let latitude: Double
            let longitude: Double
            let locationAddress: String?
            let photoUrls: [String]
            let organizationId: String?
        }
        
        let request = CreateReportRequest(
            description: description,
            urgencyLevel: urgencyLevel.rawValue,
            animalType: animalType.rawValue,
            latitude: latitude,
            longitude: longitude,
            locationAddress: locationAddress,
            photoUrls: photoUrls,
            organizationId: organizationId
        )
        
        let encoder = JSONEncoder()
        let body = try encoder.encode(request)
        
        if let jsonString = String(data: body, encoding: .utf8) {
            print("📤 JSON enviado: \(jsonString)")
        }
        
        print("🔵 Creando reporte con organizationId: \(organizationId ?? "ninguna")")
        
        let response = try await api.request(
            endpoint: "/api/reports",
            method: .POST,
            body: body,
            responseType: APIResponse<Report>.self
        )
        
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        
        return data
    }
}

