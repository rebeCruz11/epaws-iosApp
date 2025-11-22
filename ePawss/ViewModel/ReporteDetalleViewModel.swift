//
//  ReporteDetalleViewModel.swift
//  ePaw
//
//  Created by ESTUDIANTE on 15/11/25.
//

import Foundation

@MainActor
class ReporteDetalleViewModel: ObservableObject {
    @Published var reporte: Report?
    @Published var isLoading = false
    @Published var error: String?
    @Published var actualizandoEstado = false
    
    private let servicio = OrganizationService()
    
    func cargarReporte(id: String) async {
        isLoading = true
        error = nil
        
        do {
            reporte = try await servicio.obtenerDetalleReporte(id: id)
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func actualizarEstado(reporteId: String, nuevoEstado: ReportStatus, notas: String?) async {
        actualizandoEstado = true
        
        do {
            reporte = try await servicio.actualizarEstado(
                reporteId: reporteId,
                nuevoEstado: nuevoEstado,
                notas: notas
            )
        } catch {
            self.error = error.localizedDescription
        }
        
        actualizandoEstado = false
    }
}
