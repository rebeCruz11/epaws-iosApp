//
//  ReportViewModel.swift
//  ePaw
//
//  Created by ESTUDIANTE on 07/11/25.
//

import Foundation

@MainActor
class ReportViewModel: ObservableObject {
    @Published var reports: [Report] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var currentPage: Int = 1
    @Published var totalPages: Int = 1
    
    private let service = ReportService()
    
    
    /// Cargar reportes para veterinarias (asignados a esta veterinaria)
    func loadVeterinaryReports(page: Int = 1) async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await service.getVeterinaryReports(
                page: page,
                limit: 20
            )
            
            guard !Task.isCancelled else {
                isLoading = false
                return
            }
            
            if page == 1 {
                reports = response.data
            } else {
                reports.append(contentsOf: response.data)
            }
            currentPage = response.pagination.currentPage
            totalPages = response.pagination.totalPages
            isLoading = false
        } catch is CancellationError {
            isLoading = false
        } catch let error as APIError {
            errorMessage = error.localizedDescription
            showError = true
            isLoading = false
        } catch {
            if !Task.isCancelled {
                errorMessage = "Error al cargar reportes: \(error.localizedDescription)"
                showError = true
            }
            isLoading = false
        }
    }

    
    /// Cargar reportes de organización
    func loadOrganizationReports(page: Int = 1, status: ReportStatus? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await service.getOrganizationReports(page: page, limit: 20, status: status)
            if page == 1 {
                reports = response.data
            } else {
                reports.append(contentsOf: response.data)
            }
            currentPage = response.pagination.currentPage
            totalPages = response.pagination.totalPages
            isLoading = false
        } catch let error as APIError {
            errorMessage = error.localizedDescription
            showError = true
            isLoading = false
        } catch {
            errorMessage = "Error al cargar reportes: \(error.localizedDescription)"
            showError = true
            isLoading = false
        }
    }
    
    /// Cargar reportes cercanos
    func loadNearbyReports(latitude: Double, longitude: Double, maxDistance: Int = 10000) async {
        isLoading = true
        errorMessage = nil
        
        do {
            reports = try await service.getNearbyReports(
                latitude: latitude,
                longitude: longitude,
                maxDistance: maxDistance
            )
            isLoading = false
        } catch let error as APIError {
            errorMessage = error.localizedDescription
            showError = true
            isLoading = false
        } catch {
            errorMessage = "Error al cargar reportes cercanos: \(error.localizedDescription)"
            showError = true
            isLoading = false
        }
    }
}
