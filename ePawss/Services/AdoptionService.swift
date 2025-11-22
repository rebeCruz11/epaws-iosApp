//
//  AdoptionService.swift
//  ePaw
//
//  Created by ESTUDIANTE on 14/11/25.
//

import Foundation

class AdoptionService {
    private let api = APIService.shared
    
    // MARK: - Submit Adoption
    func submitAdoption(
        animalId: String,
        applicationMessage: String,
        adopterInfo: AdopterInfo
    ) async throws -> Adoption {
        struct Request: Codable {
            let animalId: String
            let applicationMessage: String
            let adopterInfo: AdopterInfo
        }
        
        let request = Request(
            animalId: animalId,
            applicationMessage: applicationMessage,
            adopterInfo: adopterInfo
        )
        
        let encoder = JSONEncoder()
        let body = try encoder.encode(request)
        
        print("🔵 [AdoptionService] Enviando solicitud de adopción para animal: \(animalId)")
        
        do {
            let response = try await api.request(
                endpoint: "/api/adoptions",
                method: .POST,
                body: body,
                responseType: APIResponse<Adoption>.self
            )
            
            guard let adoption = response.data else {
                // ✅ Si data es nil pero hay mensaje, lanza con ese mensaje
                throw NSError(
                    domain: "",
                    code: 400,
                    userInfo: [NSLocalizedDescriptionKey: response.message ?? "Error al enviar solicitud"]
                )
            }
            
            print("🟢 [AdoptionService] Solicitud enviada exitosamente: \(adoption.id)")
            return adoption
            
        } catch {
            // ✅ Re-lanza el error para que lo capture el ViewModel
            print("🔴 [AdoptionService] Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Get My Applications
    func getMyApplications(page: Int = 1, limit: Int = 10, status: AdoptionStatus? = nil) async throws -> [Adoption] {
        var endpoint = "/api/adoptions/my-applications?page=\(page)&limit=\(limit)"
        
        if let status = status {
            endpoint += "&status=\(status.rawValue)"
        }
        
        print("🔵 [AdoptionService] Obteniendo mis solicitudes")
        
        let response = try await api.request(
            endpoint: endpoint,
            method: .GET,
            responseType: PaginatedResponse<Adoption>.self
        )
        
        print("🟢 [AdoptionService] \(response.data.count) solicitudes obtenidas")
        return response.data
    }
    
    // MARK: - Get Adoption By ID
    func getAdoptionById(id: String) async throws -> Adoption {
        print("🔵 [AdoptionService] Obteniendo adopción: \(id)")
        
        let response = try await api.request(
            endpoint: "/api/adoptions/\(id)",
            method: .GET,
            responseType: APIResponse<Adoption>.self
        )
        
        guard let adoption = response.data else {
            throw NSError(
                domain: "",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: response.message ?? "Adopción no encontrada"]
            )
        }
        
        print("🟢 [AdoptionService] Adopción obtenida")
        return adoption
    }
    
    // MARK: - Cancel Adoption
    func cancelAdoption(id: String) async throws -> Adoption {
        print("🔵 [AdoptionService] Cancelando adopción: \(id)")
        
        let response = try await api.request(
            endpoint: "/api/adoptions/\(id)/cancel",
            method: .PUT,
            responseType: APIResponse<Adoption>.self
        )
        
        guard let adoption = response.data else {
            throw NSError(
                domain: "",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: response.message ?? "Error al cancelar adopción"]
            )
        }
        
        print("🟢 [AdoptionService] Adopción cancelada")
        return adoption
    }
    
    // MARK: - Organization Methods
    
    /// Obtener solicitudes de adopción de la organización
    func getOrganizationAdoptions(organizationId: String, status: AdoptionStatus? = nil, page: Int = 1) async throws -> [Adoption] {
        return await withCheckedContinuation { continuation in
            var statusString: String? = nil
            if let status = status {
                statusString = status.rawValue
            }
            
            APIService.shared.fetchOrganizationAdoptions(organizationId: organizationId, status: statusString, page: page) { result in
                switch result {
                case .success(let adoptions):
                    continuation.resume(returning: adoptions)
                case .failure(let error):
                    print("🔴 [AdoptionService] Error obteniendo adopciones: \(error)")
                    continuation.resume(returning: [])
                }
            }
        }
    }
    
    /// Obtener solicitudes de adopción para un animal específico
    func getAdoptionsForAnimal(animalId: String) async throws -> [Adoption] {
        return await withCheckedContinuation { continuation in
            APIService.shared.fetchAdoptionsForAnimal(animalId: animalId) { result in
                switch result {
                case .success(let adoptions):
                    continuation.resume(returning: adoptions)
                case .failure(let error):
                    print("🔴 [AdoptionService] Error obteniendo adopciones del animal: \(error)")
                    continuation.resume(returning: [])
                }
            }
        }
    }
    
    /// Actualizar estado de adopción (aprobar/rechazar/completar)
    func updateAdoptionStatus(adoptionId: String, status: AdoptionStatus, reviewNotes: String? = nil, rejectionReason: String? = nil) async throws -> Adoption {
        return try await withCheckedThrowingContinuation { continuation in
            APIService.shared.updateAdoptionStatus(
                adoptionId: adoptionId,
                status: status.rawValue,
                reviewNotes: reviewNotes,
                rejectionReason: rejectionReason
            ) { result in
                switch result {
                case .success(let adoption):
                    continuation.resume(returning: adoption)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - Response Models
struct PaginatedResponse<T: Codable>: Codable {
    let data: [T]
    let pagination: Pagination?
    
    struct Pagination: Codable {
        let currentPage: Int
        let totalPages: Int
        let totalItems: Int
        let itemsPerPage: Int
    }
}
