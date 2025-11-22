//
//  OrganizationService.swift
//  ePaw
//
//  Created by ESTUDIANTE on 15/11/25.
//

import Foundation

class OrganizationService {
    private let api = APIService.shared
    
    // MARK: - Obtener todas las organizaciones (para usuarios)
    func getAllOrganizations() async throws -> [Organization] {
        struct Response: Codable {
            let success: Bool
            let data: [Organization]
        }
        
        let response = try await api.request(
            endpoint: "/api/organizations",
            method: .GET,
            responseType: Response.self
        )
        
        return response.data
    }
    
    // MARK: - Obtener reportes asignados a la organización
    func obtenerReportesAsignados(pagina: Int = 1) async throws -> [Report] {
        let response = try await api.request(
            endpoint: "/api/reports/organization/assigned?page=\(pagina)&limit=20",
            method: .GET,
            responseType: ReportListResponse.self
        )
        
        return response.data
    }
    
    // MARK: - Obtener detalle de un reporte
    func obtenerDetalleReporte(id: String) async throws -> Report {
        struct Response: Codable {
            let success: Bool
            let data: Report
        }
        
        let response = try await api.request(
            endpoint: "/api/reports/\(id)",
            method: .GET,
            responseType: Response.self
        )
        
        return response.data
    }
    
    // MARK: - Actualizar estado del reporte
    func actualizarEstado(reporteId: String, nuevoEstado: ReportStatus, notas: String?) async throws -> Report {
        struct Request: Codable {
            let status: String
            let notes: String?
        }
        
        struct Response: Codable {
            let success: Bool
            let data: Report
        }
        
        let body = Request(status: nuevoEstado.rawValue, notes: notas)
        let encoder = JSONEncoder()
        let bodyData = try encoder.encode(body)
        
        let response = try await api.request(
            endpoint: "/api/reports/\(reporteId)",
            method: .PUT,
            body: bodyData,
            responseType: Response.self
        )
        
        return response.data
    }
}
