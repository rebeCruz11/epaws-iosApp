//
//  VeterinaryViewModel.swift
//  ePaw
//
//  Created by ESTUDIANTE on 07/11/25.
//

import Foundation

@MainActor
class VeterinaryViewModel: ObservableObject {
    @Published var veterinaries: [VeterinaryListItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var currentPage: Int = 1
    @Published var totalPages: Int = 1
    @Published var searchText: String = ""
    
    private let service = VeterinaryService()
    
    // MARK: - Cargar veterinarias
    func loadVeterinaries(page: Int = 1) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await service.getAllVeterinaries(page: page, limit: 10)
            veterinaries = response.veterinaries
            currentPage = response.pagination.currentPage  // ✅ CAMBIO AQUÍ
            totalPages = response.pagination.totalPages
            isLoading = false
        } catch let error as APIError {
            handleError(error)
            isLoading = false
        } catch {
            errorMessage = "Error al cargar veterinarias: \(error.localizedDescription)"
            showError = true
            isLoading = false
        }
    }
    
    // MARK: - Buscar por especialidad
    func searchBySpecialty(_ specialty: String, page: Int = 1) async {
        guard !specialty.isEmpty else {
            await loadVeterinaries(page: page)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await service.searchBySpecialty(specialty: specialty, page: page, limit: 10)
            veterinaries = response.veterinaries
            currentPage = response.pagination.currentPage  // ✅ CAMBIO AQUÍ
            totalPages = response.pagination.totalPages
            isLoading = false
        } catch let error as APIError {
            handleError(error)
            isLoading = false
        } catch {
            errorMessage = "Error en la búsqueda: \(error.localizedDescription)"
            showError = true
            isLoading = false
        }
    }
    
    // MARK: - Cargar veterinarias cercanas
    func loadNearbyVeterinaries(latitude: Double, longitude: Double, maxDistance: Int = 20000) async {
        isLoading = true
        errorMessage = nil
        
        do {
            veterinaries = try await service.getNearbyVeterinaries(
                latitude: latitude,
                longitude: longitude,
                maxDistance: maxDistance
            )
            isLoading = false
        } catch let error as APIError {
            handleError(error)
            isLoading = false
        } catch {
            errorMessage = "Error al cargar veterinarias cercanas: \(error.localizedDescription)"
            showError = true
            isLoading = false
        }
    }
    
    // MARK: - Error Handler
    private func handleError(_ error: APIError) {
        errorMessage = error.localizedDescription
        showError = true
    }
}
