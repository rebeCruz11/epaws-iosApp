//
//  ReportCardView.swift
//  ePaw
//
//  Created by ESTUDIANTE on 07/11/25.
//

import SwiftUI

struct ReportCardView: View {
    let report: Report
    private let imageStorage = ImageStorageService.shared
    
    var timeAgo: String {
        guard let date = ISO8601DateFormatter().date(from: report.createdAt) else {
            return "Hace un momento"
        }
        let interval = Date().timeIntervalSince(date)
        let hours = Int(interval / 3600)
        if hours < 1 {
            return "Hace menos de 1 hora"
        } else if hours == 1 {
            return "Hace 1 hora"
        } else if hours < 24 {
            return "Hace \(hours) horas"
        } else {
            let days = hours / 24
            return "Hace \(days) día\(days > 1 ? "s" : "")"
        }
    }
    
    var displayLocation: String {
        if let address = report.locationAddress, !address.isEmpty {
            return address
        }
        return "Ubicación no especificada"
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // ✅ CAMBIO: Cargar imagen local en lugar de URL remota
            if let imageFilename = report.photoUrls.first, !imageFilename.isEmpty,
               let image = imageStorage.loadImage(filename: imageFilename) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                ZStack {
                    Color.gray.opacity(0.1)
                    Text(report.animalType.icon)
                        .font(.largeTitle)
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Información del reporte
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Reporte #\(report.id.suffix(6))")
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Indicador de urgencia
                    Circle()
                        .fill(urgencyColor(report.urgencyLevel))
                        .frame(width: 8, height: 8)
                }
                
                // Estado
                Text(report.status.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor(report.status))
                    .foregroundColor(.white)
                    .cornerRadius(6)
                
                // Ubicación
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle")
                        .font(.caption)
                    Text(displayLocation)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                // Tiempo
                Text(timeAgo)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Chevron
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 20)
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
}
