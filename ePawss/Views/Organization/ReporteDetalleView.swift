//
//  ReporteDetalleView.swift
//  ePaw
//

import SwiftUI

struct ReporteDetalleView: View {
    let reporteId: String
    @StateObject private var viewModel = ReporteDetalleViewModel()
    @State private var mostrarActualizarEstado = false
    @State private var mostrarCrearAnimal = false
    @State private var nuevoEstado: ReportStatus = .pending
    @State private var notas = ""
    
    private let imageStorage = ImageStorageService.shared
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView()
                    .padding()
            } else if let reporte = viewModel.reporte {
                VStack(alignment: .leading, spacing: 20) {
                    // Imágenes locales con TabView
                    if !reporte.photoUrls.isEmpty {
                        TabView {
                            ForEach(reporte.photoUrls, id: \.self) { imageFilename in
                                if let image = imageStorage.loadImage(filename: imageFilename) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                } else {
                                    ZStack {
                                        Color.gray.opacity(0.2)
                                        VStack(spacing: 8) {
                                            Image(systemName: "photo.slash")
                                                .font(.system(size: 50))
                                                .foregroundColor(.gray)
                                            Text("Imagen no disponible")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                        }
                        .frame(height: 300)
                        .tabViewStyle(.page)
                    }
                    
                    // Ubicación
                    if let direccion = reporte.locationAddress {
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.blue)
                            Text(direccion)
                                .font(.subheadline)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    
                    // Información principal
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Reporte #\(String(reporte.id.prefix(6)))")
                                .font(.headline)
                            Spacer()
                            Text(formatearFecha(reporte.createdAt))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        HStack(spacing: 8) {
                            Text(reporte.animalType.icon)
                            Text(reporte.animalType.displayName)
                                .font(.subheadline)
                            
                            // Badge de urgencia
                            Text(reporte.urgencyLevel.displayName)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(urgenciaColor(reporte.urgencyLevel))
                                .cornerRadius(6)
                            
                            // Badge de estado
                            Text(reporte.status.displayName)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(estadoColor(reporte.status))
                                .cornerRadius(6)
                        }
                        
                        if let reportador = reporte.reporterInfo {
                            HStack {
                                Image(systemName: "person.fill")
                                    .font(.caption)
                                Text("Reportado por: \(reportador.name)")
                                    .font(.subheadline)
                            }
                            .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Descripción
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Descripción")
                            .font(.headline)
                        Text(reporte.description)
                            .font(.body)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Botón actualizar estado
                    Button {
                        nuevoEstado = reporte.status
                        mostrarActualizarEstado = true
                    } label: {
                        Text("Actualizar Estado")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // ✅ NUEVO: Botón crear perfil de animal
                    if reporte.status == .rescued || reporte.status == .inVeterinary {
                        Button {
                            mostrarCrearAnimal = true
                        } label: {
                            HStack {
                                Image(systemName: "pawprint.fill")
                                Text("Crear Perfil de Animal")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Detalle del Reporte")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.cargarReporte(id: reporteId)
        }
        .sheet(isPresented: $mostrarActualizarEstado) {
            NavigationStack {
                Form {
                    Section("Nuevo Estado") {
                        Picker("Estado", selection: $nuevoEstado) {
                            ForEach([ReportStatus.pending, .assigned, .rescued, .inVeterinary, .recovered, .closed], id: \.self) { estado in
                                Text(estado.displayName).tag(estado)
                            }
                        }
                    }
                    
                    Section("Notas (opcional)") {
                        TextEditor(text: $notas)
                            .frame(height: 100)
                    }
                    
                    Section {
                        Button {
                            Task {
                                await viewModel.actualizarEstado(
                                    reporteId: reporteId,
                                    nuevoEstado: nuevoEstado,
                                    notas: notas.isEmpty ? nil : notas
                                )
                                mostrarActualizarEstado = false
                            }
                        } label: {
                            if viewModel.actualizandoEstado {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text("Guardar")
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.white)
                            }
                        }
                        .listRowBackground(Color.orange)
                        .disabled(viewModel.actualizandoEstado)
                    }
                }
                .navigationTitle("Actualizar Estado")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancelar") {
                            mostrarActualizarEstado = false
                        }
                    }
                }
            }
        }
        // ✅ NUEVO: Sheet para crear animal
        .sheet(isPresented: $mostrarCrearAnimal) {
            if let reporte = viewModel.reporte {
                CreateAnimalFromReportView(reporte: reporte)
            }
        }
    }
    
    private func formatearFecha(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: iso) else { return iso }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        displayFormatter.locale = Locale(identifier: "es_ES")
        
        return displayFormatter.string(from: date)
    }
    
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
