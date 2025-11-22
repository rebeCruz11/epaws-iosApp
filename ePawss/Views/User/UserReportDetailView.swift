//
//  UserReportDetailView.swift
//  ePaw
//
//  Created by ESTUDIANTE on 14/11/25.
//

import SwiftUI

struct UserReportDetailView: View {
    let report: Report
    @Environment(\.dismiss) var dismiss
    private let imageStorage = ImageStorageService.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Imágenes
                if !report.photoUrls.isEmpty {
                    TabView {
                        ForEach(report.photoUrls, id: \.self) { imageFilename in
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
                } else {
                    ZStack {
                        Color.gray.opacity(0.2)
                        VStack(spacing: 8) {
                            Text(report.animalType.icon)
                                .font(.system(size: 80))
                            Text("Sin imágenes")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(height: 250)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    // ID del reporte
                    Text("Reporte #\(report.id.suffix(6))")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Estado y urgencia
                    HStack {
                        Text(report.status.displayName)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(statusColor(report.status))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(urgencyColor(report.urgencyLevel))
                                .frame(width: 10, height: 10)
                            Text(report.urgencyLevel.displayName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Divider()
                    
                    // Tipo de animal
                    HStack {
                        Text("Tipo de animal:")
                            .font(.headline)
                        Text(report.animalType.displayName)
                            .font(.body)
                        Text(report.animalType.icon)
                    }
                    
                    Divider()
                    
                    // Descripción
                    Text("Descripción")
                        .font(.headline)
                    Text(report.description)
                        .font(.body)
                    
                    Divider()
                    
                    // Ubicación
                    Text("Ubicación")
                        .font(.headline)
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                        if let address = report.locationAddress {
                            Text(address)
                                .font(.body)
                        } else if let lat = report.location.latitude, let lon = report.location.longitude {
                            Text("Lat: \(String(format: "%.6f", lat)), Lon: \(String(format: "%.6f", lon))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        } else {
                            Text("Ubicación no especificada")
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Divider()
                    
                    // Organización asignada
                    if let orgInfo = report.organizationInfo {
                        Text("Organización asignada")
                            .font(.headline)
                        Text(orgInfo.organizationDetails?.organizationName ?? orgInfo.name)
                            .font(.body)
                        
                        Divider()
                    }
                    
                    // Veterinaria asignada
                    if let vetInfo = report.veterinaryInfo {
                        Text("Veterinaria asignada")
                            .font(.headline)
                        Text(vetInfo.veterinaryDetails?.clinicName ?? vetInfo.name)
                            .font(.body)
                        
                        Divider()
                    }
                    
                    // Notas adicionales
                    if let notes = report.notes, !notes.isEmpty {
                        Text("Notas")
                            .font(.headline)
                        Text(notes)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Divider()
                    }
                    
                    // Fechas
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Información temporal")
                            .font(.headline)
                        
                        HStack {
                            Text("Creado:")
                                .foregroundColor(.gray)
                            Text(formatDate(report.createdAt))
                                .font(.caption)
                        }
                        
                        if let rescuedAt = report.rescuedAt {
                            HStack {
                                Text("Rescatado:")
                                    .foregroundColor(.gray)
                                Text(formatDate(rescuedAt))
                                    .font(.caption)
                            }
                        }
                        
                        if let closedAt = report.closedAt {
                            HStack {
                                Text("Cerrado:")
                                    .foregroundColor(.gray)
                                Text(formatDate(closedAt))
                                    .font(.caption)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Detalle del Reporte")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    private func statusColor(_ status: ReportStatus) -> Color {
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
    
    private func urgencyColor(_ level: UrgencyLevel) -> Color {
        switch level {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        displayFormatter.locale = Locale(identifier: "es_ES")
        
        return displayFormatter.string(from: date)
    }
}


