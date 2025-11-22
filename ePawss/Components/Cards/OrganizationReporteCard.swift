//
//  OrganizationReporteCard.swift
//  ePaw
//
//  Created by ESTUDIANTE on 7/11/25.
//

import SwiftUI

struct OrganizationReporteCard: View {
    let reporte: OrganizationReport

    var colorUrgencia: Color {
        switch reporte.urgencyLevel {
        case "critical", "high": return .red
        case "medium": return .yellow
        case "low": return .gray
        default: return .gray
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            if let urlString = reporte.photoUrls.first, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray.opacity(0.1)
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Reporte #\(reporte.id.prefix(6))")
                        .font(.headline)
                    Spacer()
                    Text(reporte.urgencyLevel.capitalized)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(colorUrgencia)
                        .foregroundColor(.white)
                        .cornerRadius(7)
                }
                Text(reporte.animalType.capitalized)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(reporte.locationAddress)
                    .font(.caption)
                    .foregroundColor(.secondary)
                if let nombre = reporte.reporterId?.name {
                    HStack {
                        Image(systemName: "person.fill")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text("Por: \(nombre)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                Text(dateShort(reporte.createdAt))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 5)
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color(.systemGray4), radius: 1, x: 0, y: 1)
    }

    func dateShort(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: iso) else { return "" }
        let daysAgo = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        return "Hace \(daysAgo) días"
    }
}
