//
//  OrganizationReportsViewModel.swift
//  ePaw
//
//  Created by ESTUDIANTE on 15/11/25.
//

import Foundation

@MainActor
class OrganizationReportsViewModel: ObservableObject {
    @Published var reportes: [Report] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let servicio = OrganizationService()
    
    func cargarReportes() async {
        isLoading = true
        error = nil
        
        do {
            reportes = try await servicio.obtenerReportesAsignados()
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
}
