//
//  OrganizationReportsView.swift
//  ePaw
//

import SwiftUI

struct OrganizationReportsView: View {
    @StateObject private var viewModel = OrganizationReportsViewModel()
    @State private var filtroEstado: ReportStatus?
    @State private var textoBusqueda = ""
    
    var reportesFiltrados: [Report] {
        var resultados = viewModel.reportes
        
        if let estado = filtroEstado {
            resultados = resultados.filter { $0.status == estado }
        }
        
        if !textoBusqueda.isEmpty {
            resultados = resultados.filter {
                $0.description.localizedCaseInsensitiveContains(textoBusqueda) ||
                ($0.locationAddress?.localizedCaseInsensitiveContains(textoBusqueda) ?? false)
            }
        }
        
        return resultados
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Buscador
            TextField("Buscar reportes...", text: $textoBusqueda)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            
            // Filtros
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    OrgFiltroBoton(titulo: "Todos", seleccionado: filtroEstado == nil) {
                        filtroEstado = nil
                    }
                    OrgFiltroBoton(titulo: "Pendientes", seleccionado: filtroEstado == .pending) {
                        filtroEstado = .pending
                    }
                    OrgFiltroBoton(titulo: "Rescatados", seleccionado: filtroEstado == .rescued) {
                        filtroEstado = .rescued
                    }
                    OrgFiltroBoton(titulo: "En Veterinaria", seleccionado: filtroEstado == .inVeterinary) {
                        filtroEstado = .inVeterinary
                    }
                }
                .padding(.horizontal)
            }
            
            // Lista
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxHeight: .infinity)
            } else if reportesFiltrados.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("No hay reportes")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(reportesFiltrados) { reporte in
                            NavigationLink(destination: ReporteDetalleView(reporteId: reporte.id)) {
                                OrgReporteListCard(reporte: reporte)
                                    .padding(.horizontal)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Reportes")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.cargarReportes()
        }
        .refreshable {
            await viewModel.cargarReportes()
        }
    }
}

// MARK: - Org Reporte List Card (CON IMAGEN LOCAL)
struct OrgReporteListCard: View {
    let reporte: Report
    private let imageStorage = ImageStorageService.shared  // ✅ AGREGADO
    
    var body: some View {
        HStack(spacing: 14) {
            // ✅ Cargar imagen local
            if let primeraFoto = reporte.photoUrls.first,
               let image = imageStorage.loadImage(filename: primeraFoto) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Reporte #\(String(reporte.id.prefix(6)))")
                        .font(.system(size: 15, weight: .semibold))
                    Spacer()
                    // ✅ Badge de estado
                    Text(reporte.status.displayName)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(estadoColor(reporte.status))
                        .cornerRadius(6)
                }
                
                Text(reporte.description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 11))
                        Text(reporte.locationAddress ?? "Sin dirección")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.gray)
                    
                    // ✅ Badge de urgencia
                    Text(reporte.urgencyLevel.displayName)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(urgenciaColor(reporte.urgencyLevel))
                        .cornerRadius(5)
                }
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
    
    // ✅ Funciones helper
    private func urgenciaColor(_ urgency: UrgencyLevel) -> Color {
        switch urgency {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }
    
    private func estadoColor(_ status: ReportStatus) -> Color {
        switch status {
        case .pending: return .orange
        case .assigned: return .blue
        case .rescued: return .green
        case .inVeterinary: return .purple
        case .recovered: return .teal
        case .adopted: return .pink
        case .closed: return .gray
        }
    }
}

// MARK: - Org Filtro Boton
struct OrgFiltroBoton: View {
    let titulo: String
    let seleccionado: Bool
    let accion: () -> Void
    
    var body: some View {
        Button(action: accion) {
            Text(titulo)
                .font(.system(size: 13, weight: seleccionado ? .semibold : .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(seleccionado ? Color.orange : Color.white)
                .foregroundColor(seleccionado ? .white : .gray)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(seleccionado ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}
